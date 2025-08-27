// lib/screens/airbnb_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// This screen displays a list of Airbnb-style short-term rentals fetched from Firestore.
class AirbnbScreen extends StatefulWidget {
  final AuthService authService;

  const AirbnbScreen({super.key, required this.authService});

  @override
  State<AirbnbScreen> createState() => _AirbnbScreenState();
}

class _AirbnbScreenState extends State<AirbnbScreen> {
  late CommonWidgets commonWidgets;
  late Future<List<Map<String, dynamic>>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    // Start fetching Airbnb properties from Firestore when the screen initializes
    _propertiesFuture = _fetchAirbnbProperties();
  }

  // Method to fetch all properties from the 'properties' collection where propertyType is 'Vocational'
  Future<List<Map<String, dynamic>>> _fetchAirbnbProperties() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('properties')
          .where('propertyType', isEqualTo: 'Vocational')
          .get();

      return querySnapshot.docs.map((doc) => {
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id, // Add the document ID to the data map
          }).toList();
    } catch (e) {
      print('Error fetching Airbnb properties: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    
    // Set column count based on screen size
    int crossAxisCount = 1;
    if (isLargeScreen) {
      crossAxisCount = 3;
    } else if (isMediumScreen) {
      crossAxisCount = 2;
    }

    return Scaffold(
      // The `buildAppBar` method in `common_widgets.dart` does not have a `title` parameter.
      // Removed the title parameter to resolve the compilation error.
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _propertiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return commonWidgets.buildEmptyState(
                    'Oops!',
                    'Something went wrong. Please try again later.',
                    () {
                      setState(() {
                        _propertiesFuture = _fetchAirbnbProperties();
                      });
                    },
                    'Retry',
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return commonWidgets.buildEmptyState(
                    'No Listings Found',
                    'There are no short-term rentals available at the moment.',
                    () {
                      setState(() {
                        _propertiesFuture = _fetchAirbnbProperties();
                      });
                    },
                    'Refresh',
                  );
                } else {
                  final properties = snapshot.data!;
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                      vertical: 20,
                    ),
                    color: const Color(0xFFF0F2F5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: properties.length,
                          itemBuilder: (context, index) {
                            final listing = properties[index];
                            return _buildListingCard(listing);
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    final Map<String, dynamic> location = listing['location'] ?? {};
    final Map<String, dynamic> airbnbDetails = listing['airbnbDetails'] ?? {};
    final String guests = (airbnbDetails['guests'] ?? 'N/A').toString();

    // Wrap the Card with an InkWell to make it clickable
    return InkWell(
      onTap: () {
        // Navigate to the view property screen and pass the listing data
        Navigator.pushNamed(
          context,
          '/view_property',
          arguments: listing,
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    listing['coverImageUrl'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return const Center(child: Text('Image Failed to Load'));
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {
                        // Handle favorite logic
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                height: 120, // Fixed height to prevent layout shifts
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
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
                            '${location['locality']}, ${location['town']}',
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
                        _buildFeatureIcon(Icons.bed, '${airbnbDetails['bedrooms']} Bed'),
                        const SizedBox(width: 15),
                        _buildFeatureIcon(Icons.person, '$guests Guests'),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'KSH ${listing['price']} / night',
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
}
