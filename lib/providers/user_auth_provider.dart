import 'package:booksbound_app/models/user_model.dart';
import 'package:booksbound_app/services/auth_service.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAuthProvider extends ChangeNotifier {
  bool _isloading = false;
  String _error = "";
  final AuthService _authService = AuthService();

  bool get isloading => _isloading;
  String get error => _error;
  User? get user => FirebaseAuth.instance.currentUser;

  Future<Result<void>> registerUser(UserModel userData) async {
    _isloading = true;
    _error = "";
    notifyListeners();

    final result = await _authService.register(userData);
    if (result.isSuccess) {
      _error = "";
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
    return result;
  }

  Future<Result<User?>> loginUser({
    required String email,
    required String password,
  }) async {
    _isloading = true;
    _error = "";
    notifyListeners();

    final result = await _authService.login(email: email, password: password);
    if (result.isSuccess) {
      _error = "";
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
    return result;
  }

  Future<Result<void>> logout() async {
    final result = await _authService.logout();
    if (result.isSuccess) {
      clear();
    } else {
      _error = result.message;
      notifyListeners();
    }
    return result;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isloading = true;
    _error = "";
    notifyListeners();

    final result = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (result.isSuccess) {
      _error = "";
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
    return result.isSuccess;
  }

  void clear() {
    _isloading = false;
    _error = "";
    notifyListeners();
  }
}
