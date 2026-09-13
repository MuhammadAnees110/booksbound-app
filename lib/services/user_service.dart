import 'dart:convert';

import 'package:booksbound_app/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
}
