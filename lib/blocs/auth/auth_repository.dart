import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> login(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  Future<String> register(String email, String password, String username) async {
    try {
      // Check if username already exists
      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      
      if (usernameCheck.docs.isNotEmpty) {
        throw Exception("Username already exists");
      }

      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save additional user info to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user!.uid;
    } catch (e) {
      throw Exception("Registration failed: ${e.toString()}");
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Password reset failed: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}