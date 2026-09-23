import 'dart:convert';
import 'dart:io';

import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  User? get user => FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  Future<Result<Map<String, dynamic>?>> getUserData() async {
    try {
      final currentUser = user;
      if (currentUser == null) {
        return Result.error(ResultStatus.unauthorized, 'No user logged in');
      }

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .get();
      return Result.success(doc.data());
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  /// Picks an image from the gallery, compresses it to 512×512 @ 50% quality,
  /// encodes it as Base64, and saves it in Firestore (free — no Storage needed).
  Future<Result<String>> changeProfilePicture() async {
    final currentUser = user;
    if (currentUser == null) {
      return Result.error(ResultStatus.unauthorized, 'No user logged in');
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image == null) return Result.noContent('No image selected');

      // Read bytes and encode as Base64
      final bytes = await File(image.path).readAsBytes();
      final base64String = base64Encode(bytes);

      // Save Base64 string directly to Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .update({'photoUrl': base64String});

      return Result.success(base64String);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> saveProfile(String name, String? photoUrl) async {
    final currentUser = user;
    if (currentUser == null) {
      return Result.error(ResultStatus.unauthorized, 'No user logged in');
    }

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .update({
        'name': name,
        'photoUrl': photoUrl,
      });
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<String>> getUserAvatar(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return Result.success(doc.data()?['photoUrl'] ?? '');
      }
      return Result.success('');
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<String>> getUserRole(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      return Result.success(doc.data()?['role'] ?? 'user');
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> deleteAccount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Result.error(ResultStatus.unauthorized, 'No user logged in');
    }

    try {
      // 1. Delete user's cart items
      final cartSnapshot = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      for (final doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      // 2. Delete user's wishlist items
      final wishlistSnapshot = await _firestore
          .collection('wishlist')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      for (final doc in wishlistSnapshot.docs) {
        await doc.reference.delete();
      }

      // 3. Anonymize user's reviews (keep content, remove userId)
      final reviewsSnapshot = await _firestore
          .collection(AppConstants.reviewsCollection)
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      for (final doc in reviewsSnapshot.docs) {
        await doc.reference.update({
          'userId': 'deleted_user',
          'userName': 'Deleted User',
          'userAvatarUrl': null,
        });
      }

      // 4. Anonymize user's orders (keep for admin records)
      final ordersSnapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      for (final doc in ordersSnapshot.docs) {
        await doc.reference.update({
          'userId': 'deleted_user',
          'shippingAddress': '[deleted]',
        });
      }

      // 5. Delete user document from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .delete();
      if (AppConstants.usersCollection != 'users') {
        try {
          await _firestore.collection('users').doc(currentUser.uid).delete();
        } catch (_) {
          // Ignore if collection doesn't exist
        }
      }

      // 7. Delete Firebase Auth account
      await currentUser.delete();

      // 8. Log analytics event
      await FirebaseAnalytics.instance.logEvent(name: 'account_deleted');
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

class UserService {
  static Future<Result<void>> deleteAccount() async {
    final service = ProfileService();
    return await service.deleteAccount();
  }
}
