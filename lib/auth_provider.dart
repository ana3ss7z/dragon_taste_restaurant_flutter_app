import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier { //ChangeNotifier, which allows notifying listeners (i.e., UI widgets) when data changes.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = true; // ✅ Added loading flag

  //constructeur
  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      _isLoading = false; // ✅ Done loading when user state is received
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading; // ✅ Added getter


  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found for that email.');
        case 'wrong-password':
          throw Exception('Incorrect password.');
        case 'invalid-email':
          throw Exception('Invalid email address format.');
        case 'user-disabled':
          throw Exception('This user account has been disabled.');
        case 'too-many-requests':
          throw Exception('Too many login attempts. Please try again later.');
        default:
          throw Exception('Authentication failed. ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
  Future<void> signUp(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = cred.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        user = _auth.currentUser;

        // Save user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
          'name': name,
          'email': email,
        });
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already registered.');
        case 'invalid-email':
          throw Exception('Invalid email address format.');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled.');
        case 'weak-password':
          throw Exception('The password provided is too weak.');
        default:
          throw Exception('Failed to sign up: ${e.message}');
      }
    } on FirebaseException catch (e) {
      // Handle Firestore errors
      throw Exception('Failed to save user data: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
