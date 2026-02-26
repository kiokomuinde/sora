// lib/screens/my_favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/services/firestore_service.dart'; 
import 'package:intl/intl.dart'; 

class MyFavoritesScreen extends StatefulWidget {
  final AuthService authService;
  final FirestoreService firestoreService;

  const MyFavoritesScreen({
    Key? key, 
    required this.authService,
    required this.firestoreService, 
  }) : super(key: key);

  @override
  State<MyFavoritesScreen> createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends State<MyFavoritesScreen> {
  late CommonWidgets commonWidgets;
  
  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
  }

  // Helper method for price formatting
  String _formatPrice(dynamic price) {
    if (price == null) return 'Price not listed';

    if (price is String) {
      try {
        final formatter = NumberFormat('#,###', 'en_US');
        final doublePrice = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), ''));
        if (doublePrice != null) {
          return 'KSH ${formatter.format(doublePrice)}';
        }
      } catch (e) {
        // Fall through
      }
      return 'KSH $price';
    }

    if (price is num) {
      final formatter = NumberFormat('#,###', 'en_US');
      return 'KSH ${formatter.format(price)}';
    }

    if (price is Map) {
      final dynamic priceValue = price['amount'] ?? price['value'];
      if (priceValue is num) {
        final formatter = NumberFormat('#,###', 'en_US');
        return 'KSH ${formatter.format(priceValue)}';
      }
    }

    return 'KSH ${price.toString()}';
  }

  // Removes a single favorite property
  void _removeFromFavorites(String propertyId, String propertyTitle) async {
    final user = widget.authService.getCurrentUser();
    if (user == null) return;

    await widget.firestoreService.removeFavorite(user.uid, propertyId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$propertyTitle removed from favorites'),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }

  // Confirms and clears ALL favorites
  void _showClearAllConfirmation(List<Map<String, dynamic>> favoriteProperties) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Favorites'),
          content: Text('Are you sure you want to remove all ${favoriteProperties.length} properties from your favorites?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear All', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(context).pop();
                final user = widget.authService.getCurrentUser();
                if (user == null) return;
                
                int deletedCount = 0;
                for (var prop in favoriteProperties) {
                  final String propertyId = prop['id'] as String? ?? '';
                  if (propertyId.isNotEmpty) {
                    await widget.firestoreService.removeFavorite(user.uid, propertyId);
                    deletedCount++;
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$deletedCount favorites have been cleared.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.getCurrentUser();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    if (user == null) {
      return Scaffold(
        appBar: commonWidgets.buildAppBar(),
        endDrawer: commonWidgets.buildDrawer(),
        body: commonWidgets.buildSignInPromptScreen('/my_favorites'), 
      );
    }

    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 80 : (isMediumScreen ? 60 : 40),
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1E90FF).withOpacity(0.8), const Color(0xFF0A66C2).withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Favorites',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Properties you\'ve saved for later viewing.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Favorites Stream Builder (Dynamic Content)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                vertical: isLargeScreen ? 30 : 20,
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: widget.firestoreService.streamFavoriteProperties(user.uid), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Text('Error loading favorites: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    ));
                  }

                  final favoriteProperties = snapshot.data ?? [];
                  final propertiesCount = favoriteProperties.length;

                  return Column(
                    children: [
                      // Favorites Count and Clear All
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$propertiesCount Favorite Properties',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (propertiesCount > 0)
                            TextButton.icon(
                              onPressed: () {
                                _showClearAllConfirmation(favoriteProperties);
                              },
                              icon: const Icon(Icons.clear_all, color: Colors.red),
                              label: const Text('Clear All', style: TextStyle(color: Colors.red)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Favorites Grid or Empty State
                      propertiesCount == 0
                          ? commonWidgets.buildEmptyState(
                              'No Favorites Yet',
                              'Start browsing properties and add them to your favorites.',
                              () => Navigator.pushNamed(context, '/buy'),
                              'Browse Properties',
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
                                crossAxisSpacing: isLargeScreen ? 30 : 20,
                                mainAxisSpacing: isLargeScreen ? 30 : 20,
                                childAspectRatio: isLargeScreen ? 0.8 : (isMediumScreen ? 0.75 : 0.9),
                              ),
                              itemCount: propertiesCount,
                              itemBuilder: (context, index) {
                                final property = favoriteProperties[index];
                                return _buildFavoritePropertyCard(property);
                              },
                            ),
                    ],
                  );
                },
              ),
            ),

            // Footer
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  // Card implementation matching my_listings_screen data fields
  Widget _buildFavoritePropertyCard(Map<String, dynamic> property) {
    // 1. Core Fields (Always safe with .toString())
    final String propertyId = (property['id'] ?? '0').toString();
    final String title = (property['title'] ?? 'No Title').toString();
    final dynamic price = property['price']; 
    final String listingType = (property['listingType'] ?? 'N/A').toString();

    // 2. Image URL (Use coverImageUrl as primary source)
    final String imageUrl = (property['coverImageUrl'] as String?) ?? 'assets/images/placeholder.jpg';
    bool isNetworkImage = imageUrl.startsWith('http');

    // 3. Location (Handle nested Map)
    String displayLocation = 'Unknown Location';
    final Map<String, dynamic>? locationMap = property['location'] is Map ? property['location'] as Map<String, dynamic> : null;

    if (locationMap != null) {
      final String locality = (locationMap['locality'] ?? '').toString();
      final String town = (locationMap['town'] ?? '').toString();
      final String county = (locationMap['county'] ?? '').toString();
      
      List<String> parts = [locality, town, county].where((p) => p.isNotEmpty).toList();
      displayLocation = parts.join(', ');
    }
    
    // 4. Bedrooms/Bathrooms/Area (Handle nested maps)
    int bedrooms = 0;
    int bathrooms = 0;
    String areaText = 'N/A';
    String areaUnit = '';

    // Check for Residential details
    final Map<String, dynamic>? residentialDetails = property['residentialDetails'] is Map ? property['residentialDetails'] as Map<String, dynamic> : null;
    if (residentialDetails != null) {
      // Safely parse from string field in the map
      bedrooms = int.tryParse(residentialDetails['bedrooms']?.toString() ?? '0') ?? 0;
      bathrooms = int.tryParse(residentialDetails['bathrooms']?.toString() ?? '0') ?? 0;
      areaText = (residentialDetails['size'] ?? 'N/A').toString();
      areaUnit = (residentialDetails['sizeUnit'] ?? '').toString();
    }

    // Check for Airbnb details (overrides/supplements Residential if present)
    final Map<String, dynamic>? airbnbDetails = property['airbnbDetails'] is Map ? property['airbnbDetails'] as Map<String, dynamic> : null;
    if (airbnbDetails != null) {
      // Safely parse from string field in the map
      bedrooms = int.tryParse(airbnbDetails['bedrooms']?.toString() ?? '0') ?? bedrooms;
      bathrooms = int.tryParse(airbnbDetails['bathrooms']?.toString() ?? '0') ?? bathrooms;
    }

    // Fallback/Top-level check (for simple listings or older data)
    bedrooms = int.tryParse(property['bedrooms']?.toString() ?? '0') ?? bedrooms;
    bathrooms = int.tryParse(property['bathrooms']?.toString() ?? '0') ?? bathrooms;
    if (areaText == 'N/A' && property['size'] != null) {
        areaText = property['size'].toString();
        areaUnit = (property['sizeUnit'] ?? 'sqft').toString();
    }

    // Final area string formatting
    String finalAreaDisplay = 'N/A';
    if (areaText != 'N/A') {
        finalAreaDisplay = areaUnit.isNotEmpty ? '$areaText $areaUnit' : areaText;
    }
    
    return GestureDetector(
      onTap: () {
        // === UPDATED: Now uses named routing to seamlessly map to ViewPropertyScreen ===
        Navigator.pushNamed(
          context,
          '/view_property',
          arguments: property,
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Image loading logic
                  isNetworkImage 
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                  
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFromFavorites(propertyId, title), 
                      tooltip: 'Remove from favorites',
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A66C2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        listingType,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            // Use the constructed location string
                            displayLocation,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Show features only if data is available
                    if (bedrooms > 0 || bathrooms > 0 || finalAreaDisplay != 'N/A')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (bedrooms > 0)
                            _buildFeatureIcon(Icons.bed, '$bedrooms Beds'),
                          if (bathrooms > 0)
                            _buildFeatureIcon(Icons.bathtub, '$bathrooms Baths'),
                          if (finalAreaDisplay != 'N/A')
                            _buildFeatureIcon(Icons.square_foot, finalAreaDisplay),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Text(
                      _formatPrice(price),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
  
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      ),
    );
  }
}