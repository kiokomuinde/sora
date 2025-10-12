// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

/// A service class to handle Firebase Authentication operations.
/// It provides methods for signing in, signing up, signing out,
/// and a stream to listen to authentication state changes.
class AuthService {
  final FirebaseAuth _auth;

  // Constructor now accepts a FirebaseAuth instance
  AuthService({required FirebaseAuth firebaseAuth}) : _auth = firebaseAuth;

  /// Stream to listen for authentication state changes.
  /// Provides the current [User] object or `null` if no user is signed in.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns the currently logged-in user.
  /// Returns null if no user is signed in.
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  // ADDED METHOD: Required by dashboard_screen.dart for data fetching
  /// Returns the UID of the currently logged-in user.
  /// Returns null if no user is signed in.
  String? getCurrentUserUid() {
    return _auth.currentUser?.uid;
  }

  /// Signs in a user with their email and password.
  /// Throws a [FirebaseAuthException] if authentication fails.
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      // Re-throw the exception to be handled by the UI (e.g., display error message)
      rethrow;
    } catch (e) {
      // Handle other unexpected errors
      throw Exception('An unexpected error occurred during sign-in: $e');
    }
  }

  /// Registers a new user with their email and password.
  /// Throws a [FirebaseAuthException] if registration fails.
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      // Re-throw the exception to be handled by the UI
      rethrow;
    } catch (e) {
      // Handle other unexpected errors
      throw Exception('An unexpected error occurred during sign-up: $e');
    }
  }

  /// Sends a password reset email to the given email address.
  /// Throws a [FirebaseAuthException] if sending the reset email fails.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      // Re-throw the exception to be handled by the UI
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred while sending reset email: $e');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}