import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../bloc/session_cubit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        signInOption: SignInOption.standard,
      );

      try {
        final currentUser = await googleSignIn.signInSilently();
        if (currentUser != null) {
          await googleSignIn.disconnect();
          await googleSignIn.signOut();
        }
      } catch (e) {
        print('Error clearing previous session: $e');
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('User cancelled sign in');
        return;
      }

      final GoogleSignInAuthentication auth = await googleUser.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Could not get ID token');
      }

      print('Got ID token: $idToken');

      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/auth/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'idToken': idToken,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final session = Session(
          accessToken: responseData['accessToken'],
          user: User(
            id: responseData['user']['id'],
            name: responseData['user']['name'],
            avatar: responseData['user']['avatar'],
            roles: List<String>.from(responseData['user']['roles'] ?? []),
            isDeleted: false,
            isBanned: false,
          ),
        );

        if (context.mounted) {
          await context.read<SessionCubit>().signIn(session);
        }
      } else {
        print('Full error response: ${response.body}');
        throw Exception('Lỗi đăng nhập: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thất bại: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return ElevatedButton(
      onPressed: () => _signInWithGoogle(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? const Color(0xFF2C4B6B) : Colors.white,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Image.network(
                'https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.g_mobiledata,
                    color: Colors.blue,
                    size: 20,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Đăng nhập với Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
