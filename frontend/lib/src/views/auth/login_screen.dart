import 'package:frontend/bloc/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:frontend/src/views/home/home_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

import '../../../components/google_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
