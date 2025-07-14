// /lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // For ValueNotifier

/// A service class to handle Firebase Authentication operations.
/// It provides methods for signing in, signing up, signing out,
/// and a ValueNotifier to listen to authentication state changes.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // ValueNotifier to notify listeners about the current user.
  // This is a simple way to manage state for demonstration purposes.
  final ValueNotifier<User?> currentUserNotifier = ValueNotifier<User?>(null);

  AuthService() {
    // Listen to Firebase Auth state changes and update the ValueNotifier.
    _firebaseAuth.authStateChanges().listen((User? user) {
      currentUserNotifier.value = user;
    });
  }

  /// Returns the currently logged-in user.
  /// Returns null if no user is signed in.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Signs in a user with their email and password.
  /// Throws a FirebaseAuthException if authentication fails.
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      // Re-throw the exception to be handled by the UI
      rethrow;
    } catch (e) {
      // Handle other potential errors
      throw Exception('An unexpected error occurred during sign-in: $e');
    }
  }

  /// Registers a new user with their email and password.
  /// Throws a FirebaseAuthException if registration fails.
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      // Re-throw the exception to be handled by the UI
      rethrow;
    } catch (e) {
      // Handle other potential errors
      throw Exception('An unexpected error occurred during sign-up: $e');
    }
  }

  /// Sends a password reset email to the given email address.
  /// Throws a FirebaseAuthException if sending the reset email fails.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      // Re-throw the exception to be handled by the UI
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred while sending reset email: $e');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
