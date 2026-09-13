import 'package:booksbound_app/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class RatingsService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  Map<String, double> _userRatings = {};

  Future<double> getUserRating(String bookId) async {
    _userRatings = {};
    await loadUserRatings();
    return _userRatings[bookId] ?? 0;
  }

  bool hasRated(String bookId) {
    return _userRatings.containsKey(bookId);
  }

  Future<void> rateBook(String bookId, double rating) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _userRatings[bookId] = rating;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('ratings')
          .doc(bookId)
          .set({'rating': rating, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      debugPrint('Rating error: $e');
    }
  }

  Future<void> loadUserRatings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .collection('ratings')
        .get();

    for (var doc in snapshot.docs) {
      _userRatings[doc.id] = doc['rating'];
    }
  }
}
