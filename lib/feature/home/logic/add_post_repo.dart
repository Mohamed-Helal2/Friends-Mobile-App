import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AddPostRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AddPostRepo({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final String _cloudName = 'dluidla5k';
  final String _uploadPreset = 'friends_app';

  Future<void> addPost({required String content, File? image}) async {
    String? imageUrl;

    if (image != null) {
      imageUrl = await _uploadImageToCloudinary(image);
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    await _firestore.collection('posts').add({
      'uid': currentUser.uid,
      'content': content,
      'imageUrl': imageUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(resBody);
        return data['secure_url'];
      } else {
        print("Cloudinary upload failed: ${response.statusCode}");
        print(resBody);
        return null;
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }
}
