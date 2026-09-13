import 'package:booksbound_app/models/user_model.dart';
import 'package:booksbound_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAuthProvider extends ChangeNotifier {
  bool _isloading = false;
  String _error = "";
  final AuthService _authService = AuthService();

  bool get isloading => _isloading;
  String get error => _error;
  User? get user => FirebaseAuth.instance.currentUser;

  Future<void> registerUser(UserModel userData) async {
    try {
      _isloading = true;
      _error = "";
      notifyListeners();

      await _authService.register(userData);

      _isloading = false;
      _error = "";
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isloading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    _isloading = true;
    _error = "";
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      clear();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isloading = true;
    _error = "";
    notifyListeners();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  void clear() {
    _isloading = false;
    _error = "";
    notifyListeners();
  }
}
