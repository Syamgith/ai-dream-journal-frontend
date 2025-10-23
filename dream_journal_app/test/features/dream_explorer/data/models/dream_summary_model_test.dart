import 'package:flutter_test/flutter_test.dart';
import 'package:dreamidiary/features/dream_explorer/data/models/dream_summary_model.dart';

void main() {
  group('DreamSummary', () {
    test('fromJson creates valid DreamSummary', () {
      final json = {
        'dream_id': 123,
        'title': 'Flying Dream',
        'date': '2024-01-15T10:30:00',
        'relevance_score': 0.87,
      };

      final dreamSummary = DreamSummary.fromJson(json);

      expect(dreamSummary.dreamId, 123);
      expect(dreamSummary.title, 'Flying Dream');
      expect(dreamSummary.date, DateTime.parse('2024-01-15T10:30:00'));
      expect(dreamSummary.relevanceScore, 0.87);
    });

    test('toJson creates valid JSON', () {
      final dreamSummary = DreamSummary(
        dreamId: 123,
        title: 'Flying Dream',
        date: DateTime.parse('2024-01-15T10:30:00'),
        relevanceScore: 0.87,
      );

      final json = dreamSummary.toJson();

      expect(json['dream_id'], 123);
      expect(json['title'], 'Flying Dream');
      expect(json['date'], '2024-01-15T10:30:00.000');
      expect(json['relevance_score'], 0.87);
    });

    test('fromJson and toJson are reversible', () {
      final originalJson = {
        'dream_id': 456,
        'title': 'Ocean Dream',
        'date': '2024-03-10T09:00:00',
        'relevance_score': 0.91,
      };

      final dreamSummary = DreamSummary.fromJson(originalJson);
      final newJson = dreamSummary.toJson();

      expect(newJson['dream_id'], originalJson['dream_id']);
      expect(newJson['title'], originalJson['title']);
      expect(newJson['relevance_score'], originalJson['relevance_score']);
    });
  });
}
