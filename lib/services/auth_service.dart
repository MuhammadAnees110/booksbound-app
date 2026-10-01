import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/user_model.dart';
import 'package:booksbound_app/services/analytics_service.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
      final blocked = await _rejectIfBlocked(credential.user!.uid);
      if (blocked != null) return blocked;
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

  /// Social sign-in with a Google account. Uses Firebase Auth's built-in
  /// provider flow (popup on web, browser tab on Android/iOS), so no extra
  /// plugin is needed. Creates the Firestore profile on first sign-in.
  Future<Result<User?>> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider()..addScope('email');
      final UserCredential credential = kIsWeb
          ? await firebaseAuth.signInWithPopup(provider)
          : await firebaseAuth.signInWithProvider(provider);
      final user = credential.user;
      if (user == null) {
        return Result.error(ResultStatus.unauthorized, 'Google sign-in failed');
      }

      final userDoc = firebaseFirestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid);
      final snapshot = await userDoc.get();
      if (!snapshot.exists) {
        final email = user.email ?? '';
        await userDoc.set(
          UserModel(
            uid: user.uid,
            name: user.displayName ?? email.split('@').first,
            email: email,
            photoUrl: user.photoURL,
            createdAt: DateTime.now(),
            role: 'user',
          ).toJson(),
        );
        await AnalyticsService.logSignUp();
      } else {
        final blocked = await _rejectIfBlocked(user.uid);
        if (blocked != null) return blocked;
      }

      await AnalyticsService.logLogin('google');
      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  /// Signs the user out again if an admin has blocked the account.
  Future<Result<User?>?> _rejectIfBlocked(String uid) async {
    final snapshot = await firebaseFirestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (snapshot.data()?['isBlocked'] == true) {
      await firebaseAuth.signOut();
      return Result.error(
        ResultStatus.forbidden,
        'This account has been blocked by an administrator.',
      );
    }
    return null;
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
      final user = firebaseAuth.currentUser;
      if (user == null) return Result.success(false);
      final blocked = await _rejectIfBlocked(user.uid);
      return Result.success(blocked == null);
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
        return Result.error(
          ResultStatus.unauthorized,
          "User not authenticated",
        );
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
