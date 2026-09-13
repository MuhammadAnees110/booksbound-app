import 'package:flutter/material.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _service = WishlistService();
  Set<String> _wishlistIds = {};
  bool _isLoading = false;

  Set<String> get items => _wishlistIds;
  int get itemCount => _wishlistIds.length;
  bool get isLoading => _isLoading;

  Future<void> loadWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      final ids = await _service.getWishlist();
      _wishlistIds.clear();
      _wishlistIds.addAll(ids);
    } catch (e) {
      debugPrint("Error loading wishlist: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleWishlist(String bookId) async {
    if (_wishlistIds.contains(bookId)) {
      _wishlistIds.remove(bookId);
      await _service.removeFromWishlist(bookId);
    } else {
      _wishlistIds.add(bookId);
      await _service.addToWishlist(bookId);
    }
    loadWishlist();
    notifyListeners();
  }

  bool isInWishlist(String bookId) {
    return _wishlistIds.contains(bookId);
  }

  Future<void> removeFromWishlist(String bookId) async {
    _wishlistIds.remove(bookId);
    await _service.removeFromWishlist(bookId);
    loadWishlist();
    notifyListeners();
  }

  void clear() {
    _wishlistIds = {};
    _isLoading = false;
    debugPrint("cleared everything");
    notifyListeners();
  }
}
