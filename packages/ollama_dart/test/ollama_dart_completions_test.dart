import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Ollama Generate Completions API tests', skip: true, () {
    late OllamaClient client;
    const defaultModel = 'llama2:latest';

    setUp(() async {
      client = OllamaClient();
      // Check that the model exists
      final res = await client.listModels();
      expect(
        res.models?.firstWhere((final m) => m.name == defaultModel),
        isNotNull,
      );
    });

    tearDown(() {
      client.endSession();
    });

    test('Test call completions API', () async {
      const testPrompt = 'List the numbers from 1 to 9 in order. '
          'Output ONLY the numbers in one line without any spaces or commas. '
          'NUMBERS:';

      final response = await client.generateCompletion(
        request: const GenerateCompletionRequest(
          model: defaultModel,
          prompt: testPrompt,
        ),
      );
      expect(response.model, defaultModel);
      expect(response.createdAt, isNotNull);
      expect(
        response.response?.replaceAll(RegExp(r'[\s\n]'), ''),
        contains('123456789'),
      );
      expect(response.done, isTrue);
      expect(response.context, isNotEmpty);
      expect(response.totalDuration, greaterThan(0));
      expect(response.loadDuration, greaterThan(0));
      expect(response.promptEvalCount, greaterThan(0));
      expect(response.evalCount, greaterThan(0));
      expect(response.evalDuration, greaterThan(0));
    });

    test('Test call completions streaming API', () async {
      const testPrompt = 'List the numbers from 1 to 9 in order. '
          'Output ONLY the numbers in one line without any spaces or commas. '
          'NUMBERS:';

      final stream = client.generateCompletionStream(
        request: const GenerateCompletionRequest(
          model: defaultModel,
          prompt: testPrompt,
        ),
      );
      String text = '';
      await for (final res in stream) {
        expect(res.response, isNotNull);
        text += res.response!.trim();
      }
      expect(text, contains('123456789'));
    });

    test('Test call completions API with raw mode', () async {
      const testPrompt = '[INST] List the numbers from 1 to 9 in order. '
          'Output ONLY the numbers in one line without any spaces or commas. '
          'NUMBERS: [/INST]';

      final res = await client.generateCompletion(
        request: const GenerateCompletionRequest(
          model: defaultModel,
          prompt: testPrompt,
          raw: true,
        ),
      );
      final generation = res.response?.replaceAll(RegExp(r'[\s\n]'), '');
      expect(generation, contains('123456789'));
    });

    test('Test call completions API with JSON mode', () async {
      const testPrompt = 'List the numbers from 1 to 9 in order. '
          'Respond using JSON.';

      final res = await client.generateCompletion(
        request: const GenerateCompletionRequest(
          model: defaultModel,
          prompt: testPrompt,
          format: ResponseFormat.json,
        ),
      );
      final generation = res.response?.replaceAll(RegExp(r'[\s\n]'), '');
      expect(generation, contains('[1,2,3,4,5,6,7,8,9]'));
    });

    test('Test call completions API with stop sequence', () async {
      const testPrompt = 'List the numbers from 1 to 9 in order. '
          'Output ONLY the numbers in one line without any spaces or commas. '
          'NUMBERS:';

      final res = await client.generateCompletion(
        request: const GenerateCompletionRequest(
          model: defaultModel,
          prompt: testPrompt,
          options: RequestOptions(stop: ['4']),
        ),
      );
      final generation = res.response?.replaceAll(RegExp(r'[\s\n]'), '');
      expect(generation, contains('123'));
      expect(generation, isNot(contains('456789')));
    });
  });
}
