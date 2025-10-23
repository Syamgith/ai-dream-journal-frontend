import 'package:flutter_test/flutter_test.dart';
import 'package:dreamidiary/features/dream_explorer/data/models/pattern_response_model.dart';

void main() {
  group('PatternResponse', () {
    test('fromJson creates valid PatternResponse', () {
      final json = {
        'pattern_analysis': 'Analyzing your dreams, I found...',
        'relevant_dreams': [
          {
            'dream_id': 156,
            'title': 'Running From Shadow',
            'date': '2024-04-05T03:00:00',
            'relevance_score': 0.94,
          }
        ],
      };

      final response = PatternResponse.fromJson(json);

      expect(response.patternAnalysis, 'Analyzing your dreams, I found...');
      expect(response.relevantDreams.length, 1);
      expect(response.relevantDreams[0].dreamId, 156);
      expect(response.relevantDreams[0].title, 'Running From Shadow');
    });

    test('fromJson handles empty relevant dreams', () {
      final json = {
        'pattern_analysis': 'No patterns found.',
        'relevant_dreams': [],
      };

      final response = PatternResponse.fromJson(json);

      expect(response.patternAnalysis, 'No patterns found.');
      expect(response.relevantDreams.isEmpty, true);
    });
  });
}
