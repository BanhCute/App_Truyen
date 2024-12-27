import 'user.dart';

class Session {
  final User user;
  final String accessToken;

  Session({
    required this.user,
    required this.accessToken,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      user: User.fromJson(json['user']),
      accessToken: json['accessToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
    };
  }
}

abstract class SessionState {}

class SessionLoading extends SessionState {}

class Unauthenticated extends SessionState {}

class Authenticated extends SessionState {
  final Session session;

  Authenticated(this.session);
}
