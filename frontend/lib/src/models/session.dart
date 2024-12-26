class Session {
  final String? accessToken;
  final User? user;

  Session({required this.accessToken, required this.user});

  static fromJson(Map<String, dynamic> json) {
    return Session(
        accessToken: json['accessToken'] as String,
        user: User.fromJson(json['user'] as Map<String, dynamic>));
  }
}

class User {
  final int? id;
  final String? avatar;
  final String? name;

  User({required this.id, required this.avatar, required this.name});

  static fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      avatar: json['avatar'] ?? "" as String,
      name: json['name'] as String,
    );
  }
}
