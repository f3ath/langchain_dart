import 'package:langchain/src/chat_models/chat_models.dart';
import 'package:langchain/src/stores/message/in_memory.dart';
import 'package:test/test.dart';

void main() {
  group('ChatMessageHistory tests', () {
    test('Test addMessage and getMessages', () async {
      final history = ChatMessageHistory();
      final message = ChatMessage.human('This is a test');
      history.addMessage(message);
      expect(await history.getMessages(), [message]);
    });

    test('Test addUserMessage', () async {
      final history = ChatMessageHistory()
        ..addUserMessage('This is a human msg');
      final messages = await history.getMessages();
      expect(messages.first, isA<HumanChatMessage>());
      expect(messages.first.content, 'This is a human msg');
    });

    test('Test addAIChatMessage', () async {
      final history = ChatMessageHistory()
        ..addAIChatMessage('This is an AI msg');
      final messages = await history.getMessages();
      expect(messages.first, isA<AIChatMessage>());
      expect(messages.first.content, 'This is an AI msg');
    });

    test('Test clear', () async {
      final history = ChatMessageHistory();
      final message = ChatMessage.human('This is a test');
      history
        ..addMessage(message)
        ..clear();
      expect(await history.getMessages(), <ChatMessage>[]);
    });
  });
}
