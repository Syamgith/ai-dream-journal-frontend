import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../models/chat_message_model.dart';
import '../models/dream_explorer_response_model.dart';
import '../models/similar_dreams_response_model.dart';
import '../models/pattern_response_model.dart';
import '../models/compare_dreams_response_model.dart';

class DreamExplorerRepository {
  final ApiClient _apiClient;

  DreamExplorerRepository(this._apiClient);

  /// Ask a question with conversation context
  /// Returns DreamExplorerResponse with answer and relevant dreams
  Future<DreamExplorerResponse> askQuestion(
    String question,
    List<ChatMessage> chatHistory, {
    int topK = 5,
  }) async {
    try {
      debugPrint('DreamExplorerRepository: Asking question: $question');

      final response = await _apiClient.post(
        '/dream-explorer/ask',
        body: {
          'question': question,
          'chat_history': chatHistory.map((msg) => msg.toJson()).toList(),
          'top_k': topK,
        },
        requireAuth: true,
      );

      debugPrint('DreamExplorerRepository: Question response received');
      return DreamExplorerResponse.fromJson(response);
    } catch (e) {
      debugPrint('DreamExplorerRepository: Error asking question: $e');
      rethrow;
    }
  }

  /// Search dreams by semantic meaning with optional filters
  /// Returns SimilarDreamsResponse with matching dreams
  Future<SimilarDreamsResponse> searchDreams(
    String query, {
    int topK = 5,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? emotionTags,
  }) async {
    try {
      debugPrint('DreamExplorerRepository: Searching dreams: $query');

      final body = <String, dynamic>{
        'query': query,
        'top_k': topK,
      };

      if (startDate != null) {
        body['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        body['end_date'] = endDate.toIso8601String();
      }
      if (emotionTags != null && emotionTags.isNotEmpty) {
        body['emotion_tags'] = emotionTags;
      }

      final response = await _apiClient.post(
        '/dream-explorer/search',
        body: body,
        requireAuth: true,
      );

      debugPrint('DreamExplorerRepository: Search response received');
      return SimilarDreamsResponse.fromJson(response);
    } catch (e) {
      debugPrint('DreamExplorerRepository: Error searching dreams: $e');
      rethrow;
    }
  }

  /// Find dreams similar to a specific dream
  /// Returns SimilarDreamsResponse with similar dreams
  Future<SimilarDreamsResponse> findSimilarDreams(
    int dreamId, {
    int topK = 5,
  }) async {
    try {
      debugPrint('DreamExplorerRepository: Finding similar dreams for ID: $dreamId');

      final response = await _apiClient.get(
        '/dream-explorer/similar/$dreamId?top_k=$topK',
        requireAuth: true,
      );

      debugPrint('DreamExplorerRepository: Similar dreams response received');
      return SimilarDreamsResponse.fromJson(response);
    } catch (e) {
      debugPrint('DreamExplorerRepository: Error finding similar dreams: $e');
      rethrow;
    }
  }

  /// Analyze dreams for recurring patterns and themes
  /// Returns PatternResponse with analysis and relevant dreams
  Future<PatternResponse> findPatterns(
    String patternQuery, {
    int topK = 10,
  }) async {
    try {
      debugPrint('DreamExplorerRepository: Finding patterns: $patternQuery');

      final response = await _apiClient.post(
        '/dream-explorer/patterns',
        body: {
          'pattern_query': patternQuery,
          'top_k': topK,
        },
        requireAuth: true,
      );

      debugPrint('DreamExplorerRepository: Pattern analysis response received');
      return PatternResponse.fromJson(response);
    } catch (e) {
      debugPrint('DreamExplorerRepository: Error finding patterns: $e');
      rethrow;
    }
  }

  /// Compare two dreams and get AI insights
  /// Returns CompareDreamsResponse with comparison analysis
  Future<CompareDreamsResponse> compareDreams(
    int dreamId1,
    int dreamId2,
  ) async {
    try {
      debugPrint('DreamExplorerRepository: Comparing dreams $dreamId1 and $dreamId2');

      final response = await _apiClient.post(
        '/dream-explorer/compare',
        body: {
          'dream_id_1': dreamId1,
          'dream_id_2': dreamId2,
        },
        requireAuth: true,
      );

      debugPrint('DreamExplorerRepository: Comparison response received');
      return CompareDreamsResponse.fromJson(response);
    } catch (e) {
      debugPrint('DreamExplorerRepository: Error comparing dreams: $e');
      rethrow;
    }
  }

  /// Check health status of Dream Explorer service
  /// Returns health status map
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      debugPrint('DreamExplorerRepository: Checking health');

      final response = await _apiClient.get(
        '/dream-explorer/health',
        requireAuth: false,
      );

      debugPrint('DreamExplorerRepository: Health check response: $response');
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('DreamExplorerRepository: Error checking health: $e');
      rethrow;
    }
  }
}
