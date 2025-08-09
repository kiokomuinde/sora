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
}
