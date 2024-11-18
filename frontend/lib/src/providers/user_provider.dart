import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
  
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
} 