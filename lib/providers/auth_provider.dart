import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  Future<void> signInWithGoogle() async {
    // Simulate Google Sign In
    await Future.delayed(const Duration(seconds: 1));
    
    _isAuthenticated = true;
    _userId = 'sample_user_id';
    _userEmail = 'user@example.com';
    _userName = 'Sample User';
    
    notifyListeners();
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    _userName = null;
    
    notifyListeners();
  }
} 