import 'package:booksbound_app/features/admin/manage_users/service/admin_users_service.dart';
import 'package:booksbound_app/models/user_model.dart';
import 'package:flutter/material.dart';

class AdminUsersProvider extends ChangeNotifier {
  final _service = AdminUsersService();

  List<UserModel> _users = [];
  bool _loading = false;
  String _error = '';

  List<UserModel> get users => _users;
  bool get isLoading => _loading;
  String get error => _error;

  Future<void> loadUsers() async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      _users = await _service.fetchUsers();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> toggleBlock(UserModel user) async {
    await _service.toggleBlockUser(user.uid, !user.isBlocked);
    await loadUsers();
  }

  Future<void> makeAdmin(UserModel user) async {
    await _service.changeRole(user.uid, 'admin');
    await loadUsers();
  }

  Future<void> makeUser(UserModel user) async {
    await _service.changeRole(user.uid, 'user');
    await loadUsers();
  }
}
