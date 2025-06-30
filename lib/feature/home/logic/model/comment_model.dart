// First, create the comment model
// comment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String userName;
  final String userImageUrl;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(Map<String, dynamic> data, String commentId) {
    return CommentModel(
      commentId: commentId,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userImageUrl: data['userImageUrl'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}