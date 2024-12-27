import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/bloc/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/session.dart';
import 'package:frontend/src/views/home/home_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

import '../../../components/google_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  final bool canPop;

  const LoginScreen({
    super.key,
    this.canPop = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);

      // Tạo instance mới của GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        signInOption: SignInOption.standard,
        clientId:
            '1000163321141-s1t9qk9k2h7qtqj7uc4dh4kc7l6do2hd.apps.googleusercontent.com',
      );

      // Clear cache và đăng xuất
      await googleSignIn.disconnect();
      await googleSignIn.signOut();

      // Đợi một chút để đảm bảo cache đã được xóa
      await Future.delayed(const Duration(milliseconds: 300));

      // Hiển thị dialog chọn tài khoản
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập bị hủy')),
          );
        }
        return;
      }

      // Tiếp tục với flow đăng nhập hiện tại
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final response = await http.post(
        Uri.parse('${dotenv.get('API_URL')}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': googleAuth.idToken,
        }),
      );

      if (response.statusCode == 201) {
        final sessionData = json.decode(response.body);
        if (mounted) {
          context.read<SessionCubit>().signIn(Session.fromJson(sessionData));
        }
      } else {
        throw Exception('Failed to sign in with Google');
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thất bại')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final backgroundColor =
        isDarkMode ? const Color(0xFF1B3A57) : Colors.grey[200];
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return BlocListener<SessionCubit, SessionState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );

          Future.delayed(Duration.zero, () {
            if (state.session.user?.isAdmin == true) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('Chào mừng Admin!!'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Xin chào ${state.session.user?.name}'),
                      const SizedBox(height: 8),
                      const Text('Bạn có quyền:'),
                      const Text('• Đăng truyện mới'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đăng nhập thành công!!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
        }
      },
      child: Scaffold(
        appBar: widget.canPop
            ? AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: backgroundColor,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: textColor,
                    ),
                    onPressed: () {
                      context.read<ThemeProvider>().toggleTheme();
                    },
                  ),
                ],
              )
            : null,
        backgroundColor: backgroundColor,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode ? const Color(0xFF2C4B6B) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.menu_book,
                    size: 100,
                    color: const Color(0xFF1B3A57),
                  ),
                ),
                const SizedBox(height: 30),
                BlocBuilder<SessionCubit, SessionState>(
                  builder: (context, state) {
                    if (state is Authenticated) {
                      return Column(
                        children: [
                          if (state.session.user?.avatar != null)
                            CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  NetworkImage(state.session.user!.avatar!),
                            ),
                          const SizedBox(height: 15),
                          Text(
                            state.session.user?.name ?? '',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Text(
                  'TRUYỆN FULL',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Đọc truyện mọi lúc mọi nơi',
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 60),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: const GoogleButton(),
                ),
                const SizedBox(height: 25),
                Text(
                  'Bằng cách đăng nhập, bạn đồng ý với\nđiều khoản sử dụng của chúng tôi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
