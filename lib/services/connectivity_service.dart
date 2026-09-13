import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  static bool _isOnlineFromResults(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  /// Check current network connectivity status
  static Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _isOnlineFromResults(results);
    } catch (_) {
      return true; // Fail open
    }
  }

  /// Stream of online/offline boolean status updates
  static Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isOnlineFromResults);
  }
}
