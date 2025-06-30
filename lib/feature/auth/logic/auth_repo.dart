import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepo {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepo({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> signupWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    // Step 1: Create the user with Firebase Auth
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user?.uid;
    if (uid == null) {
      throw Exception("User ID is null after signup.");
    }
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'photoURL': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signupWithGoogle() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in aborted by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Google sign in failed: user is null');

      final userDoc = _firestore.collection('users').doc(user.uid);
      if (!(await userDoc.get()).exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'provider': 'google',
        });
      }
    } catch (e) {
      print("ee ------------ ${e.toString()}");
      rethrow;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.success) {
        final String accessToken = loginResult.accessToken!.tokenString;
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken);

        final userCredential = await _firebaseAuth.signInWithCredential(
          facebookAuthCredential,
        );

        final user = userCredential.user;
        if (user == null)
          throw Exception('Facebook sign in failed: user is null');

        final userData = await FacebookAuth.instance.getUserData();

        final userDoc = _firestore.collection('users').doc(user.uid);
        if (!(await userDoc.get()).exists) {
          await userDoc.set({
            'uid': user.uid,
            'email': user.email ?? userData['email'],
            'name': user.displayName ?? userData['name'] ?? '',
            'photoURL':
                user.photoURL ?? userData['picture']['data']['url'] ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'provider': 'facebook',
          });
        }
      } else {
        throw Exception("Facebook login failed: ${loginResult.status}");
      }
    } catch (e) {
      print("Facebook sign in error: ${e.toString()}");
      rethrow;
    }
  }
}
