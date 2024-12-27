import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
export '../models/session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SessionCubit extends Cubit<SessionState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  SessionCubit() : super(Unauthenticated()) {
    checkAuthStatus();
  }

  Future<bool> isTokenValid(String token) async {
    // Luôn trả về true vì chúng ta sẽ tin tưởng token cho đến khi API trả về 401
    return true;
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userData = prefs.getString('user_data');

      if (token != null && userData != null) {
        final user = json.decode(userData);
        emit(Authenticated(Session(
          accessToken: token,
          user: User.fromJson(user),
        )));
      }
    } catch (e) {
      print('Error checking auth status: $e');
      emit(Unauthenticated());
    }
  }

  Future<String?> getValidToken() async {
    if (state is! Authenticated) {
      print('Not authenticated');
      return null;
    }

    final token = (state as Authenticated).session.accessToken;
    print('Getting token from state: $token');

    try {
      // Kiểm tra token có hợp lệ không bằng cách decode JWT
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Invalid token format');
        await signOut();
        return null;
      }

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
      if (DateTime.now().isAfter(expiry)) {
        print('Token has expired');
        await signOut();
        return null;
      }

      return token;
    } catch (e) {
      print('Error validating token: $e');
      await signOut();
      return null;
    }
  }

  Future<void> signIn(Session session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', session.accessToken);
      await prefs.setString('user_data', json.encode(session.user.toJson()));
      print('Saved token to SharedPreferences: ${session.accessToken}');
      emit(Authenticated(session));
    } catch (e) {
      print('Error saving session: $e');
      emit(Unauthenticated());
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user_data');
    } catch (e) {
      print('Error clearing session: $e');
    }
    emit(Unauthenticated());
  }

  Future<void> signInWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final session = Session(
          accessToken: data['accessToken'],
          user: User.fromJson(data['user']),
        );
        await signIn(session);
      } else {
        throw Exception('Failed to sign in with Google');
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      emit(Unauthenticated());
    }
  }

  Future<void> saveSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', session.accessToken);
    print('Saved token: ${session.accessToken}');
    emit(Authenticated(session));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('Cleared token');
    emit(Unauthenticated());
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Loaded token: $token');

    if (token != null && token.isNotEmpty) {
      try {
        // Kiểm tra token có hợp lệ không
        final parts = token.split('.');
        if (parts.length != 3) {
          print('Invalid token format');
          await clearSession();
          return;
        }

        final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

        final expiry =
            DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
        if (DateTime.now().isAfter(expiry)) {
          print('Token has expired');
          await clearSession();
          return;
        }

        // Token hợp lệ, tạo session
        final session = Session(
          accessToken: token,
          user: User.fromJson(payload),
        );
        emit(Authenticated(session));
      } catch (e) {
        print('Error loading session: $e');
        await clearSession();
      }
    } else {
      emit(Unauthenticated());
    }
  }
}
