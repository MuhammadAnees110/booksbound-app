import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/user_model.dart';
import 'package:booksbound_app/services/analytics_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<void> register(UserModel data) async {
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
    } on FirebaseAuthException catch (e) {
      throw e.toString();
    }
  }

  Future<void> signUp(UserModel data) => register(data);

  Future<User?> login({required String email, required String password}) async {
    try {
      final UserCredential credential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      await AnalyticsService.logLogin('email');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found with this email';
        case 'wrong-password':
          throw 'Incorrect Password';
        default:
          throw e.message ?? "Authentication Failed";
      }
    }
  }

  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw e.toString();
    }
  }

  Future<bool> isLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return firebaseAuth.currentUser != null;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (firebaseAuth.currentUser == null ||
        firebaseAuth.currentUser!.email == null) {
      throw Exception("User not authenticated");
    }

    final credential = EmailAuthProvider.credential(
      email: firebaseAuth.currentUser!.email!,
      password: currentPassword,
    );

    // Re-authenticate
    await firebaseAuth.currentUser!.reauthenticateWithCredential(credential);

    // Update password
    await firebaseAuth.currentUser!.updatePassword(newPassword);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found with this email';
        case 'invalid-email':
          throw 'Invalid email address format';
        default:
          throw e.message ?? 'Failed to send password reset email';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
