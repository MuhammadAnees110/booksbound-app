import 'package:booksbound_app/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review_model.dart';

class ReviewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview({
    required String bookId,
    required ReviewModel review,
  }) async {
    try {
      await _firestore.collection(AppConstants.booksCollection).doc(bookId).update({
        'reviews': FieldValue.arrayUnion([review.toMap()]),
      });
    } catch (e) {
      throw "Failed to add review: $e";
    }
  }

  Future<List<ReviewModel>> getReviews(String bookId) async {
    final doc = await _firestore.collection(AppConstants.booksCollection).doc(bookId).get();
    final data = doc.data();

    if (data == null || data['reviews'] == null) return [];

    return (data['reviews'] as List)
        .map((e) => ReviewModel.fromMap(e))
        .toList();
  }

  Future<void> toggleLike({
    required String bookId,
    required ReviewModel review,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final bookRef = _firestore.collection(AppConstants.booksCollection).doc(bookId);
    final snapshot = await bookRef.get();

    if (!snapshot.exists || snapshot.data()?['reviews'] == null) return;

    final reviews = List<Map<String, dynamic>>.from(snapshot['reviews']);

    final index = reviews.indexWhere(
      (r) =>
          r['userId'] == review.userId &&
          r['createdAt'] == review.createdAt.toIso8601String(),
    );

    if (index == -1) return;

    final likedBy = List<String>.from(reviews[index]['likedBy'] ?? []);
    likedBy.contains(currentUser.uid)
        ? likedBy.remove(currentUser.uid)
        : likedBy.add(currentUser.uid);

    reviews[index]['likedBy'] = likedBy;
    await bookRef.update({'reviews': reviews});
  }

  Future<void> deleteReview({
    required String bookId,
    required Map<String, dynamic> review,
  }) async {
    await _firestore.collection(AppConstants.booksCollection).doc(bookId).update({
      'reviews': FieldValue.arrayRemove([review]),
    });
  }
}
