import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/user_model.dart';
import 'package:booksbound_app/services/analytics_service.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<Result<void>> register(UserModel data) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: data.email,
        password: data.password,
      );
      await firebaseFirestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseAuth.currentUser?.uid)
          .set(data.copyWith(uid: firebaseAuth.currentUser!.uid).toJson());
      await AnalyticsService.logSignUp();
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> signUp(UserModel data) => register(data);

  Future<Result<User?>> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      await AnalyticsService.logLogin('email');
      return Result.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> logout() async {
    try {
      await firebaseAuth.signOut();
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<bool>> isLoggedIn() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return Result.success(firebaseAuth.currentUser != null);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (firebaseAuth.currentUser == null ||
          firebaseAuth.currentUser!.email == null) {
        return Result.error(ResultStatus.unauthorized, "User not authenticated");
      }

      final credential = EmailAuthProvider.credential(
        email: firebaseAuth.currentUser!.email!,
        password: currentPassword,
      );

      // Re-authenticate
      await firebaseAuth.currentUser!.reauthenticateWithCredential(credential);

      // Update password
      await firebaseAuth.currentUser!.updatePassword(newPassword);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
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
