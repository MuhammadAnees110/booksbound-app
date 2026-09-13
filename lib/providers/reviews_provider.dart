import 'package:booksbound_app/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booksbound_app/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/reviews_service.dart';

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

    try {
      _reviews = await _reviewsService.getReviews(bookId);
      final userIds = _reviews.map((r) => r.userId).toSet().toList();

      // Parallel batch fetching for avatars to resolve N+1 latency
      final avatarFutures = userIds.map((id) async {
        final avatar = await _userService.getUserAvatar(id);
        return MapEntry(id, avatar);
      });

      final avatarEntries = await Future.wait(avatarFutures);
      _userAvatars = Map.fromEntries(avatarEntries);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReview({
    required String bookId,
    required String comment,
  }) async {
    final user = currentUser;
    if (user == null) {
      _error = "User not authenticated";
      notifyListeners();
      return;
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
      if (data == null) throw Exception("User data not found");

      final review = ReviewModel(
        userId: user.uid,
        userName: data['name'] ?? 'Anonymous',
        comment: comment,
        createdAt: DateTime.now(),
        likedBy: [],
      );

      await _reviewsService.addReview(bookId: bookId, review: review);
      _reviews.insert(0, review);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike({
    required String bookId,
    required ReviewModel review,
  }) async {
    final user = currentUser;
    if (user == null) return;

    final index = _reviews.indexOf(review);
    if (index == -1) return;

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
    await _reviewsService.toggleLike(bookId: bookId, review: review);
  }

  bool isLikedBy(ReviewModel review) {
    final user = currentUser;
    if (user == null) return false;
    return review.isLikedBy(user.uid);
  }

  Future<void> deleteReview({
    required String bookId,
    required Map<String, dynamic> review,
  }) async {
    try {
      await _reviewsService.deleteReview(bookId: bookId, review: review);
      _reviews.removeWhere((r) => r.userId == review['userId']);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clear() {
    _isLoading = false;
    _error = "";
    _reviews = [];
    _userAvatars = {};
    notifyListeners();
  }
}
