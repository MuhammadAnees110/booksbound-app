import 'dart:async';

import 'package:booksbound_app/utils/result.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorMapper {
  static Result<T> fromFirebase<T>(FirebaseException e) {
    if (e is FirebaseAuthException) {
      return fromAuth<T>(e);
    }
    if (e.plugin == 'firebase_storage') {
      return fromStorage<T>(e);
    }
    return fromFirestore<T>(e);
  }

  static Result<T> fromAuth<T>(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Result.error(ResultStatus.badRequest, 'The email address is invalid.');
      case 'user-disabled':
        return Result.error(ResultStatus.forbidden, 'This account has been disabled.');
      case 'user-not-found':
        return Result.error(ResultStatus.notFound, 'No account found with this email.');
      case 'wrong-password':
      case 'invalid-credential':
        return Result.error(ResultStatus.unauthorized, 'Incorrect email or password.');
      case 'email-already-in-use':
        return Result.error(ResultStatus.conflict, 'An account already exists with this email.');
      case 'weak-password':
        return Result.error(ResultStatus.badRequest, 'Password is too weak. Use 8+ chars with numbers and symbols.');
      case 'too-many-requests':
        return Result.error(ResultStatus.rateLimited, 'Too many attempts. Please try again later.');
      case 'network-request-failed':
        return Result.error(ResultStatus.networkError, 'No internet connection.');
      case 'operation-not-allowed':
        return Result.error(ResultStatus.notImplemented, 'This sign-in method is not enabled.');
      case 'requires-recent-login':
        return Result.error(ResultStatus.unauthorized, 'Please log in again before performing this action.');
      default:
        return Result.error(ResultStatus.serverError, e.message ?? 'An authentication error occurred.');
    }
  }

  static Result<T> fromFirestore<T>(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Result.error(ResultStatus.forbidden, 'You do not have permission to perform this action.');
      case 'not-found':
        return Result.error(ResultStatus.notFound, 'The requested item does not exist.');
      case 'already-exists':
        return Result.error(ResultStatus.conflict, 'This item already exists.');
      case 'resource-exhausted':
        return Result.error(ResultStatus.rateLimited, 'Resource limits exceeded. Please try again later.');
      case 'unauthenticated':
        return Result.error(ResultStatus.unauthorized, 'Please log in to perform this action.');
      case 'unavailable':
        return Result.error(ResultStatus.serviceUnavailable, 'Service temporarily unavailable. Try again later.');
      case 'deadline-exceeded':
        return Result.error(ResultStatus.gatewayTimeout, 'Request timed out. Try again.');
      case 'cancelled':
        return Result.error(ResultStatus.badRequest, 'Operation was cancelled.');
      case 'data-loss':
        return Result.error(ResultStatus.serverError, 'Data corruption detected. Contact support.');
      case 'internal':
        return Result.error(ResultStatus.serverError, 'Internal server error. Try again later.');
      case 'invalid-argument':
        return Result.error(ResultStatus.badRequest, 'Invalid request: ${e.message ?? ""}');
      case 'failed-precondition':
        return Result.error(ResultStatus.unprocessable, 'Operation cannot be completed: ${e.message ?? ""}');
      default:
        return Result.error(ResultStatus.serverError, e.message ?? 'A database error occurred.');
    }
  }

  static Result<T> fromStorage<T>(FirebaseException e) {
    switch (e.code) {
      case 'object-not-found':
        return Result.error(ResultStatus.notFound, 'File not found.');
      case 'bucket-not-found':
        return Result.error(ResultStatus.notFound, 'Storage bucket not configured.');
      case 'quota-exceeded':
        return Result.error(ResultStatus.rateLimited, 'Storage quota exceeded.');
      case 'unauthorized':
        return Result.error(ResultStatus.unauthorized, 'You do not have permission to access this file.');
      case 'retry-limit-exceeded':
        return Result.error(ResultStatus.gatewayTimeout, 'Upload failed after multiple retries.');
      case 'invalid-checksum':
        return Result.error(ResultStatus.badRequest, 'File corrupted during upload.');
      case 'canceled':
        return Result.error(ResultStatus.badRequest, 'Operation cancelled.');
      default:
        return Result.error(ResultStatus.serverError, e.message ?? 'A storage error occurred.');
    }
  }

  static Result<T> fromGeneric<T>(dynamic e) {
    if (e is FormatException) {
      return Result.error(ResultStatus.badRequest, 'Invalid format: ${e.message}');
    } else if (e is ArgumentError) {
      return Result.error(ResultStatus.badRequest, 'Invalid argument: ${e.message}');
    } else if (e is StateError) {
      return Result.error(ResultStatus.unprocessable, e.message);
    } else if (e is TimeoutException) {
      return Result.error(ResultStatus.gatewayTimeout, 'Operation timed out.');
    }
    return Result.error(ResultStatus.unknown, e.toString());
  }
}
