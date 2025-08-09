// lib/screens/my_listings_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';

class MyListingsScreen extends StatefulWidget {
  final AuthService authService;

  const MyListingsScreen({Key? key, required this.authService}) : super(key: key);

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late CommonWidgets commonWidgets;

  // Sample user listings data
  final List<Map<String, dynamic>> _userListings = [
    {
      'id': '1',
      'title': '3BR House in Karen',
      'location': 'Karen, Nairobi',
      'price': 'KSH 25,000,000',
      'bedrooms': 3,
      'bathrooms': 2,
      'area': '2500',
      'listingType': 'Buy',
      'status': 'Active',
      'datePosted': '2024-01-15',
      'views': 45,
      'inquiries': 8,
      'image': 'assets/images/property1.jpg',
    },
    {
      'id': '2',
      'title': 'Modern Apartment in Westlands',
      'location': 'Westlands, Nairobi',
      'price': 'KSH 80,000/month',
      'bedrooms': 2,
      'bathrooms': 2,
      'area': '1200',
      'listingType': 'Rent',
      'status': 'Active',
      'datePosted': '2024-01-10',
      'views': 32,
      'inquiries': 5,
      'image': 'assets/images/property2.jpg',
    },
    {
      'id': '3',
      'title': 'Office Space in CBD',
      'location': 'CBD, Nairobi',
      'price': 'KSH 150,000/month',
      'bedrooms': 0,
      'bathrooms': 2,
      'area': '800',
      'listingType': 'Lease',
      'status': 'Pending',
      'datePosted': '2024-01-05',
      'views': 28,
      'inquiries': 3,
      'image': 'assets/images/property3.jpg',
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
                    'My Listings',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Manage your property listings and track their performance.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 30 : 20,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_userListings.length} Properties Listed',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  ElevatedButton.icon(
                   onPressed: () {
                      Navigator.pushNamed(context, '/add_property');
                    },                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add New Listing', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A66C2),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Listings Grid
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                vertical: isLargeScreen ? 30 : 20,
              ),
              child: _userListings.isEmpty
                  ? Column(
                      children: [
                        SizedBox(height: isLargeScreen ? 50 : 30),
                        Icon(Icons.home_work_outlined, size: isLargeScreen ? 100 : 70, color: Colors.grey[400]),
                        SizedBox(height: 20),
                        Text(
                          'No listings found.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Start by adding your first property listing.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 16 : 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: isLargeScreen ? 50 : 30),
                      ],
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isLargeScreen ? 2 : 1,
                        crossAxisSpacing: isLargeScreen ? 30 : 20,
                        mainAxisSpacing: isLargeScreen ? 30 : 20,
                        childAspectRatio: isLargeScreen ? 1.5 : 1.2,
                      ),
                      itemCount: _userListings.length,
                      itemBuilder: (context, index) {
                        final listing = _userListings[index];
                        return _buildListingCard(listing);
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

  Widget _buildListingCard(Map<String, dynamic> listing) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Image.asset(
                  listing['image'],
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
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: listing['status'] == 'Active' ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      listing['status'],
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A66C2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      listing['listingType'],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing['title'],
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
                          listing['location'],
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (listing['bedrooms'] > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFeatureIcon(Icons.bed, '${listing['bedrooms']} Beds'),
                        _buildFeatureIcon(Icons.bathtub, '${listing['bathrooms']} Baths'),
                        _buildFeatureIcon(Icons.square_foot, '${listing['area']} sqft'),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Text(
                    listing['price'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${listing['views']} Views',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          Text(
                            '${listing['inquiries']} Inquiries',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF0A66C2)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Edit listing feature coming soon!')),
                              );
                            },
                            tooltip: 'Edit Listing',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmation(listing);
                            },
                            tooltip: 'Delete Listing',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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

  void _showDeleteConfirmation(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Listing'),
          content: Text('Are you sure you want to delete "${listing['title']}"?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  _userListings.removeWhere((item) => item['id'] == listing['id']);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${listing['title']} has been deleted.')),
                );
              },
            ),
          ],
        );
      },  );
  }
}
