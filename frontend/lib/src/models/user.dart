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
  final String email;
  final String avatar;
  final bool isDeleted;
  final bool isBanned;
  final List<String> roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.isDeleted,
    required this.isBanned,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      isDeleted: json['isDeleted'] as bool? ?? false,
      isBanned: json['isBanned'] as bool? ?? false,
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'isDeleted': isDeleted,
      'isBanned': isBanned,
      'roles': roles,
    };
  }
}
