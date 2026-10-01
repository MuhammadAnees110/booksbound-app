import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/address_model.dart';
import 'package:booksbound_app/models/payment_method_model.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Saved shipping addresses and payment methods for the signed-in user.
/// Both live in owner-only subcollections under `user/{uid}`.
class AccountDetailsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const addressesCollection = 'addresses';
  static const paymentMethodsCollection = 'payment_methods';

  CollectionReference<Map<String, dynamic>>? _sub(String name) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(name);
  }

  Stream<List<AddressModel>> watchAddresses() {
    final ref = _sub(addressesCollection);
    if (ref == null) return Stream.value(const []);
    return ref.snapshots().map(
      (snap) =>
          snap.docs.map(AddressModel.fromSnapshot).toList()
            ..sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0)),
    );
  }

  Stream<List<PaymentMethodModel>> watchPaymentMethods() {
    final ref = _sub(paymentMethodsCollection);
    if (ref == null) return Stream.value(const []);
    return ref.snapshots().map(
      (snap) =>
          snap.docs.map(PaymentMethodModel.fromSnapshot).toList()
            ..sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0)),
    );
  }

  Future<Result<void>> saveAddress(AddressModel address) => _save(
    addressesCollection,
    address.id,
    address.toMap(),
    address.isDefault,
  );

  Future<Result<void>> savePaymentMethod(PaymentMethodModel method) => _save(
    paymentMethodsCollection,
    method.id,
    method.toMap(),
    method.isDefault,
  );

  Future<Result<void>> deleteAddress(String id) =>
      _delete(addressesCollection, id);

  Future<Result<void>> deletePaymentMethod(String id) =>
      _delete(paymentMethodsCollection, id);

  Future<Result<void>> setDefaultAddress(String id) =>
      _setDefault(addressesCollection, id);

  Future<Result<void>> setDefaultPaymentMethod(String id) =>
      _setDefault(paymentMethodsCollection, id);

  /// Removes every saved address and payment method (used on account deletion).
  Future<void> deleteAll() async {
    for (final name in [addressesCollection, paymentMethodsCollection]) {
      final ref = _sub(name);
      if (ref == null) return;
      final snap = await ref.get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<Result<void>> _save(
    String collection,
    String id,
    Map<String, dynamic> data,
    bool isDefault,
  ) async {
    final ref = _sub(collection);
    if (ref == null) {
      return Result.error(ResultStatus.unauthorized, 'Please log in first');
    }
    try {
      final existing = await ref.get();
      // The first entry becomes the default automatically.
      final makeDefault = isDefault || existing.docs.isEmpty;
      final doc = id.isEmpty ? ref.doc() : ref.doc(id);
      final batch = _db.batch();
      if (makeDefault) {
        for (final other in existing.docs) {
          if (other.id != doc.id && other.data()['isDefault'] == true) {
            batch.update(other.reference, {'isDefault': false});
          }
        }
      }
      batch.set(doc, {...data, 'isDefault': makeDefault});
      await batch.commit();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> _delete(String collection, String id) async {
    final ref = _sub(collection);
    if (ref == null) {
      return Result.error(ResultStatus.unauthorized, 'Please log in first');
    }
    try {
      await ref.doc(id).delete();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> _setDefault(String collection, String id) async {
    final ref = _sub(collection);
    if (ref == null) {
      return Result.error(ResultStatus.unauthorized, 'Please log in first');
    }
    try {
      final snap = await ref.get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isDefault': doc.id == id});
      }
      await batch.commit();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }
}
