import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test1/feature/home/logic/model/comment_model.dart';
import 'package:test1/feature/home/logic/model/likes_model.dart';
import 'package:test1/feature/home/logic/model/post_model.dart';

class HomeRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
 
  HomeRepo({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth, 
    required FirebaseAuth firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // NEW: Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final userSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userSnapshot.exists) {
        return userSnapshot.data();
      }
      return null;
    } catch (e) {
      print('Error getting current user data: $e');
      return null;
    }
  }

  // NEW: Stream current user data for real-time updates
  Stream<Map<String, dynamic>?> getCurrentUserDataStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) => snapshot.exists ? snapshot.data() : null);
  }

  Future<void> addPost({required String content, File? image}) async {
    String? imageUrl;
    final currentUser = _auth.currentUser;
    await _firestore.collection('posts').add({
      'uid': currentUser!.uid,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

   Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((postSnapshots) async {
      List<PostModel> posts = [];

      for (final doc in postSnapshots.docs) {
        final data = doc.data();
        final userId = data['uid'];

        final userSnapshot = await _firestore.collection('users').doc(userId).get();
        final likeDoc = await _firestore
            .collection('posts')
            .doc(doc.id)
            .collection('likes')
            .doc(_auth.currentUser!.uid)
            .get();

        final isLiked = likeDoc.exists;
        final userData = userSnapshot.data();

        if (userData == null) continue;

        posts.add(PostModel(
          postId: doc.id,
          userid: userId,
          userName: userData['name'] ?? 'Unknown',
          userImageUrl: userData['photoURL'] ?? '',
          postDate: (data['createdAt'] as Timestamp).toDate(),
          postContent: data['content'] ?? '',
          postImageUrl: data['imageUrl'] ?? '',
          isLikedByCurrentUser: isLiked
        ));
      }

      return posts;
    });
  }

  // Keep the original method for backward compatibility
  Future<List<PostModel>> getPosts() async {
    final postSnapshots = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    List<PostModel> posts = [];

    for (final doc in postSnapshots.docs) {
      final data = doc.data();
      final userId = data['uid'];

      final userSnapshot = await _firestore.collection('users').doc(userId).get();
      final likeDoc = await _firestore
          .collection('posts')
          .doc(doc.id)
          .collection('likes')
          .doc(_auth.currentUser!.uid)
          .get();

      final isLiked = likeDoc.exists;
      final userData = userSnapshot.data();

      if (userData == null) continue;

      posts.add(PostModel(
        postId: doc.id,
        userid: userId,
        userName: userData['name'] ?? 'Unknown',
        userImageUrl: userData['photoURL'] ?? '',
        postDate: (data['createdAt'] as Timestamp).toDate(),
        postContent: data['content'] ?? '',
        postImageUrl: data['imageUrl'] ?? '',
        isLikedByCurrentUser: isLiked
      ));
    }

    return posts;
  }

  Future<void> likePost(String postId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    // Get current user data
    final userSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();
    final userData = userSnapshot.data();

    final likeDocRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(currentUser.uid);

    final likeDoc = await likeDocRef.get();

    if (likeDoc.exists) {
      // Unlike the post
      await likeDocRef.delete();
    } else {
      // Like the post with user info
      await likeDocRef.set({
        'userId': currentUser.uid,
        'userName': userData?['name'] ?? 'Unknown',
        'userImageUrl': userData?['photoURL'] ?? '',
        'likedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<int> getLikesCount(String postId) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .get();

    return snapshot.docs.length;
  }

  // Stream version for likes count
  Stream<int> getLikesCountStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<bool> getLikeStatusStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // NEW: Get users who liked a post (one-time fetch)
  Future<List<UserLikeModel>> getUsersWhoLiked(String postId) async {
    final likesSnapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .orderBy('likedAt', descending: true)
        .get();

    List<UserLikeModel> likes = [];

    for (final doc in likesSnapshot.docs) {
      final data = doc.data();
      likes.add(UserLikeModel.fromFirestore(data, doc.id));
    }

    return likes;
  }

  // NEW: Stream users who liked a post for real-time updates
  Stream<List<UserLikeModel>> getUsersWhoLikedStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .orderBy('likedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserLikeModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// comment 
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    // Get current user data
    final userSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();
    final userData = userSnapshot.data();

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'postId': postId,
      'userId': currentUser.uid,
      'userName': userData?['name'] ?? 'Unknown',
      'userImageUrl': userData?['photoURL'] ?? '',
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get comments for a post (one-time fetch)
  Future<List<CommentModel>> getComments(String postId) async {
    final commentSnapshots = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .get();

    return commentSnapshots.docs
        .map((doc) => CommentModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Stream comments for real-time updates
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get comments count
  Future<int> getCommentsCount(String postId) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();

    return snapshot.docs.length;
  }

  // Stream for comments count
  Stream<int> getCommentsCountStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

   
}
