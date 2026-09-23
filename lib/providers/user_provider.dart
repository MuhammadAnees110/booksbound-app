import 'package:booksbound_app/services/user_service.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  bool _isloading = false;
  String _error = "";
  Map<String, dynamic>? _userData;
  String _role = "user";

  bool get isloading => _isloading;
  String get error => _error;
  Map<String, dynamic>? get userData => _userData;
  String get role => _role;
  bool get isAdmin => _role == "admin";

  Future<void> loadRole(String uid) async {
    final result = await _profileService.getUserRole(uid);
    if (result.isSuccess) {
      _role = result.data ?? 'user';
    }
    notifyListeners();
  }

  Future<Result<Map<String, dynamic>?>> getUserData() async {
    _isloading = true;
    _error = "";
    notifyListeners();

    final result = await _profileService.getUserData();
    if (result.isSuccess) {
      _userData = result.data;
      _error = "";
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
    return result;
  }

  Future<Result<String>> changeProfilePicture() async {
    _isloading = true;
    _error = "";
    notifyListeners();

    final result = await _profileService.changeProfilePicture();
    if (result.isSuccess) {
      await getUserData();
      _error = "";
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
    return result;
  }

  Future<Result<void>> saveProfile(String name, String? photoUrl) async {
    _isloading = true;
    _error = "";
    notifyListeners();

    final result = await _profileService.saveProfile(name, photoUrl);
    if (result.isSuccess) {
      await getUserData();
      _error = "";
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
    return result;
  }

  void clear() {
    _isloading = false;
    _error = "";
    _userData = null;
    _role = "user";
    notifyListeners();
  }
}
