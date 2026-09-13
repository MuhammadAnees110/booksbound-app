import 'package:booksbound_app/models/book_model.dart';

class CartItemModel {
  final Book book;
  int quantity;

  CartItemModel({required this.book, this.quantity = 1});

  double get totalPrice => book.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'book': book.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      book: Book.fromMap(map['book'] as Map<String, dynamic>),
      quantity: map['quantity'] as int? ?? 1,
    );
  }
}

typedef CartItem = CartItemModel;
