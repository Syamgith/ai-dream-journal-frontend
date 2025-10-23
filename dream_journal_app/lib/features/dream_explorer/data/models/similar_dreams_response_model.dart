import 'dream_summary_model.dart';

class SimilarDreamsResponse {
  final List<DreamSummary> dreams;
  final int totalFound;

  SimilarDreamsResponse({
    required this.dreams,
    required this.totalFound,
  });

  factory SimilarDreamsResponse.fromJson(Map<String, dynamic> json) {
    return SimilarDreamsResponse(
      dreams: (json['dreams'] as List<dynamic>)
          .map((dream) => DreamSummary.fromJson(dream as Map<String, dynamic>))
          .toList(),
      totalFound: json['total_found'] as int,
    );
  }
}
