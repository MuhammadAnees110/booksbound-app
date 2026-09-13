import 'dart:convert';

import 'package:booksbound_app/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  User? get user => FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  Future<Map<String, dynamic>?> getUserData() async {
    final currentUser = user;
    if (currentUser == null) return null;

    final doc = await _firestore.collection(AppConstants.usersCollection).doc(currentUser.uid).get();
    return doc.data();
  }

  Future<void> changeProfilePicture() async {
    final currentUser = user;
    if (currentUser == null) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      await _firestore.collection(AppConstants.usersCollection).doc(currentUser.uid).update({
        'photoUrl': base64Image,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveProfile(String name, String? photoUrl) async {
    final currentUser = user;
    if (currentUser == null) return;

    try {
      await _firestore.collection(AppConstants.usersCollection).doc(currentUser.uid).update({
        'name': name,
        'photoUrl': photoUrl,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getUserAvatar(String userId) async {
    try {
      final doc = await _firestore.collection(AppConstants.usersCollection).doc(userId).get();
      if (doc.exists) {
        return doc.data()?['photoUrl'] ?? '';
      }
    } catch (e) {
      debugPrint("Failed to fetch user avatar: $e");
    }
    return '';
  }

  Future<String> getUserRole(String uid) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    return doc.data()?['role'] ?? 'user';
  }

  Future<void> deleteAccount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('No user logged in');

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

      // 5. Delete user profile picture from Storage (if exists)
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${currentUser.uid}.jpg');
        await storageRef.delete();
      } catch (_) {
        // Picture may not exist, ignore
      }

      // 6. Delete user document from Firestore
      await _firestore.collection(AppConstants.usersCollection).doc(currentUser.uid).delete();
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
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}

class UserService {
  static Future<void> deleteAccount() async {
    final service = ProfileService();
    await service.deleteAccount();
  }
}
