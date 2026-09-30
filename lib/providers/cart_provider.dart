import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/models/cart_item_model.dart';
import 'package:booksbound_app/services/analytics_service.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;
  List<CartItemModel> get itemList => _items.values.toList();
  int get itemsCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    for (var item in _items.values) {
      total += item.totalPrice;
    }
    return total;
  }

  double get totalPrice => totalAmount;

  Future<bool> addToCart(Book book, [int quantity = 1]) async {
    final existingItem = _items[book.id];
    final stock = existingItem?.book.stock ?? book.stock;
    final currentQuantity = existingItem?.quantity ?? 0;
    final availableQuantity = stock - currentQuantity;
    if (quantity <= 0 || availableQuantity <= 0) return false;

    final quantityToAdd = quantity < availableQuantity
        ? quantity
        : availableQuantity;
    if (existingItem != null) {
      existingItem.quantity += quantityToAdd;
    } else {
      _items[book.id] = CartItem(book: book, quantity: quantityToAdd);
    }
    notifyListeners();

    await AnalyticsService.logAddToCart(
      bookId: book.id,
      title: book.title,
      price: book.price,
      quantity: quantityToAdd,
    );
    return true;
  }

  void removeItem(String bookId) {
    _items.remove(bookId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool increaseQuantity(String bookId) {
    final item = _items[bookId];
    if (item == null || item.quantity >= item.book.stock) return false;
    item.quantity += 1;
    notifyListeners();
    return true;
  }

  void decreaseQuantity(String bookId) {
    if (!_items.containsKey(bookId)) return;
    if (_items[bookId]!.quantity > 1) {
      _items[bookId]!.quantity -= 1;
    } else {
      _items.remove(bookId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
