// lib/screens/airbnb_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';

// This screen displays a list of sample Airbnb-style short-term rentals.
class AirbnbScreen extends StatefulWidget {
  final AuthService authService;

  const AirbnbScreen({super.key, required this.authService});

  @override
  State<AirbnbScreen> createState() => _AirbnbScreenState();
}

class _AirbnbScreenState extends State<AirbnbScreen> {
  late CommonWidgets commonWidgets;

  // Sample Airbnb-style listings data
  final List<Map<String, dynamic>> _airbnbListings = [
    {
      'id': '1',
      'title': 'Cozy Lakeside Cabin',
      'location': 'Lake Naivasha, Kenya',
      'price': 'KSH 15,000 / night',
      'bedrooms': 2,
      'guests': 4,
      'rating': 4.8,
      'image': 'assets/images/property_airbnb1.jpg',
    },
    {
      'id': '2',
      'title': 'Modern Loft in Downtown',
      'location': 'CBD, Nairobi',
      'price': 'KSH 10,000 / night',
      'bedrooms': 1,
      'guests': 2,
      'rating': 4.5,
      'image': 'assets/images/property_airbnb2.jpg',
    },
    {
      'id': '3',
      'title': 'Beachfront Villa with Pool',
      'location': 'Diani Beach, Mombasa',
      'price': 'KSH 30,000 / night',
      'bedrooms': 3,
      'guests': 6,
      'rating': 4.9,
      'image': 'assets/images/property_airbnb3.jpg',
    },
    {
      'id': '4',
      'title': 'Safari Tent in Maasai Mara',
      'location': 'Maasai Mara, Kenya',
      'price': 'KSH 20,000 / night',
      'bedrooms': 1,
      'guests': 2,
      'rating': 5.0,
      'image': 'assets/images/property_airbnb4.jpg',
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
                  colors: [const Color(0xFF1E90FF).withOpacity(0.8), const Color(0xFF0A66C2).withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Your Perfect Getaway',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Browse unique homes and experiences for your next trip.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
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
              child: _airbnbListings.isEmpty
                  ? Column(
                      children: [
                        SizedBox(height: isLargeScreen ? 50 : 30),
                        Icon(Icons.bed_outlined, size: isLargeScreen ? 100 : 70, color: Colors.grey[400]),
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
                          'Check back later for new short-term rental listings.',
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
                        crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
                        crossAxisSpacing: isLargeScreen ? 30 : 20,
                        mainAxisSpacing: isLargeScreen ? 30 : 20,
                        childAspectRatio: 0.8, // Adjusted aspect ratio for the new card design
                      ),
                      itemCount: _airbnbListings.length,
                      itemBuilder: (context, index) {
                        final listing = _airbnbListings[index];
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
            flex: 3,
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
                  left: 10, // Moved star icon to the top left
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          '${listing['rating']}',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 5, // Adjusted position to give it some space
                  right: 5, // Placed favorites icon in the top right
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement favorite functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Favorite added for ${listing['title']}')),
                      );
                    },
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
                  Row(
                    children: [
                      _buildFeatureIcon(Icons.bed, '${listing['bedrooms']} Bed'),
                      const SizedBox(width: 15),
                      _buildFeatureIcon(Icons.person, '${listing['guests']} Guests'),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    listing['price'],
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
}
