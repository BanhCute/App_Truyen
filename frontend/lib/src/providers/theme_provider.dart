import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get theme => _isDarkMode ? _darkTheme : _lightTheme;

  static final _lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey[200],
    primaryColor: const Color(0xFF1B3A57),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[200],
      titleTextStyle: const TextStyle(color: Colors.black),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
  );

  static final _darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color.fromARGB(255, 230, 240, 236),
    primaryColor: Colors.blue,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B3A57),
      titleTextStyle: TextStyle(color: Colors.white),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardColor: Colors.white10,
    hintColor: Colors.grey[300],
    dividerColor: Colors.white24,
    iconTheme: const IconThemeData(color: Colors.white),
    dialogBackgroundColor: const Color(0xFF2C4B6B),
  );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}
