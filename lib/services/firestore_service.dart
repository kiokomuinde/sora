// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // NEW: Method to add a contact message to Firestore
  Future<bool> addContactMessage(String name, String email, String message) async {
    try {
      await _firestore.collection('contactMessages').add({
        'name': name,
        'email': email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Contact message sent to Firestore successfully!');
      return true;
    } catch (e) {
      print('Error sending contact message: $e');
      return false;
    }
  }

  Future<bool> addProperty(Map<String, dynamic> propertyData) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('User is not authenticated.');
      return false;
    }

    // Add the user's ID and a timestamp to the property data
    propertyData['userId'] = user.uid;
    propertyData['timestamp'] = FieldValue.serverTimestamp();
    // NEW: Add a default status of 'Pending' for new properties
    propertyData['status'] = 'Pending';

    try {
      await _firestore.collection('properties').add(propertyData);
      print('Property added to Firestore successfully!');
      return true;
    } catch (e) {
      print('Error adding property to Firestore: $e');
      return false;
    }
  }

  // NEW: Method to update an existing property in Firestore
  Future<bool> updateProperty(String propertyId, Map<String, dynamic> propertyData) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('User is not authenticated.');
      return false;
    }

    // NEW: Add a timestamp to the property data
    propertyData['updatedAt'] = FieldValue.serverTimestamp();

    try {
      await _firestore.collection('properties').doc(propertyId).update(propertyData);
      print('Property updated in Firestore successfully!');
      return true;
    } catch (e) {
      print('Error updating property in Firestore: $e');
      return false;
    }
  }

  // NEW: Method to update a single property field
  Future<bool> updatePropertyStatus(String propertyId, String newStatus) async {
    try {
      await _firestore.collection('properties').doc(propertyId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Property status updated to $newStatus successfully!');
      return true;
    } catch (e) {
      print('Error updating property status: $e');
      return false;
    }
  }

  // Method to get a real-time stream of properties for a specific user
  Stream<QuerySnapshot> getPropertiesForUser(String userId) {
    return _firestore
        .collection('properties')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Method to delete a property from Firestore
  Future<bool> deleteProperty(String propertyId) async {
    try {
      await _firestore.collection('properties').doc(propertyId).delete();
      print('Property deleted from Firestore successfully!');
      return true;
    } catch (e) {
      print('Error deleting property: $e');
      return false;
    }
  }

  /// Adds a property to a user's favorites list.
  Future<void> addFavorite(String userId, String propertyId) async {
    try {
      await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .doc(propertyId)
          .set({'addedAt': FieldValue.serverTimestamp()});
      print('Property $propertyId added to favorites for user $userId');
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  /// Removes a property from a user's favorites list.
  Future<void> removeFavorite(String userId, String propertyId) async {
    try {
      await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .doc(propertyId)
          .delete();
      print('Property $propertyId removed from favorites for user $userId');
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  /// Checks if a property is in a user's favorites list.
  Future<bool> isFavorite(String userId, String propertyId) async {
    try {
      final docSnapshot = await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .doc(propertyId)
          .get();
      return docSnapshot.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // NEW: Method to add a new blog post to Firestore
  Future<bool> addBlog(Map<String, dynamic> blogData) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('User is not authenticated.');
      return false;
    }

    // Add the user's ID and a timestamp to the blog data
    blogData['userId'] = user.uid;
    blogData['timestamp'] = FieldValue.serverTimestamp();

    try {
      await _firestore.collection('blogs').add(blogData);
      print('Blog post added to Firestore successfully!');
      return true;
    } catch (e) {
      print('Error adding blog post to Firestore: $e');
      return false;
    }
  }

  // NEW: Method to get a real-time stream of all blog posts
  Stream<QuerySnapshot> getBlogs() {
    return _firestore.collection('blogs').snapshots();
  }

  // CORRECTED: Method to add a newsletter subscriber's email to Firestore
  Future<bool> addNewsletterSubscriber(String email) async {
    try {
      await _firestore.collection('newsletterSubscribers').add({
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Newsletter email added to Firestore successfully!');
      return true;
    } catch (e) {
      print('Error adding newsletter email: $e');
      return false;
    }
  }
}