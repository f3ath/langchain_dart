import 'package:http/http.dart' as http;
import 'package:langchain/langchain.dart';
import 'package:tiktoken/tiktoken.dart';
import 'package:uuid/uuid.dart';
import 'package:vertex_ai/vertex_ai.dart';

import 'models/mappers.dart';
import 'models/models.dart';

/// {@template chat_vertex_ai}
/// Wrapper around GCP Vertex AI text chat models API (aka PaLM API for chat).
///
/// Example:
/// ```dart
/// final chatModel = ChatVertexAI(
///   authHttpClient: authClient,
///   project: 'your-project-id',
/// );
/// final result = await chatModel([ChatMessage.humanText('Hello')]);
/// ```
///
/// Vertex AI documentation:
/// https://cloud.google.com/vertex-ai/docs/generative-ai/language-model-overview
///
/// ### Set up your Google Cloud Platform project
///
/// 1. [Select or create a Google Cloud project](https://console.cloud.google.com/cloud-resource-manager).
/// 2. [Make sure that billing is enabled for your project](https://cloud.google.com/billing/docs/how-to/modify-project).
/// 3. [Enable the Vertex AI API](https://console.cloud.google.com/flows/enableapi?apiid=aiplatform.googleapis.com).
/// 4. [Configure the Vertex AI location](https://cloud.google.com/vertex-ai/docs/general/locations).
///
/// ### Authentication
///
/// To create an instance of `ChatVertexAI` you need to provide an
/// HTTP client that handles authentication. The easiest way to do this is to
/// use [`AuthClient`](https://pub.dev/documentation/googleapis_auth/latest/googleapis_auth/AuthClient-class.html)
/// from the [googleapis_auth](https://pub.dev/packages/googleapis_auth)
/// package.
///
/// There are several ways to obtain an `AuthClient` depending on your use case.
/// Check out the [googleapis_auth](https://pub.dev/packages/googleapis_auth)
/// package documentation for more details.
///
/// Example using a service account JSON:
///
/// ```dart
/// final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
///   json.decode(serviceAccountJson),
/// );
/// final authClient = await clientViaServiceAccount(
///   serviceAccountCredentials,
///   [ChatVertexAI.cloudPlatformScope],
/// );
/// final chatVertexAi = ChatVertexAI(
///   httpClient: authClient,
///   project: 'your-project-id',
/// );
/// ```
///
/// The service account should have the following
/// [permission](https://cloud.google.com/vertex-ai/docs/general/iam-permissions):
/// - `aiplatform.endpoints.predict`
///
/// The required[OAuth2 scope](https://developers.google.com/identity/protocols/oauth2/scopes)
/// is:
/// - `https://www.googleapis.com/auth/cloud-platform` (you can use the
///   constant `ChatVertexAI.cloudPlatformScope`)
///
/// See: https://cloud.google.com/vertex-ai/docs/generative-ai/access-control
///
/// ### Available models
///
/// - `chat-bison`
///   * Max input token: 4096
///   * Max output tokens: 1024
///   * Training data: Up to Feb 2023
///   * Max turns: 2500
/// - `chat-bison-32k`
///   * Max input and output tokens combined: 32k
///   * Training data: Up to Aug 2023
///   * Max turns: 2500
///
/// The previous list of models may not be exhaustive or up-to-date. Check out
/// the [Vertex AI documentation](https://cloud.google.com/vertex-ai/docs/generative-ai/learn/models)
/// for the latest list of available models.
///
/// ### Model options
///
/// You can define default options to use when calling the model (e.g.
/// temperature, stop sequences, etc. ) using the [defaultOptions] parameter.
///
/// The default options can be overridden when calling the model using the
/// `options` parameter.
///
/// Example:
/// ```dart
/// final chatModel = ChatVertexAI(
///   httpClient: authClient,
///   project: 'your-project-id',
///   defaultOptions: ChatVertexAIOptions(
///     temperature: 0.9,
///   ),
/// );
/// final result = await chatModel(
///   [ChatMessage.humanText('Hello')],
///   options: ChatVertexAIOptions(
///     temperature: 0.5,
///    ),
/// );
/// ```
/// {@endtemplate}
class ChatVertexAI extends BaseChatModel<ChatVertexAIOptions> {
  /// {@macro chat_vertex_ai}
  ChatVertexAI({
    required final http.Client httpClient,
    required final String project,
    final String location = 'us-central1',
    final String? rootUrl,
    this.defaultOptions = const ChatVertexAIOptions(),
  }) : client = VertexAIGenAIClient(
          httpClient: httpClient,
          project: project,
          location: location,
          rootUrl: rootUrl ?? 'https://$location-aiplatform.googleapis.com/',
        );

  /// A client for interacting with Vertex AI API.
  final VertexAIGenAIClient client;

  /// The default options to use when calling the model.
  final ChatVertexAIOptions defaultOptions;

  /// Scope required for Vertex AI API calls.
  static const cloudPlatformScope = VertexAIGenAIClient.cloudPlatformScope;

  /// A UUID generator.
  late final Uuid _uuid = const Uuid();

  @override
  String get modelType => 'vertex-ai-chat';

  @override
  Future<ChatResult> generate(
    final List<ChatMessage> messages, {
    final ChatVertexAIOptions? options,
  }) async {
    final id = _uuid.v4();
    String? context;
    final vertexMessages = <VertexAITextChatModelMessage>[];
    for (final message in messages) {
      if (message is SystemChatMessage) {
        context = message.content;
        continue;
      } else {
        vertexMessages.add(message.toVertexAIChatMessage());
      }
    }
    final examples = (options?.examples ?? defaultOptions.examples)
        ?.map((final e) => e.toVertexAIChatExample())
        .toList(growable: false);

    final result = await client.chat.predict(
      context: context,
      examples: examples,
      messages: vertexMessages,
      publisher: options?.publisher ?? defaultOptions.publisher,
      model: options?.model ?? defaultOptions.model,
      parameters: VertexAITextChatModelRequestParams(
        maxOutputTokens:
            options?.maxOutputTokens ?? defaultOptions.maxOutputTokens,
        temperature: options?.temperature ?? defaultOptions.temperature,
        topP: options?.topP ?? defaultOptions.topP,
        topK: options?.topK ?? defaultOptions.topK,
        stopSequences: options?.stopSequences ?? defaultOptions.stopSequences,
        candidateCount:
            options?.candidateCount ?? defaultOptions.candidateCount,
      ),
    );
    return result.toChatResult(id, options?.model ?? defaultOptions.model);
  }

  /// Tokenizes the given prompt using tiktoken.
  ///
  /// Currently Google does not provide a tokenizer for Vertex AI models.
  /// So we use tiktoken and text-davinci-003 model to get an approximation
  /// for counting tokens. Mind that the actual tokens will be totally
  /// different from the ones used by the Vertex AI model.
  ///
  /// - [promptValue] The prompt to tokenize.
  @override
  Future<List<int>> tokenize(
    final PromptValue promptValue, {
    final ChatVertexAIOptions? options,
  }) async {
    final encoding = encodingForModel('text-davinci-003');
    return encoding.encode(promptValue.toString());
  }
}
