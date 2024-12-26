import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/home/home_screen.dart';
import 'providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Truyen Full',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.theme,
          home: HomeScreen(),
        );
      },
    );
  }
}
