class UserRole {
  final int userId;
  final int roleId;
  final String roleName;

  UserRole({
    required this.userId,
    required this.roleId,
    required this.roleName,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      userId: json['userId'],
      roleId: json['roleId'],
      roleName: json['role']['name'],
    );
  }
}

class User {
  final int id;
  final String name;
  final String? email;
  final String? avatar;
  final List<String> roles;
  final List<String> authorities;

  User({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
    this.roles = const [],
    this.authorities = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      roles: List<String>.from(json['roles'] ?? []),
      authorities: List<String>.from(json['authorities'] ?? []),
    );
  }

  bool get isAdmin => roles.contains('ADMIN');
}
