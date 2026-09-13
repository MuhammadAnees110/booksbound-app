import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/models/cart_item_model.dart';
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

  void addToCart(Book book) {
    if (_items.containsKey(book.id)) {
      _items[book.id]!.quantity++;
    } else {
      _items[book.id] = CartItem(book: book);
    }
    notifyListeners();
  }

  void removeItem(String bookId) {
    _items.remove(bookId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void increaseQuantity(String bookId) {
    if (!_items.containsKey(bookId)) return;
    _items[bookId]!.quantity += 1;
    notifyListeners();
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
