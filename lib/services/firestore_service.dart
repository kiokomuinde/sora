// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================================================================
  // 1. CONTACT AND NEWSLETTER MANAGEMENT
  // =========================================================================

  /// Adds a contact message to the 'contactMessages' collection.
  Future<bool> addContactMessage(String name, String email, String message) async {
    try {
      await _firestore.collection('contactMessages').add({
        'name': name,
        'email': email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error sending contact message: $e');
      return false;
    }
  }

  /// Adds a newsletter subscriber's email to Firestore.
  Future<bool> addNewsletterSubscriber(String email) async {
    try {
      await _firestore.collection('newsletterSubscribers').doc(email).set({
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding newsletter subscriber: $e');
      return false;
    }
  }

  // =========================================================================
  // 2. PROPERTY LISTING MANAGEMENT 
  // =========================================================================

  /// Adds a new property listing to the 'properties' collection.
  Future<bool> addProperty(Map<String, dynamic> propertyData) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('Error: User must be logged in to add a property.');
      return false;
    }

    try {
      await _firestore.collection('properties').add({
        ...propertyData,
        'userId': user.uid,
        'status': 'Pending', 
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding property: $e');
      return false;
    }
  }

  /// Gets a real-time stream of all approved properties.
  Stream<QuerySnapshot> getPropertiesStream() {
    return _firestore
        .collection('properties')
        .where('status', isEqualTo: 'Approved')
        .orderBy('timestamp', descending: true)
        .snapshots(); 
  }

  /// Get properties listed by a specific user. (Used in my_listings_screen.dart)
  Stream<QuerySnapshot> getPropertiesForUser(String userId) { 
    if (userId.isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection('properties')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots(); 
  }

  /// Gets a list of approved properties filtered by listing type. (Used in view_property_screen.dart)
  Future<List<Map<String, dynamic>>> getPropertiesByListingType(String listingType) async { 
     try {
      final QuerySnapshot snapshot = await _firestore
          .collection('properties')
          .where('status', isEqualTo: 'Approved')
          .where('listingType', isEqualTo: listingType)
          .orderBy('timestamp', descending: true)
          .limit(10) 
          .get();
      
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print('Error getting properties by listing type "$listingType": $e');
      return [];
    }
  }

  /// Get a single property by its ID.
  Future<Map<String, dynamic>?> getPropertyById(String propertyId) async {
    try {
      final doc = await _firestore.collection('properties').doc(propertyId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      print('Error fetching property by ID: $e');
      return null;
    }
  }
  
  /// Updates the status of a property. (Used in my_listings_screen.dart)
  Future<bool> updatePropertyStatus(String propertyId, String newStatus) async { 
    try {
      await _firestore.collection('properties').doc(propertyId).update({'status': newStatus});
      return true;
    } catch (e) {
      print('Error updating property status: $e');
      return false;
    }
  }

  /// Deletes a property. (Used in my_listings_screen.dart)
  Future<bool> deleteProperty(String propertyId) async { 
    try {
      await _firestore.collection('properties').doc(propertyId).delete();
      return true;
    } catch (e) {
      print('Error deleting property: $e');
      return false;
    }
  }


  // =========================================================================
  // 3. USER PROFILE MANAGEMENT
  // =========================================================================

  /// Sets or updates a user's profile data.
  Future<void> setUserProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      await _firestore.collection('userProfiles').doc(userId).set(
        profileData,
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error setting user profile: $e');
    }
  }

  /// Gets a user's profile data.
  Stream<Map<String, dynamic>?> getUserProfile(String userId) {
    return _firestore.collection('userProfiles').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    });
  }

  // =========================================================================
  // 4. FAVORITES MANAGEMENT (Two positional arguments)
  // =========================================================================

  /// Checks if a property is in the user's favorites.
  Future<bool> isFavorite(String userId, String propertyId) async { 
    if (userId.isEmpty) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(propertyId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  /// Adds a property to the user's favorites.
  Future<void> addFavorite(String userId, String propertyId) async { 
    if (userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(propertyId)
          .set({
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  /// Removes a property from the user's favorites.
  Future<void> removeFavorite(String userId, String propertyId) async { 
    if (userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(propertyId)
          .delete();
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  /// Get a stream of the current user's favorite property IDs.
  Stream<List<String>> getFavoritePropertyIdsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // =========================================================================
  // 5. BLOG MANAGEMENT
  // =========================================================================

  /// Adds a new blog post.
  Future<bool> addBlog(Map<String, dynamic> blogData) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('Error: User must be logged in to add a blog.');
      return false;
    }

    try {
      await _firestore.collection('blogs').add({
        ...blogData,
        'authorId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding blog: $e');
      return false;
    }
  }

  /// Get a stream of all blog posts, ordered by timestamp.
  Stream<QuerySnapshot> getBlogs({int limit = 100}) { 
    return _firestore
        .collection('blogs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }


  /// Get a single blog by its slug or ID.
  Future<Map<String, dynamic>?> getBlogBySlugOrId(String identifier) async {
    try {
      final doc = await _firestore.collection('blogs').doc(identifier).get();
      if (doc.exists) {
        // Ensure the document ID is mapped to 'blogId' for consistency
        return {'blogId': doc.id, ...doc.data() as Map<String, dynamic>}; 
      }
      return null;
    } catch (e) {
      print('Error fetching blog by identifier: $e');
      return null;
    }
  }
  
  /// Get a list of related blog posts (by category), excluding the current one.
  Future<List<Map<String, dynamic>>> getRelatedBlogs(
    String category, 
    String currentBlogId, 
    {int limit = 3}
  ) async {
    if (category.isEmpty || currentBlogId.isEmpty) {
      print('DEBUG: Category or currentBlogId is empty, cannot fetch related blogs.');
      return [];
    }
    
    final String cleanCurrentBlogId = currentBlogId.trim();

    try {
      // **CRITICAL:** This query requires the Composite Index on ['category', 'timestamp']
      final QuerySnapshot querySnapshot = await _firestore
          .collection('blogs')
          .where('category', isEqualTo: category) 
          .orderBy('timestamp', descending: true)
          .limit(limit + 1)
          .get();
      
      final List<Map<String, dynamic>> blogs = querySnapshot.docs.map((doc) {
        return {'blogId': doc.id, ...doc.data() as Map<String, dynamic>}; 
      }).toList();

      // Filter out the currently viewed blog post using its ID
      final relatedBlogs = blogs.where((blog) {
        final docId = blog['blogId'] as String?;
        final isMatch = docId != null && docId.trim() == cleanCurrentBlogId;
        
        return !isMatch; 
      }).toList();
      
      return relatedBlogs.take(limit).toList();

    } catch (e) {
      print('Error fetching related blogs: $e');
      return [];
    }
  }
  
  // =========================================================================
  // 6. DASHBOARD STATS
  // =========================================================================

  /// Gets the count of properties listed by the current user. (For 'My Listings' card)
  Future<int> getMyListingsCount(String userId) async {
    if (userId.isEmpty) return 0;

    try {
      final querySnapshot = await _firestore
          .collection('properties')
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      // FIX: Use ?? 0 to convert nullable int? to non-nullable int
      return querySnapshot.count ?? 0; 
    } catch (e) {
      print('Error fetching my listings count: $e');
      return 0;
    }
  }

  /// Gets the count of favorite properties for the current user. (For 'Favorites' card)
  Future<int> getFavoritesCount(String userId) async {
    if (userId.isEmpty) return 0;

    try {
      // Assumes 'users/{userId}/favorites' subcollection structure based on existing favorite methods.
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .count()
          .get();
      // FIX: Use ?? 0 to convert nullable int? to non-nullable int
      return querySnapshot.count ?? 0; 
    } catch (e) {
      print('Error fetching favorites count: $e');
      return 0;
    }
  }
}