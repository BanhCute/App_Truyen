import 'user.dart';

class Session {
  final String accessToken;
  final User user;

  Session({
    required this.accessToken,
    required this.user,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      accessToken: json['accessToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'user': user.toJson(),
    };
  }
}
