class UserLikeModel {
  final String userId;
  final String userName;
  final String userImageUrl;
  final DateTime likedAt;

  UserLikeModel({
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.likedAt,
  });

  factory UserLikeModel.fromFirestore(Map<String, dynamic> data, String userId) {
    return UserLikeModel(
      userId: userId,
      userName: data['userName'] ?? 'Unknown',
      userImageUrl: data['userImageUrl'] ?? '',
      likedAt: data['likedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'likedAt': likedAt,
    };
  }
}