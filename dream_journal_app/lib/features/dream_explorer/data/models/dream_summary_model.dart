class DreamSummary {
  final int dreamId;
  final String title;
  final DateTime date;
  final double relevanceScore;

  DreamSummary({
    required this.dreamId,
    required this.title,
    required this.date,
    required this.relevanceScore,
  });

  factory DreamSummary.fromJson(Map<String, dynamic> json) {
    return DreamSummary(
      dreamId: json['dream_id'] as int,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      relevanceScore: (json['relevance_score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dream_id': dreamId,
      'title': title,
      'date': date.toIso8601String(),
      'relevance_score': relevanceScore,
    };
  }
}
