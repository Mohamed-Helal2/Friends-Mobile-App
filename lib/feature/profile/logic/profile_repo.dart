import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:test1/feature/auth/logic/model/user_model.dart';
import 'package:test1/feature/home/logic/model/post_model.dart';

class ProfileRepo {
  final FirebaseFirestore _firestore;

  ProfileRepo({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Firestore: Get User Data
  Future<UserModel?> getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  // Firestore: Get User Posts as Stream
  Stream<List<PostModel>> getUserPosts(String userId) {
    try {
      return _firestore
          .collection('posts')
          .where('uid', isEqualTo: userId)
          .snapshots()
          .asyncMap<List<PostModel>>((snapshot) async {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userData = userDoc.data() ?? {'name': 'Unknown', 'photoURL': ''};

        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['postId'] = doc.id;
          data['userName'] = userData['name'] ?? 'Unknown';
          data['userImageUrl'] = userData['photoURL'] ?? '';
          return PostModel.fromJson(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  // Cloudinary config
  final String _cloudName = 'dluidla5k';
  final String _uploadPreset = 'friends_app';

  // Upload image to Cloudinary
  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(resBody);
        return data['secure_url'];
      } else {
        print("Cloudinary upload failed: $resBody");
        return null;
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e");
      return null;
    }
  }

  Future<void> updateUserProfileImage(String userId, String imageUrl) async {
    await _firestore.collection('users').doc(userId).update({
      'photoURL': imageUrl,
    });
  }

  Future<bool> updateProfilePhoto(String userId, File imageFile) async {
    final imageUrl = await _uploadImageToCloudinary(imageFile);
    if (imageUrl == null) return false;

    await updateUserProfileImage(userId, imageUrl);
    return true;
  }
}
