import 'package:flutter_test/flutter_test.dart';
import 'package:dreamidiary/features/dream_explorer/data/models/dream_explorer_response_model.dart';

void main() {
  group('DreamExplorerResponse', () {
    test('fromJson creates valid DreamExplorerResponse', () {
      final json = {
        'answer': 'Based on your dream history...',
        'relevant_dreams': [
          {
            'dream_id': 123,
            'title': 'Flying Dream',
            'date': '2024-01-15T10:30:00',
            'relevance_score': 0.87,
          }
        ],
        'chat_history': [
          {'role': 'user', 'content': 'What do flying dreams mean?'},
          {'role': 'assistant', 'content': 'Based on your dream history...'},
        ],
      };

      final response = DreamExplorerResponse.fromJson(json);

      expect(response.answer, 'Based on your dream history...');
      expect(response.relevantDreams.length, 1);
      expect(response.relevantDreams[0].dreamId, 123);
      expect(response.chatHistory.length, 2);
      expect(response.chatHistory[0].role, 'user');
      expect(response.chatHistory[1].role, 'assistant');
    });

    test('fromJson handles empty lists', () {
      final json = {
        'answer': 'No relevant dreams found.',
        'relevant_dreams': [],
        'chat_history': [],
      };

      final response = DreamExplorerResponse.fromJson(json);

      expect(response.answer, 'No relevant dreams found.');
      expect(response.relevantDreams.isEmpty, true);
      expect(response.chatHistory.isEmpty, true);
    });
  });
}
