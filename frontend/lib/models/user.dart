class User {
  final int id;
  final String name;
  final String? avatar;
  final List<String> roles;
  final bool isDeleted;
  final bool isBanned;

  User({
    required this.id,
    required this.name,
    this.avatar,
    required this.roles,
    required this.isDeleted,
    required this.isBanned,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      roles: List<String>.from(json['roles'] ?? []),
      isDeleted: json['isDeleted'] ?? false,
      isBanned: json['isBanned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'roles': roles,
      'isDeleted': isDeleted,
      'isBanned': isBanned,
    };
  }

  bool get isAdmin => roles.contains('ADMIN');
}
