class CompareDreamsResponse {
  final String comparison;

  CompareDreamsResponse({
    required this.comparison,
  });

  factory CompareDreamsResponse.fromJson(Map<String, dynamic> json) {
    return CompareDreamsResponse(
      comparison: json['comparison'] as String,
    );
  }
}
