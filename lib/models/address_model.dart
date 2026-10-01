import 'package:cloud_firestore/cloud_firestore.dart';

/// A saved shipping address, stored at `user/{uid}/addresses/{id}`
/// (owner-only by Firestore rules).
class AddressModel {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String postalCode;
  final String country;
  final bool isDefault;

  const AddressModel({
    this.id = '',
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });

  factory AddressModel.fromSnapshot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return AddressModel(
      id: doc.id,
      label: (data['label'] as String?) ?? 'Address',
      fullName: (data['fullName'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      street: (data['street'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      postalCode: (data['postalCode'] as String?) ?? '',
      country: (data['country'] as String?) ?? '',
      isDefault: (data['isDefault'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  /// Single-line form used on orders.
  String get formatted => [
    fullName,
    street,
    '$city $postalCode'.trim(),
    country,
    if (phone.isNotEmpty) 'Phone: $phone',
  ].where((part) => part.trim().isNotEmpty).join(', ');
}
