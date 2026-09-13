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

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      wishlist: List<String>.from(map['wishlist'] ?? []),
      ratings: Map<String, double>.from(map['ratings'] ?? {}),
      role: map['role'] ?? "user",
      isBlocked: map['isBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
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
