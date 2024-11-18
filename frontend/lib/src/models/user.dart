class User {
  final String id;
  final String username;
  final String password;
  final String email;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }
}
