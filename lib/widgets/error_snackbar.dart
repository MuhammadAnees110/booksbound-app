import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:flutter/material.dart';

class ErrorPresenter {
  static void show(BuildContext context, Result result) {
    if (result.isSuccess) return;

    final color = _colorFor(result.status);
    final icon = _iconFor(result.status);
    final title = _titleFor(result.status);
    final duration = _durationFor(result.status);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    result.message,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
      ),
    );

    // Trigger haptics
    if (result.statusCode != null && result.statusCode! >= 500) {
      Haptics.heavy();
    } else if (result.statusCode != null && result.statusCode! >= 400) {
      Haptics.warning();
    }
  }

  static Color _colorFor(ResultStatus s) => switch (s) {
        ResultStatus.networkError => Colors.orange,
        ResultStatus.unauthorized => Colors.blue,
        ResultStatus.forbidden => Colors.red,
        ResultStatus.notFound => Colors.grey,
        ResultStatus.conflict => Colors.amber.shade800,
        ResultStatus.rateLimited => Colors.purple,
        ResultStatus.badRequest => Colors.orange,
        ResultStatus.unprocessable => Colors.orange,
        _ => Colors.red,
      };

  static IconData _iconFor(ResultStatus s) => switch (s) {
        ResultStatus.networkError => Icons.wifi_off,
        ResultStatus.unauthorized => Icons.lock_outline,
        ResultStatus.forbidden => Icons.block,
        ResultStatus.notFound => Icons.search_off,
        ResultStatus.conflict => Icons.warning_amber,
        ResultStatus.rateLimited => Icons.timer,
        ResultStatus.badRequest => Icons.error_outline,
        ResultStatus.unprocessable => Icons.error_outline,
        ResultStatus.serverError => Icons.cloud_off,
        ResultStatus.gatewayTimeout => Icons.timer_off,
        _ => Icons.error,
      };

  static String _titleFor(ResultStatus s) => switch (s) {
        ResultStatus.networkError => 'No Internet',
        ResultStatus.unauthorized => 'Authentication Required',
        ResultStatus.forbidden => 'Access Denied',
        ResultStatus.notFound => 'Not Found',
        ResultStatus.conflict => 'Already Exists',
        ResultStatus.rateLimited => 'Too Many Attempts',
        ResultStatus.badRequest => 'Invalid Input',
        ResultStatus.unprocessable => 'Cannot Complete',
        ResultStatus.serverError => 'Server Error',
        ResultStatus.gatewayTimeout => 'Request Timed Out',
        _ => 'Error',
      };

  static Duration _durationFor(ResultStatus s) {
    if (s == ResultStatus.networkError) return const Duration(seconds: 5);
    if (s == ResultStatus.serverError) return const Duration(seconds: 4);
    return const Duration(seconds: 3);
  }
}
