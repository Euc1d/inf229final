import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await refreshUserData();
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> refreshUserData() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      _user = await _authService.getUserData(firebaseUser.uid);
      notifyListeners();
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _authService.signUp(email, password, name);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _authService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_user != null) {
      await _authService.updateUserData(_user!.id, data);
      await refreshUserData();
    }
  }
}