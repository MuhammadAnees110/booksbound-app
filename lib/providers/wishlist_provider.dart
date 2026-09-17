import 'package:booksbound_app/services/analytics_service.dart';
import 'package:booksbound_app/services/wishlist_service.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:flutter/material.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _service = WishlistService();
  final Set<String> _wishlistIds = {};
  bool _isLoading = false;
  String _error = '';

  Set<String> get items => _wishlistIds;
  int get itemCount => _wishlistIds.length;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadWishlist() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await _service.getWishlist();
    if (result.isSuccess) {
      _wishlistIds.clear();
      _wishlistIds.addAll(result.data ?? []);
      _error = '';
    } else {
      _error = result.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Result<void>> toggleWishlist(String bookId) async {
    Result<void> result;
    if (_wishlistIds.contains(bookId)) {
      _wishlistIds.remove(bookId);
      notifyListeners();
      result = await _service.removeFromWishlist(bookId);
    } else {
      _wishlistIds.add(bookId);
      notifyListeners();
      result = await _service.addToWishlist(bookId);
      await AnalyticsService.logWishlistAdd(bookId);
    }
    if (!result.isSuccess) {
      _error = result.message;
      await loadWishlist();
    }
    notifyListeners();
    return result;
  }

  bool isInWishlist(String bookId) {
    return _wishlistIds.contains(bookId);
  }

  Future<Result<void>> removeFromWishlist(String bookId) async {
    _wishlistIds.remove(bookId);
    notifyListeners();
    final result = await _service.removeFromWishlist(bookId);
    if (!result.isSuccess) {
      _error = result.message;
      await loadWishlist();
    }
    notifyListeners();
    return result;
  }

  void clear() {
    _wishlistIds.clear();
    _isLoading = false;
    _error = '';
    notifyListeners();
  }
}
