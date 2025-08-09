// lib/screens/recently_viewed_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/screens/property_detail_screen.dart';

class RecentlyViewedScreen extends StatefulWidget {
  final AuthService authService;

  const RecentlyViewedScreen({Key? key, required this.authService}) : super(key: key);

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  late CommonWidgets commonWidgets;

  // Sample recently viewed properties data
  List<Map<String, dynamic>> _recentlyViewedProperties = [
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
      'viewedDate': '2024-01-22 14:30',
      'viewCount': 3,
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
      'viewedDate': '2024-01-21 16:45',
      'viewCount': 2,
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
      'viewedDate': '2024-01-20 10:15',
      'viewCount': 1,
    },
    {
      'title': 'Family House in Karen',
      'location': 'Karen, Nairobi',
      'price': 'KSH 35,000,000',
      'bedrooms': 5,
      'bathrooms': 4,
      'area': '4000',
      'listingType': 'Buy',
      'type': 'House',
      'description': 'Spacious family house in a quiet neighborhood',
      'images': ['assets/images/property4.jpg'],
      'viewedDate': '2024-01-19 09:20',
      'viewCount': 1,
    },
    {
      'title': 'Studio Apartment in Parklands',
      'location': 'Parklands, Nairobi',
      'price': 'KSH 45,000/month',
      'bedrooms': 1,
      'bathrooms': 1,
      'area': '600',
      'listingType': 'Rent',
      'type': 'Apartment',
      'description': 'Cozy studio apartment perfect for young professionals',
      'images': ['assets/images/property5.jpg'],
      'viewedDate': '2024-01-18 13:10',
      'viewCount': 2,
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
                    'Recently Viewed',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Properties you\'ve recently viewed, sorted by most recent.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Recently Viewed Count and Clear History
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 30 : 20,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_recentlyViewedProperties.length} Recently Viewed Properties',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (_recentlyViewedProperties.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _showClearHistoryConfirmation();
                      },
                      icon: const Icon(Icons.clear_all, color: Colors.red),
                      label: const Text('Clear History', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),

            // Recently Viewed List
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                vertical: isLargeScreen ? 30 : 20,
              ),
              child: _recentlyViewedProperties.isEmpty
                  ? Column(
                      children: [
                        SizedBox(height: isLargeScreen ? 50 : 30),
                        Icon(Icons.history, size: isLargeScreen ? 100 : 70, color: Colors.grey[400]),
                        SizedBox(height: 20),
                        Text(
                          'No recently viewed properties.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Start browsing properties to see your viewing history here.',
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
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentlyViewedProperties.length,
                      itemBuilder: (context, index) {
                        final property = _recentlyViewedProperties[index];
                        return _buildRecentlyViewedCard(property, index);
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

  Widget _buildRecentlyViewedCard(Map<String, dynamic> property, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailScreen(property: property),
            ),
          );
        },
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Property Image
              Container(
                width: 120,
                height: 120,
                child: Image.asset(
                  property['images'][0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              
              // Property Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              property['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              _removeFromHistory(property, index);
                            },
                            tooltip: 'Remove from history',
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              property['location'],
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            property['price'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A66C2),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A66C2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              property['listingType'],
                              style: const TextStyle(
                                color: Color(0xFF0A66C2),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (property['bedrooms'] > 0)
                        Row(
                          children: [
                            _buildSmallFeatureIcon(Icons.bed, '${property['bedrooms']}'),
                            const SizedBox(width: 15),
                            _buildSmallFeatureIcon(Icons.bathtub, '${property['bathrooms']}'),
                            const SizedBox(width: 15),
                            _buildSmallFeatureIcon(Icons.square_foot, '${property['area']} sqft'),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatViewedDate(property['viewedDate']),
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                          Text(
                            'Viewed ${property['viewCount']} time${property['viewCount'] > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallFeatureIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatViewedDate(String dateString) {
    try {
      final DateTime viewedDate = DateTime.parse(dateString);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(viewedDate);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  void _removeFromHistory(Map<String, dynamic> property, int index) {
    setState(() {
      _recentlyViewedProperties.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${property['title']} removed from history'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _recentlyViewedProperties.insert(index, property);
            });
          },
        ),
      ),
    );
  }

  void _showClearHistoryConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Viewing History'),
          content: const Text('Are you sure you want to clear your entire viewing history?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear History', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  _recentlyViewedProperties.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Viewing history has been cleared.')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
