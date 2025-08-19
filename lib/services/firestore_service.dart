// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> addProperty(Map<String, dynamic> propertyData) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('User is not authenticated.');
      return false;
    }

    // Add the user's ID and a timestamp to the property data
    propertyData['userId'] = user.uid;
    propertyData['timestamp'] = FieldValue.serverTimestamp();

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

    // Add updated timestamp to the property data
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
      print('Error deleting property from Firestore: $e');
      return false;
    }
  }
}

