import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/user_model.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUsersService {
  final _firestore = FirebaseFirestore.instance;

  Future<Result<List<UserModel>>> fetchUsers() async {
    try {
      final snapshot =
          await _firestore.collection(AppConstants.usersCollection).get();

      final users =
          snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
      return Result.success(users);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> toggleBlockUser(String? uid, bool block) async {
    if (uid == null) {
      return Result.error(ResultStatus.badRequest, 'User ID cannot be null');
    }
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'isBlocked': block});
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> changeRole(String? uid, String role) async {
    if (uid == null) {
      return Result.error(ResultStatus.badRequest, 'User ID cannot be null');
    }
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'role': role});
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }
}
