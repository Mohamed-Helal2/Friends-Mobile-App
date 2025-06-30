import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userid;
  final String userName;
  final String userImageUrl;
  final DateTime postDate;
  final String postContent;
  final String? postImageUrl;
  final bool isLikedByCurrentUser;

  PostModel({
    required this.postId,
    required this.userid,
    required this.userName,
    required this.userImageUrl,
    required this.postDate,
    required this.postContent,
    this.postImageUrl,
    required this.isLikedByCurrentUser,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    try {
      return PostModel(
        postId: json['postId'] as String? ?? '',  
        userid: json['uid'] as String? ?? '', 
        userName: json['userName'] as String? ?? 'Unknown',  
        userImageUrl: json['userImageUrl'] as String? ?? '',  
        postDate: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),  
        postContent: json['content'] as String? ?? '',  
        postImageUrl: json['imageUrl'] as String?,  
        isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool? ?? false,  
      );
    } catch (e) {
      print("Error parsing PostModel from JSON: $e, JSON: $json");
      throw Exception('Failed to parse post data: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'uid': userid,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'createdAt': Timestamp.fromDate(postDate),
      'content': postContent, 
      'imageUrl': postImageUrl, 
      'isLikedByCurrentUser': isLikedByCurrentUser,
    };
  }
}