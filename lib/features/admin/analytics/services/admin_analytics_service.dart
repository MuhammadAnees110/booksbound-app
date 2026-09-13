import 'package:booksbound_app/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> totalUsers() async {
    final snap = await _firestore.collection(AppConstants.usersCollection).get();
    return snap.docs.length;
  }

  Future<int> blockedUsers() async {
    final snap = await _firestore
        .collection(AppConstants.usersCollection)
        .where('isBlocked', isEqualTo: true)
        .get();
    return snap.docs.length;
  }

  Future<int> totalBooks() async {
    final snap = await _firestore.collection(AppConstants.booksCollection).get();
    return snap.docs.length;
  }

  Future<int> bestsellerBooks() async {
    final snap = await _firestore
        .collection(AppConstants.booksCollection)
        .where('isBestseller', isEqualTo: true)
        .get();
    return snap.docs.length;
  }

  Future<int> totalReviews() async {
    final books = await _firestore.collection(AppConstants.booksCollection).get();

    int count = 0;
    for (var doc in books.docs) {
      final reviews = doc.data()['reviews'];
      if (reviews is List) {
        count += reviews.length;
      }
    }
    return count;
  }
}
