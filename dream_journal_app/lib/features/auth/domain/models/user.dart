class User {
  final int id;
  final String email;
  final String? name;
  final bool isGuest;

  User({
    required this.id,
    required this.email,
    this.name,
    this.isGuest = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      isGuest: json['isGuest'] ?? false,
    );
  }

  factory User.guest() {
    return User(
      id: 0,
      email: 'guest@example.com',
      name: 'Guest',
      isGuest: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isGuest': isGuest,
    };
  }
}
