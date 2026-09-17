import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/review_model.dart';
import 'package:booksbound_app/services/reviews_service.dart';
import 'package:booksbound_app/services/user_service.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewsProvider extends ChangeNotifier {
  final ReviewsService _reviewsService = ReviewsService();
  final ProfileService _userService = ProfileService();

  bool _isLoading = false;
  String _error = '';
  List<ReviewModel> _reviews = [];
  Map<String, String> _userAvatars = {};

  bool get isLoading => _isLoading;
  String get error => _error;
  List<ReviewModel> get reviews => _reviews;
  Map<String, String> get userAvatars => _userAvatars;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> loadReviews(String bookId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await _reviewsService.getReviews(bookId);
    if (result.isSuccess) {
      _reviews = result.data ?? [];
      final userIds = _reviews.map((r) => r.userId).toSet().toList();

      // Parallel batch fetching for avatars to resolve N+1 latency
      final avatarFutures = userIds.map((id) async {
        final avatarResult = await _userService.getUserAvatar(id);
        return MapEntry(id, avatarResult.data ?? '');
      });

      final avatarEntries = await Future.wait(avatarFutures);
      _userAvatars = Map.fromEntries(avatarEntries);
      _error = '';
    } else {
      _error = result.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Result<void>> addReview({
    required String bookId,
    required String comment,
  }) async {
    final user = currentUser;
    if (user == null) {
      _error = "User not authenticated";
      notifyListeners();
      return Result.error(ResultStatus.unauthorized, "User not authenticated");
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      final data = snapshot.data();
      if (data == null) {
        final res =
            Result<void>.error(ResultStatus.notFound, "User data not found");
        _error = res.message;
        _isLoading = false;
        notifyListeners();
        return res;
      }

      final review = ReviewModel(
        userId: user.uid,
        userName: data['name'] ?? 'Anonymous',
        comment: comment,
        createdAt: DateTime.now(),
        likedBy: [],
      );

      final result =
          await _reviewsService.addReview(bookId: bookId, review: review);
      if (result.isSuccess) {
        _reviews.insert(0, review);
        _error = '';
      } else {
        _error = result.message;
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      final res = ErrorMapper.fromGeneric<void>(e);
      _error = res.message;
      _isLoading = false;
      notifyListeners();
      return res;
    }
  }

  Future<Result<void>> toggleLike({
    required String bookId,
    required ReviewModel review,
  }) async {
    final user = currentUser;
    if (user == null) {
      return Result.error(ResultStatus.unauthorized, 'User not authenticated');
    }

    final index = _reviews.indexOf(review);
    if (index == -1) {
      return Result.error(ResultStatus.notFound, 'Review not found');
    }

    final likedBy = List<String>.from(review.likedBy);
    likedBy.contains(user.uid)
        ? likedBy.remove(user.uid)
        : likedBy.add(user.uid);

    _reviews[index] = ReviewModel(
      userId: review.userId,
      userName: review.userName,
      comment: review.comment,
      createdAt: review.createdAt,
      likedBy: likedBy,
    );

    notifyListeners();
    final result =
        await _reviewsService.toggleLike(bookId: bookId, review: review);
    if (!result.isSuccess) {
      _error = result.message;
      _reviews[index] = review;
      notifyListeners();
    }
    return result;
  }

  bool isLikedBy(ReviewModel review) {
    final user = currentUser;
    if (user == null) return false;
    return review.isLikedBy(user.uid);
  }

  Future<Result<void>> deleteReview({
    required String bookId,
    required Map<String, dynamic> review,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result =
        await _reviewsService.deleteReview(bookId: bookId, review: review);
    if (result.isSuccess) {
      _reviews.removeWhere((r) => r.userId == review['userId']);
      _error = '';
    } else {
      _error = result.message;
    }
    _isLoading = false;
    notifyListeners();
    return result;
  }

  void clear() {
    _isLoading = false;
    _error = "";
    _reviews = [];
    _userAvatars = {};
    notifyListeners();
  }
}
