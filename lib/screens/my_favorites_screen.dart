// lib/screens/my_favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/screens/property_detail_screen.dart';

class MyFavoritesScreen extends StatefulWidget {
  final AuthService authService;

  const MyFavoritesScreen({Key? key, required this.authService}) : super(key: key);

  @override
  State<MyFavoritesScreen> createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends State<MyFavoritesScreen> {
  late CommonWidgets commonWidgets;

  // Sample favorite properties data
  List<Map<String, dynamic>> _favoriteProperties = [
    {
      'title': 'Luxury Villa in Westlands',
      'location': 'Westlands, Nairobi',
      'price': 'KSH 45,000,000',
      'bedrooms': 4,
      'bathrooms': 3,
      'area': '3500',
      'listingType': 'Buy',
      'type': 'Villa',
      'description': 'Beautiful luxury villa with modern amenities',
      'images': ['assets/images/property1.jpg'],
      'dateAdded': '2024-01-20',
    },
    {
      'title': 'Modern Apartment in Kilimani',
      'location': 'Kilimani, Nairobi',
      'price': 'KSH 120,000/month',
      'bedrooms': 3,
      'bathrooms': 2,
      'area': '1800',
      'listingType': 'Rent',
      'type': 'Apartment',
      'description': 'Spacious modern apartment with great amenities',
      'images': ['assets/images/property2.jpg'],
      'dateAdded': '2024-01-18',
    },
    {
      'title': 'Commercial Space in CBD',
      'location': 'CBD, Nairobi',
      'price': 'KSH 200,000/month',
      'bedrooms': 0,
      'bathrooms': 2,
      'area': '1000',
      'listingType': 'Lease',
      'type': 'Commercial',
      'description': 'Prime commercial space in the heart of the city',
      'images': ['assets/images/property3.jpg'],
      'dateAdded': '2024-01-15',
    },
  ];

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

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
                  colors: [Color(0xFF1E90FF).withOpacity(0.8), Color(0xFF0A66C2).withOpacity(0.8)],
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

            // Favorites Count and Clear All
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 30 : 20,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_favoriteProperties.length} Favorite Properties',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (_favoriteProperties.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _showClearAllConfirmation();
                      },
                      icon: const Icon(Icons.clear_all, color: Colors.red),
                      label: const Text('Clear All', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),

            // Favorites Grid
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                vertical: isLargeScreen ? 30 : 20,
              ),
              child: _favoriteProperties.isEmpty
                  ? Column(
                      children: [
                        SizedBox(height: isLargeScreen ? 50 : 30),
                        Icon(Icons.favorite_border, size: isLargeScreen ? 100 : 70, color: Colors.grey[400]),
                        SizedBox(height: 20),
                        Text(
                          'No favorite properties yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Start browsing properties and add them to your favorites.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 16 : 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/buy');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A66C2),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Browse Properties',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: isLargeScreen ? 50 : 30),
                      ],
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
                      itemCount: _favoriteProperties.length,
                      itemBuilder: (context, index) {
                        final property = _favoriteProperties[index];
                        return _buildFavoritePropertyCard(property);
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

  Widget _buildFavoritePropertyCard(Map<String, dynamic> property) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(property: property),
          ),
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
                  Image.asset(
                    property['images'][0],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        _removeFromFavorites(property);
                      },
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
                        property['listingType'],
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
                      property['title'],
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
                            property['location'],
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (property['bedrooms'] > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFeatureIcon(Icons.bed, '${property['bedrooms']} Beds'),
                          _buildFeatureIcon(Icons.bathtub, '${property['bathrooms']} Baths'),
                          _buildFeatureIcon(Icons.square_foot, '${property['area']} sqft'),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Text(
                      property['price'],
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

  void _removeFromFavorites(Map<String, dynamic> property) {
    setState(() {
      _favoriteProperties.removeWhere((item) => item['title'] == property['title']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${property['title']} removed from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _favoriteProperties.add(property);
            });
          },
        ),
      ),
    );
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Favorites'),
          content: const Text('Are you sure you want to remove all properties from your favorites?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear All', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  _favoriteProperties.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All favorites have been cleared.')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
