import 'package:booksbound_app/utils/result.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityGuard {
  static Future<Result<T>> wrap<T>(Future<T> Function() operation) async {
    final connectivity = Connectivity();
    final connections = await connectivity.checkConnectivity();
    if (connections.contains(ConnectivityResult.none)) {
      return Result.error(
        ResultStatus.networkError,
        'You are offline. Please check your internet connection.',
      );
    }
    try {
      final data = await operation();
      return Result.success(data);
    } catch (e) {
      rethrow; // Caller handles with ErrorMapper
    }
  }
}
