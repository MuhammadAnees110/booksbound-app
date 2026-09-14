import 'package:flutter/services.dart';

/// Centralised haptic feedback utility.
/// All methods are no-ops on devices that don't support haptics.
class Haptics {
  /// Light tap — button presses, navigation, toggles.
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium tap — add to cart, save, wishlist.
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap — destructive confirmations (delete).
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Success pattern — order placed, payment success.
  static Future<void> success() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Warning pattern — validation failure, error.
  static Future<void> warning() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// Selection click — picking from a list, rating stars.
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }
}
