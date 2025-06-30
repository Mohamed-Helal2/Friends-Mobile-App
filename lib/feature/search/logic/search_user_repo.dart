import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test1/feature/auth/logic/model/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<UserModel>> getAllUsers() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .where((user) => user.id != currentUserId)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      
      if (query.isEmpty) {
        return await getAllUsers();
      }

      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .get();

      final allUsers = querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .where((user) => user.id != currentUserId)
          .toList();

      // Filter by search query locally
      return allUsers
          .where((user) => 
              user.name.toLowerCase().contains(query.toLowerCase()))
              
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }}