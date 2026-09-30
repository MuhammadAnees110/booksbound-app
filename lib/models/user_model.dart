import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String name;
  final String email;
  final String password;
  final String? photoUrl;
  final DateTime createdAt;
  final List<String> wishlist;
  final Map<String, double> ratings;
  final String role;
  final bool isBlocked;

  UserModel({
    this.uid,
    required this.name,
    required this.email,
    this.password = '',
    this.photoUrl,
    required this.createdAt,
    required this.role,
    this.wishlist = const [],
    this.ratings = const {},
    this.isBlocked = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> map, {String? uid}) =>
      UserModel.fromMap(map, uid: uid);

  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    DateTime parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return UserModel(
      uid: uid ?? (map['uid'] as String?),
      name: (map['name'] as String?) ?? (map['displayName'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      password: (map['password'] as String?) ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: parsedDate,
      wishlist: List<String>.from(map['wishlist'] ?? []),
      ratings: (map['ratings'] as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          ) ??
          {},
      role: (map['role'] as String?) ?? "user",
      isBlocked: (map['isBlocked'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'displayName': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'wishlist': wishlist,
      'ratings': ratings,
      'role': role,
      'isBlocked': isBlocked,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? password,
    String? photoUrl,
    DateTime? createdAt,
    List<String>? wishlist,
    Map<String, double>? ratings,
    String? role,
    bool? isBlocked,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      wishlist: wishlist ?? this.wishlist,
      ratings: ratings ?? this.ratings,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
