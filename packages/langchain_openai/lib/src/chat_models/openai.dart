import 'package:http/http.dart' as http;
import 'package:langchain/langchain.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:tiktoken/tiktoken.dart';

import 'models/mappers.dart';
import 'models/models.dart';

/// Wrapper around [OpenAI Chat API](https://platform.openai.com/docs/api-reference/chat).
///
/// Example:
/// ```dart
/// final chat = ChatOpenAI(apiKey: '...', temperature: 1);
/// final messages = [
///   ChatMessage.system('You are a helpful assistant that translates English to French.'),
///   ChatMessage.humanText('I love programming.')
/// ];
/// final res = await chat(messages);
/// ```
///
/// - [Completions guide](https://platform.openai.com/docs/guides/gpt/chat-completions-api)
/// - [Completions API docs](https://platform.openai.com/docs/api-reference/chat)
///
/// ### Authentication
///
/// The OpenAI API uses API keys for authentication. Visit your
/// [API Keys](https://platform.openai.com/account/api-keys) page to retrieve
/// the API key you'll use in your requests.
///
/// #### Organization (optional)
///
/// For users who belong to multiple organizations, you can specify which
/// organization is used for an API request. Usage from these API requests will
/// count against the specified organization's subscription quota.
///
/// ```dart
/// final client = ChatOpenAI(
///   apiKey: 'OPENAI_API_KEY',
///   organization: 'org-dtDDtkEGoFccn5xaP5W1p3Rr',
/// );
/// ```
///
/// ### Advance
///
/// #### Azure OpenAI Service
///
/// OpenAI's models are also available as an [Azure service](https://learn.microsoft.com/en-us/azure/ai-services/openai/overview).
///
/// Although the Azure OpenAI API is similar to the official OpenAI API, there
/// are subtle differences between them. This client is intended to be used
/// with the official OpenAI API, but most of the functionality should work
/// with the Azure OpenAI API as well.
///
/// If you want to use this client with the Azure OpenAI API (at your own risk),
/// you can do so by instantiating the client as follows:
///
/// ```dart
/// final client = ChatOpenAI(
///   baseUrl: 'https://YOUR_RESOURCE_NAME.openai.azure.com/openai/deployments/YOUR_DEPLOYMENT_NAME',
///   headers: { 'api-key': 'YOUR_API_KEY' },
///   queryParams: { 'api-version': 'API_VERSION' },
/// );
/// ```
///
/// - `YOUR_RESOURCE_NAME`: This value can be found in the Keys & Endpoint
///    section when examining your resource from the Azure portal.
/// - `YOUR_DEPLOYMENT_NAME`: This value will correspond to the custom name
///    you chose for your deployment when you deployed a model. This value can be found under Resource Management > Deployments in the Azure portal.
/// - `YOUR_API_KEY`: This value can be found in the Keys & Endpoint section
///    when examining your resource from the Azure portal.
/// - `API_VERSION`: The Azure OpenAI API version to use (e.g. `2023-05-15`).
///    Try to use the [latest version available](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/cognitiveservices/data-plane/AzureOpenAI/inference),
///    it will probably be the closest to the official OpenAI API.
///
/// #### Custom HTTP client
///
/// You can always provide your own implementation of `http.Client` for further
/// customization:
///
/// ```dart
/// final client = ChatOpenAI(
///   apiKey: 'OPENAI_API_KEY',
///   client: MyHttpClient(),
/// );
/// ```
///
/// #### Using a proxy
///
/// ##### HTTP proxy
///
/// You can use your own HTTP proxy by overriding the `baseUrl` and providing
/// your required `headers`:
///
/// ```dart
/// final client = ChatOpenAI(
///   baseUrl: 'https://my-proxy.com',
///   headers: {'x-my-proxy-header': 'value'},
/// );
/// ```
///
/// If you need further customization, you can always provide your own
/// `http.Client`.
///
/// ##### SOCKS5 proxy
///
/// To use a SOCKS5 proxy, you can use the
/// [`socks5_proxy`](https://pub.dev/packages/socks5_proxy) package and a
/// custom `http.Client`.
class ChatOpenAI extends BaseChatModel<ChatOpenAIOptions> {
  /// Create a new [ChatOpenAI] instance.
  ///
  /// Main configuration options:
  /// - `apiKey`: your OpenAI API key. You can find your API key in the
  ///   [OpenAI dashboard](https://platform.openai.com/account/api-keys).
  /// - `organization`: your OpenAI organization ID (if applicable).
  /// - [ChatOpenAI.encoding]
  /// - [OpenAI.defaultOptions]
  ///
  /// Advance configuration options:
  /// - `baseUrl`: the base URL to use. Defaults to OpenAI's API URL. You can
  ///   override this to use a different API URL, or to use a proxy.
  /// - `headers`: global headers to send with every request. You can use
  ///   this to set custom headers, or to override the default headers.
  /// - `queryParams`: global query parameters to send with every request. You
  ///   can use this to set custom query parameters (e.g. Azure OpenAI API
  ///   required to attach a `version` query parameter to every request).
  /// - `client`: the HTTP client to use. You can set your own HTTP client if
  ///   you need further customization (e.g. to use a Socks5 proxy).
  ChatOpenAI({
    final String? apiKey,
    final String? organization,
    final String? baseUrl,
    final Map<String, String>? headers,
    final Map<String, dynamic>? queryParams,
    final http.Client? client,
    this.defaultOptions = const ChatOpenAIOptions(),
    this.encoding,
  }) : _client = OpenAIClient(
          apiKey: apiKey ?? '',
          organization: organization,
          baseUrl: baseUrl,
          headers: headers,
          queryParams: queryParams,
          client: client,
        );

