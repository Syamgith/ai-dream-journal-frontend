class DreamEntry {
  final int? id;
  final String? title;
  final String description;
  final DateTime timestamp;
  final String? interpretation;
  final List<String>? emotions;

  DreamEntry({
    this.id,
    this.title,
    required this.description,
    required this.timestamp,
    this.interpretation,
    this.emotions,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'emotions': emotions,
      'title': title,
      'tags': [], // Empty tags for now
    };
  }

  factory DreamEntry.fromJson(Map<String, dynamic> json) {
    return DreamEntry(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      interpretation: json['interpretation'],
      emotions:
          json['emotions'] != null ? List<String>.from(json['emotions']) : null,
    );
  }
}
