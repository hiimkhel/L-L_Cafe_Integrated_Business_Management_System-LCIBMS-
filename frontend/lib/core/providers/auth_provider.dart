import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  void setUser(User user) {
    _user = user;
    notifyListeners(); 
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}