import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingsService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  Map<String, double> _userRatings = {};

  Future<Result<double>> getUserRating(String bookId) async {
    _userRatings = {};
    final loadResult = await loadUserRatings();
    if (!loadResult.isSuccess) {
      return Result.error(loadResult.status, loadResult.message);
    }
    return Result.success(_userRatings[bookId] ?? 0);
  }

  bool hasRated(String bookId) {
    return _userRatings.containsKey(bookId);
  }

  Future<Result<void>> rateBook(String bookId, double rating) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.error(ResultStatus.unauthorized, 'User not authenticated');
    }

    _userRatings[bookId] = rating;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('ratings')
          .doc(bookId)
          .set({'rating': rating, 'updatedAt': FieldValue.serverTimestamp()});
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> loadUserRatings() async {
    final user = _auth.currentUser;
    if (user == null) return Result.success(null);

    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('ratings')
          .get();

      for (var doc in snapshot.docs) {
        _userRatings[doc.id] = doc['rating'];
      }
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
