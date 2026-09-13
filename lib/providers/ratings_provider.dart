import 'package:booksbound_app/services/ratings_service.dart';
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

    try {
      _userRating = await _ratingsService.getUserRating(bookId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  bool hasRated(String bookId) {
    return _ratingsService.hasRated(bookId);
  }

  Future<void> rateBook(String bookId, double rating) async {
    _isloading = true;
    _error = "";
    notifyListeners();

    try {
      await _ratingsService.rateBook(bookId, rating);
      _userRating = rating;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserRatings() async {
    _isloading = true;
    _error = "";
    notifyListeners();

    try {
      await _ratingsService.loadUserRatings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  void clear() {
    _isloading = false;
    _error = "";
    _userRating = 0;
    notifyListeners();
  }
}
