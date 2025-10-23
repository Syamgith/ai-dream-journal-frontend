import 'dream_summary_model.dart';

class PatternResponse {
  final String patternAnalysis;
  final List<DreamSummary> relevantDreams;

  PatternResponse({
    required this.patternAnalysis,
    required this.relevantDreams,
  });

  factory PatternResponse.fromJson(Map<String, dynamic> json) {
    return PatternResponse(
      patternAnalysis: json['pattern_analysis'] as String,
      relevantDreams: (json['relevant_dreams'] as List<dynamic>)
          .map((dream) => DreamSummary.fromJson(dream as Map<String, dynamic>))
          .toList(),
    );
  }
}
