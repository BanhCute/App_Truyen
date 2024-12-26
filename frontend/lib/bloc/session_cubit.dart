import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../src/models/user.dart';

class Session {
  final User? user;

  Session({this.user});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

abstract class SessionState {}

class SessionLoading extends SessionState {}

class Unauthenticated extends SessionState {}

class Authenticated extends SessionState {
  final Session session;

  Authenticated(this.session);
}

class SessionCubit extends Cubit<SessionState> {
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
  final dio = Dio();

  SessionCubit() : super(Unauthenticated()) {
    dio.options.baseUrl = dotenv.env['API_URL'] ?? '';
  }

  Future<void> signInWithGoogle() async {
    emit(SessionLoading());

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final auth = await googleUser.authentication;
        String? idToken = auth.idToken;

        if (idToken != null) {
          final response = await dio.post(
            '/auth/google',
            data: {'idToken': idToken},
          );

          print('API Response: ${response.data}'); // Debug print

          try {
            // Nếu response.data là String, parse nó thành Map
            final Map<String, dynamic> userData = response.data is String
                ? json.decode(response.data)
                : response.data;

            emit(Authenticated(Session.fromJson(userData)));
          } catch (e) {
            print('Error parsing response: $e');
            emit(Unauthenticated());
          }
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (error) {
      print('Error during Google Sign-In: ${error.toString()}');
      emit(Unauthenticated());
    }
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    emit(Unauthenticated());
  }
}
