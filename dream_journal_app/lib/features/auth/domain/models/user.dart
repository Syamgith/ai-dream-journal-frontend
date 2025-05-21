class User {
  final int id;
  final String email;
  final String? name;
  final bool isGuest;
  final DateTime? dateCreated;

  User({
    required this.id,
    required this.email,
    this.name,
    this.isGuest = false,
    this.dateCreated,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      isGuest: json['isGuest'] ?? false,
      dateCreated: json['date_created'] != null
          ? DateTime.parse(json['date_created'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isGuest': isGuest,
      'date_created': dateCreated?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
    bool? isGuest,
    DateTime? dateCreated,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isGuest: isGuest ?? this.isGuest,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
