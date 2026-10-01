import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booksbound_app/models/cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String shippingAddress;
  final String status;
  final DateTime createdAt;
  final String paymentMethod;
  final List<OrderStatusEvent> statusHistory;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.status,
    required this.createdAt,
    this.paymentMethod = 'Cash on Delivery',
    this.statusHistory = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentMethod': paymentMethod,
      'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
    };
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CartItemModel.fromMap)
          .toList(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: data['shippingAddress'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: _parseCreatedAt(data['createdAt']),
      paymentMethod: (data['paymentMethod'] as String?) ?? 'Cash on Delivery',
      statusHistory: (data['statusHistory'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(OrderStatusEvent.fromMap)
          .toList(),
    );
  }

  static DateTime _parseCreatedAt(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// When the order reached [status], or null if it has not (yet) or the
  /// order predates status history.
  DateTime? reachedAt(String status) {
    for (final event in statusHistory.reversed) {
      if (event.status.toLowerCase() == status.toLowerCase()) return event.at;
    }
    if (status.toLowerCase() == 'pending') return createdAt;
    return null;
  }
}

/// One entry in an order's delivery timeline.
class OrderStatusEvent {
  final String status;
  final DateTime at;

  const OrderStatusEvent({required this.status, required this.at});

  factory OrderStatusEvent.fromMap(Map<String, dynamic> map) {
    return OrderStatusEvent(
      status: (map['status'] as String?) ?? '',
      at: OrderModel._parseCreatedAt(map['at']),
    );
  }

  Map<String, dynamic> toMap() => {
    'status': status,
    'at': Timestamp.fromDate(at),
  };
}
