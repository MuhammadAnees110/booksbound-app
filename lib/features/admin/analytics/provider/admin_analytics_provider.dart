import 'package:flutter/material.dart';
import '../services/admin_analytics_service.dart';

class AdminAnalyticsProvider extends ChangeNotifier {
  final AdminAnalyticsService _service = AdminAnalyticsService();

  bool _loading = false;
  String _error = '';

  int totalUsers = 0;
  int blockedUsers = 0;
  int totalBooks = 0;
  int bestsellerBooks = 0;
  int totalReviews = 0;

  bool get isLoading => _loading;
  String get error => _error;

  Future<void> loadAnalytics() async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      totalUsers = await _service.totalUsers();
      blockedUsers = await _service.blockedUsers();
      totalBooks = await _service.totalBooks();
      bestsellerBooks = await _service.bestsellerBooks();
      totalReviews = await _service.totalReviews();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
