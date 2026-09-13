class ReviewModel {
  final String userId;
  final String userName;
  final String comment;
  final DateTime createdAt;
  final List<String> likedBy;

  ReviewModel({
    required this.userId,
    required this.userName,
    required this.comment,
    required this.createdAt,
    required this.likedBy,
  });

  bool isLikedBy(String currentUserId) {
    return likedBy.contains(currentUserId);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'likedBy': likedBy,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      userId: map['userId'],
      userName: map['userName'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
      likedBy: List<String>.from(map['likedBy'] ?? map['likedby'] ?? []),
    );
  }
}
