import 'package:booksbound_app/services/user_service.dart';
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
    _role = await _profileService.getUserRole(uid);
    notifyListeners();
  }

  Future<void> getUserData() async {
    _isloading = true;
    _error = "";
    notifyListeners();

    try {
      _userData = await _profileService.getUserData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> changeProfilePicture() async {
    _isloading = true;
    _error = "";
    notifyListeners();

    try {
      await _profileService.changeProfilePicture();
      await getUserData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile(String name, String? photoUrl) async {
    _isloading = true;
    _error = "";
    notifyListeners();

    try {
      await _profileService.saveProfile(name, photoUrl);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  void clear() {
    _isloading = false;
    _error = "";
    _userData = null;
    _role = "user";
    notifyListeners();
  }
}
