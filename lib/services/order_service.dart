import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/order_model.dart';
import 'package:booksbound_app/services/analytics_service.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Result<void>> createOrder(OrderModel order) async {
    try {
      await _db
          .collection(AppConstants.ordersCollection)
          .doc(order.id)
          .set(order.toMap());

      await AnalyticsService.logPurchaseComplete(
        orderId: order.id,
        total: order.totalAmount,
      );
      return Result.created(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Stream<Result<List<OrderModel>>> getUserOrders(String userId) {
    return _db
        .collection(AppConstants.ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        final orders =
            snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
        return Result.success(orders);
      } catch (e) {
        return Result<List<OrderModel>>.error(
            ResultStatus.serverError, 'Failed to parse order data');
      }
    }).handleError((e) {
      if (e is FirebaseException) {
        return ErrorMapper.fromFirestore<List<OrderModel>>(e);
      }
      return ErrorMapper.fromGeneric<List<OrderModel>>(e);
    });
  }

  Stream<Result<List<OrderModel>>> getAllOrders() {
    return _db
        .collection(AppConstants.ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        final orders =
            snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
        return Result.success(orders);
      } catch (e) {
        return Result<List<OrderModel>>.error(
            ResultStatus.serverError, 'Failed to parse order data');
      }
    }).handleError((e) {
      if (e is FirebaseException) {
        return ErrorMapper.fromFirestore<List<OrderModel>>(e);
      }
      return ErrorMapper.fromGeneric<List<OrderModel>>(e);
    });
  }

  Future<Result<void>> updateOrderStatus(String orderId, String status) async {
    try {
      await _db
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .update({'status': status});
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }
}
