import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/order_model.dart';
import 'package:booksbound_app/services/analytics_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createOrder(OrderModel order) async {
    await _db
        .collection(AppConstants.ordersCollection)
        .doc(order.id)
        .set(order.toMap());

    await AnalyticsService.logPurchaseComplete(
      orderId: order.id,
      total: order.totalAmount,
    );
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _db
        .collection(AppConstants.ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList());
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection(AppConstants.ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({'status': status});
  }
}
