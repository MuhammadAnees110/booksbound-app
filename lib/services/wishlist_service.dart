import 'package:booksbound_app/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getWishlist() async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (!doc.exists) return [];

    final data = doc.data();
    return List<String>.from(data?['wishlist'] ?? []);
  }

  Future<void> addToWishlist(String bookId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          'wishlist': FieldValue.arrayUnion([bookId]),
        }, SetOptions(merge: true));
  }

  Future<void> removeFromWishlist(String bookId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          'wishlist': FieldValue.arrayRemove([bookId]),
        }, SetOptions(merge: true));
  }
}
