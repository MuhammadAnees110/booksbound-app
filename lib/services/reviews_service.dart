import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/review_model.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Result<void>> addReview({
    required String bookId,
    required ReviewModel review,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .update({
        'reviews': FieldValue.arrayUnion([review.toMap()]),
      });
      return Result.created(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<List<ReviewModel>>> getReviews(String bookId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .get();
      final data = doc.data();

      if (data == null || data['reviews'] == null) {
        return Result.success([]);
      }

      final reviews = (data['reviews'] as List)
          .map((e) => ReviewModel.fromMap(e))
          .toList();
      return Result.success(reviews);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> toggleLike({
    required String bookId,
    required ReviewModel review,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Result.error(ResultStatus.unauthorized, 'User not authenticated');
      }

      final bookRef =
          _firestore.collection(AppConstants.booksCollection).doc(bookId);
      final snapshot = await bookRef.get();

      if (!snapshot.exists || snapshot.data()?['reviews'] == null) {
        return Result.error(ResultStatus.notFound, 'Review not found');
      }

      final reviews = List<Map<String, dynamic>>.from(snapshot['reviews']);

      final index = reviews.indexWhere(
        (r) =>
            r['userId'] == review.userId &&
            r['createdAt'] == review.createdAt.toIso8601String(),
      );

      if (index == -1) {
        return Result.error(ResultStatus.notFound, 'Review not found');
      }

      final likedBy = List<String>.from(reviews[index]['likedBy'] ?? []);
      likedBy.contains(currentUser.uid)
          ? likedBy.remove(currentUser.uid)
          : likedBy.add(currentUser.uid);

      reviews[index]['likedBy'] = likedBy;
      await bookRef.update({'reviews': reviews});
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> deleteReview({
    required String bookId,
    required Map<String, dynamic> review,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .update({
        'reviews': FieldValue.arrayRemove([review]),
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
}
