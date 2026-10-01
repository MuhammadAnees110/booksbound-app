import 'package:cloud_firestore/cloud_firestore.dart';

/// A saved payment card, stored at `user/{uid}/payment_methods/{id}`
/// (owner-only by Firestore rules).
///
/// Only display details are kept: brand, last four digits, holder name and
/// expiry. The full card number and CVV are never stored.
class PaymentMethodModel {
  final String id;
  final String brand;
  final String last4;
  final String holderName;
  final String expiry;
  final bool isDefault;

  const PaymentMethodModel({
    this.id = '',
    required this.brand,
    required this.last4,
    required this.holderName,
    required this.expiry,
    this.isDefault = false,
  });

  factory PaymentMethodModel.fromSnapshot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return PaymentMethodModel(
      id: doc.id,
      brand: (data['brand'] as String?) ?? 'Card',
      last4: (data['last4'] as String?) ?? '',
      holderName: (data['holderName'] as String?) ?? '',
      expiry: (data['expiry'] as String?) ?? '',
      isDefault: (data['isDefault'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'last4': last4,
      'holderName': holderName,
      'expiry': expiry,
      'isDefault': isDefault,
    };
  }

  String get label => '$brand •••• $last4';

  /// Brand from the card number's leading digits.
  static String detectBrand(String digits) {
    if (digits.startsWith('4')) return 'Visa';
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(digits)) return 'Mastercard';
    if (RegExp(r'^3[47]').hasMatch(digits)) return 'Amex';
    if (digits.startsWith('6')) return 'Discover';
    return 'Card';
  }

  /// Luhn checksum, so typos are caught before saving.
  static bool isValidNumber(String digits) {
    if (digits.length < 13 || digits.length > 19) return false;
    var sum = 0;
    var doubleIt = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var d = int.parse(digits[i]);
      if (doubleIt) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      doubleIt = !doubleIt;
    }
    return sum % 10 == 0;
  }

  /// Accepts MM/YY and rejects expired dates.
  static bool isValidExpiry(String value) {
    final match = RegExp(r'^(0[1-9]|1[0-2])\/(\d{2})$').firstMatch(value);
    if (match == null) return false;
    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    final now = DateTime.now();
    return year > now.year || (year == now.year && month >= now.month);
  }
}
