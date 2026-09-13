import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// User adds a book to cart
  static Future<void> logAddToCart({
    required String bookId,
    required String title,
    required double price,
    int quantity = 1,
  }) async {
    try {
      await _analytics.logAddToCart(
        value: price * quantity,
        currency: 'USD',
        items: [
          AnalyticsEventItem(
            itemId: bookId,
            itemName: title,
            price: price,
            quantity: quantity,
          ),
        ],
      );
    } catch (_) {}
  }

  /// User begins checkout flow
  static Future<void> logBeginCheckout({
    required double total,
    required int itemCount,
  }) async {
    try {
      await _analytics.logBeginCheckout(
        value: total,
        currency: 'USD',
      );
    } catch (_) {}
  }

  /// User completes a purchase
  static Future<void> logPurchaseComplete({
    required String orderId,
    required double total,
  }) async {
    try {
      await _analytics.logPurchase(
        transactionId: orderId,
        value: total,
        currency: 'USD',
      );
    } catch (_) {}
  }

  /// User searches for a book
  static Future<void> logSearch(String query) async {
    try {
      await _analytics.logSearch(searchTerm: query);
    } catch (_) {}
  }

  /// User views a book detail page
  static Future<void> logViewItem({
    required String bookId,
    required String title,
    required double price,
  }) async {
    try {
      await _analytics.logViewItem(
        currency: 'USD',
        value: price,
        items: [
          AnalyticsEventItem(
            itemId: bookId,
            itemName: title,
            price: price,
          ),
        ],
      );
    } catch (_) {}
  }

  /// User adds a book to wishlist
  static Future<void> logWishlistAdd(String bookId) async {
    try {
      await _analytics.logEvent(
        name: 'add_to_wishlist',
        parameters: {'book_id': bookId},
      );
    } catch (_) {}
  }

  /// User signs up
  static Future<void> logSignUp() async {
    try {
      await _analytics.logSignUp(signUpMethod: 'email');
    } catch (_) {}
  }

  /// User logs in
  static Future<void> logLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (_) {}
  }
}
