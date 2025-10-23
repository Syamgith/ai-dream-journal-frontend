import 'package:flutter_test/flutter_test.dart';
import 'package:dreamidiary/features/dream_explorer/data/models/chat_message_model.dart';

void main() {
  group('ChatMessage', () {
    test('fromJson creates valid ChatMessage', () {
      final json = {
        'role': 'user',
        'content': 'What do my flying dreams mean?',
      };

      final chatMessage = ChatMessage.fromJson(json);

      expect(chatMessage.role, 'user');
      expect(chatMessage.content, 'What do my flying dreams mean?');
      expect(chatMessage.isUser, true);
      expect(chatMessage.isAssistant, false);
    });

    test('toJson creates valid JSON', () {
      final chatMessage = ChatMessage(
        role: 'assistant',
        content: 'Based on your dreams...',
      );

      final json = chatMessage.toJson();

      expect(json['role'], 'assistant');
      expect(json['content'], 'Based on your dreams...');
    });

    test('isUser returns true for user role', () {
      final userMessage = ChatMessage(role: 'user', content: 'Hello');
      expect(userMessage.isUser, true);
      expect(userMessage.isAssistant, false);
    });

    test('isAssistant returns true for assistant role', () {
      final assistantMessage = ChatMessage(role: 'assistant', content: 'Hi');
      expect(assistantMessage.isAssistant, true);
      expect(assistantMessage.isUser, false);
    });
  });
}