  /// A client for interacting with OpenAI API.
  final OpenAIClient _client;

  /// The default options to use when calling the completions API.
  final ChatOpenAIOptions defaultOptions;

  /// The encoding to use by tiktoken when [tokenize] is called.
  ///
  /// By default, when [encoding] is not set, it is derived from the [model].
  /// However, there are some cases where you may want to use this wrapper
  /// class with a [model] not supported by tiktoken (e.g. when using Azure
  /// embeddings or when using one of the many model providers that expose an
  /// OpenAI-like API but with different models). In those cases, tiktoken won't
  /// be able to derive the encoding to use, so you have to explicitly specify
  /// it using this field.
  ///
  /// Supported encodings:
  /// - `cl100k_base` (used by gpt-4, gpt-3.5-turbo, text-embedding-ada-002).
  /// - `p50k_base` (used by codex models, text-davinci-002, text-davinci-003).
  /// - `r50k_base` (used by gpt-3 models like davinci).
  ///
  /// For an exhaustive list check:
  /// https://github.com/mvitlov/tiktoken/blob/master/lib/tiktoken.dart
  final String? encoding;

  @override
  String get modelType => 'openai-chat';

  @override
  Future<ChatResult> generate(
    final List<ChatMessage> messages, {
    final ChatOpenAIOptions? options,
  }) async {
    final completion = await _client.createChatCompletion(
      request: _createChatCompletionRequest(messages, options: options),
    );
    return completion.toChatResult();
  }

  @override
  Stream<ChatResult> stream(
    final PromptValue input, {
    final ChatOpenAIOptions? options,
  }) {
    return _client
        .createChatCompletionStream(
          request: _createChatCompletionRequest(
            input.toChatMessages(),
            options: options,
          ),
        )
        .map((final completion) => completion.toChatResult());
  }

  @override
  Stream<ChatResult> streamFromInputStream(
    final Stream<PromptValue> inputStream, {
    final ChatOpenAIOptions? options,
  }) {
    return inputStream.asyncExpand((final input) {
      return stream(input, options: options);
    });
  }

