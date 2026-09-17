import 'package:booksbound_app/services/ratings_service.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:flutter/material.dart';

class RatingsProvider extends ChangeNotifier {
  bool _isloading = false;
  String _error = '';
  final RatingsService _ratingsService = RatingsService();
  double _userRating = 0;

  bool get isloading => _isloading;
  String get error => _error;
  double get userRating => _userRating;

  Future<void> getUserRating(String bookId) async {
    _isloading = true;
    _error = "";
    notifyListeners();

    final result = await _ratingsService.getUserRating(bookId);
    if (result.isSuccess) {
      _userRating = result.data ?? 0;
      _error = "";
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
  }

  bool hasRated(String bookId) {
    return _ratingsService.hasRated(bookId);
  }

  Future<Result<void>> rateBook(String bookId, double rating) async {
    _isloading = true;
    _error = "";
    notifyListeners();

    final result = await _ratingsService.rateBook(bookId, rating);
    if (result.isSuccess) {
      _userRating = rating;
      _error = "";
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
    return result;
  }

  Future<void> loadUserRatings() async {
    _isloading = true;
    _error = "";
    notifyListeners();

    final result = await _ratingsService.loadUserRatings();
    if (result.isSuccess) {
      _error = "";
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
  }

  void clear() {
    _isloading = false;
    _error = "";
    _userRating = 0;
    notifyListeners();
  }
}
