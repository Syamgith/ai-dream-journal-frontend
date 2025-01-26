class DreamEntry {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? interpretation;
  final List<String> emotions;

  DreamEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.interpretation,
    this.emotions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'date': date.toIso8601String(),
      'emotions': emotions,
      'tags': [], // Empty tags for now
    };
  }

  factory DreamEntry.fromJson(Map<String, dynamic> json) {
    return DreamEntry(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      interpretation: json['interpretation'],
      emotions: List<String>.from(json['emotions'] ?? []),
    );
  }
}