  /// Creates a [CreateChatCompletionRequest] from the given input.
  CreateChatCompletionRequest _createChatCompletionRequest(
    final List<ChatMessage> messages, {
    final ChatOpenAIOptions? options,
  }) {
    final messagesDtos = messages.toChatCompletionMessages();
    final functionsDtos = options?.functions?.toFunctionObjects();
    final functionCall = options?.functionCall?.toChatCompletionFunctionCall();
    final responseFormat =
        options?.responseFormat ?? defaultOptions.responseFormat;
    final responseFormatDto = responseFormat?.toChatCompletionResponseFormat();

    return CreateChatCompletionRequest(
      model: ChatCompletionModel.modelId(
        options?.model ?? defaultOptions.model,
      ),
      messages: messagesDtos,
      functions: functionsDtos,
      functionCall: functionCall,
      frequencyPenalty:
          options?.frequencyPenalty ?? defaultOptions.frequencyPenalty,
      logitBias: options?.logitBias ?? defaultOptions.logitBias,
      maxTokens: options?.maxTokens ?? defaultOptions.maxTokens,
      n: options?.n ?? defaultOptions.n,
      presencePenalty:
          options?.presencePenalty ?? defaultOptions.presencePenalty,
      responseFormat: responseFormatDto,
      seed: options?.seed ?? defaultOptions.seed,
      stop: (options?.stop ?? defaultOptions.stop) != null
          ? ChatCompletionStop.listString(options?.stop ?? defaultOptions.stop!)
          : null,
      temperature: options?.temperature ?? defaultOptions.temperature,
      topP: options?.topP ?? defaultOptions.topP,
      user: options?.user ?? defaultOptions.user,
    );
  }

  /// Tokenizes the given prompt using tiktoken with the encoding used by the
  /// [model]. If an encoding model is specified in [encoding] field, that
  /// encoding is used instead.
  ///
  /// - [promptValue] The prompt to tokenize.
  @override
  Future<List<int>> tokenize(
    final PromptValue promptValue, {
    final ChatOpenAIOptions? options,
  }) async {
    final model = options?.model ?? defaultOptions.model;
    return _getTiktoken(model).encode(promptValue.toString());
  }

  @override
  Future<int> countTokens(final PromptValue promptValue) async {
    final model = defaultOptions.model;
    final tiktoken = _getTiktoken(model);
    final messages = promptValue.toChatMessages();

    // Ref: https://github.com/openai/openai-cookbook/blob/main/examples/How_to_count_tokens_with_tiktoken.ipynb
    final int tokensPerMessage;
    final int tokensPerName;

    switch (model) {
      case 'gpt-3.5-turbo-0613':
      case 'gpt-3.5-turbo-16k-0613':
      case 'gpt-4-0314':
      case 'gpt-4-32k-0314':
      case 'gpt-4-0613':
      case 'gpt-4-32k-0613':
        tokensPerMessage = 3;
        tokensPerName = 1;
      case 'gpt-3.5-turbo-0301':
        // Every message follows <|start|>{role/name}\n{content}<|end|>\n
        tokensPerMessage = 4;
        // If there's a name, the role is omitted
        tokensPerName = -1;
      default:
        if (model.startsWith('gpt-3.5-turbo') || model.startsWith('gpt-4')) {
          // Returning num tokens assuming gpt-3.5-turbo-0613
          tokensPerMessage = 3;
          tokensPerName = 1;
        } else {
          throw UnimplementedError(
            'countTokens not supported for model $model',
          );
        }
    }

    int numTokens = 0;
    for (final message in messages) {
      numTokens += tokensPerMessage;
      numTokens += tiktoken.encode(message.contentAsString).length;
      numTokens += switch (message) {
        final SystemChatMessage _ => tiktoken.encode('system').length,
        final HumanChatMessage _ => tiktoken.encode('user').length,
        final AIChatMessage msg => tiktoken.encode('assistant').length +
            (msg.functionCall != null
                ? tiktoken.encode(msg.functionCall!.name).length +
                    tiktoken
                        .encode(msg.functionCall!.arguments.toString())
                        .length
                : 0),
        final FunctionChatMessage msg =>
          tiktoken.encode(msg.name).length + tokensPerName,
        final CustomChatMessage msg => tiktoken.encode(msg.role).length,
      };
    }

    // every reply is primed with <im_start>assistant
    return numTokens + 3;
  }

  /// Returns the tiktoken model to use for the given model.
  Tiktoken _getTiktoken(final String model) {
    return encoding != null ? getEncoding(encoding!) : encodingForModel(model);
  }
}
