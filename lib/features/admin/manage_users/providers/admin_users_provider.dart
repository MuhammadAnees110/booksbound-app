import 'package:booksbound_app/features/admin/manage_users/services/admin_users_service.dart';
import 'package:booksbound_app/models/user_model.dart';
import 'package:booksbound_app/utils/result.dart';
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

    final result = await _service.fetchUsers();
    if (result.isSuccess) {
      _users = result.data ?? [];
      _error = '';
    } else {
      _error = result.message;
    }

    _loading = false;
    notifyListeners();
  }

  Future<Result<void>> toggleBlock(UserModel user) async {
    final result = await _service.toggleBlockUser(user.uid, !user.isBlocked);
    if (result.isSuccess) {
      await loadUsers();
    } else {
      _error = result.message;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> makeAdmin(UserModel user) async {
    final result = await _service.changeRole(user.uid, 'admin');
    if (result.isSuccess) {
      await loadUsers();
    } else {
      _error = result.message;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> makeUser(UserModel user) async {
    final result = await _service.changeRole(user.uid, 'user');
    if (result.isSuccess) {
      await loadUsers();
    } else {
      _error = result.message;
      notifyListeners();
    }
    return result;
  }
}
