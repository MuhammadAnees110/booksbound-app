import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Result<List<String>>> getWishlist() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Result.error(ResultStatus.unauthorized, 'User not authenticated');
      }

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) return Result.success([]);

      final data = doc.data();
      final items = List<String>.from(data?['wishlist'] ?? []);
      return Result.success(items);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> addToWishlist(String bookId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Result.error(ResultStatus.unauthorized, 'User not authenticated');
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set({
        'wishlist': FieldValue.arrayUnion([bookId]),
      }, SetOptions(merge: true));
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> removeFromWishlist(String bookId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Result.error(ResultStatus.unauthorized, 'User not authenticated');
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set({
        'wishlist': FieldValue.arrayRemove([bookId]),
      }, SetOptions(merge: true));
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
