// lib/screens/local_guides_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Corrected import

class LocalGuidesScreen extends StatelessWidget { // Changed back to StatelessWidget
  final AuthService authService;

  const LocalGuidesScreen({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Correctly instantiate CommonWidgets
    final commonWidgets = CommonWidgets(context: context, authService: authService);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      appBar: commonWidgets.buildAppBar(), // Call on instance
      endDrawer: commonWidgets.buildDrawer(), // Call on instance
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Local Guides Header Section
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
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isLargeScreen ? 80 : 40),
                  bottomRight: Radius.circular(isLargeScreen ? 80 : 40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Explore Neighborhoods with Local Guides',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 52 : (isMediumScreen ? 40 : 32),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Get insider tips and detailed insights on areas you\'re interested in.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : (isMediumScreen ? 18 : 16),
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: isLargeScreen ? 60 : 30),

            // Local Guides Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Guides',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 30 : 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 1;
                      if (constraints.maxWidth > 900) {
                        crossAxisCount = 3;
                      } else if (constraints.maxWidth > 600) {
                        crossAxisCount = 2;
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: isLargeScreen ? 40 : 20,
                          mainAxisSpacing: isLargeScreen ? 40 : 20,
                          childAspectRatio: 0.8, // Adjust as needed for content
                        ),
                        itemCount: _localGuides.length,
                        itemBuilder: (context, index) {
                          return _buildGuideCard(_localGuides[index], isLargeScreen, isMediumScreen, context);
                        },
                      );
                    },
                  ),
                  SizedBox(height: isLargeScreen ? 60 : 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Loading more guides... (coming soon!)')),
                        );
                      },
                      icon: Icon(Icons.arrow_forward, color: Colors.white),
                      label: Text(
                        'View All Guides',
                        style: TextStyle(fontSize: isLargeScreen ? 18 : 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E90FF),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 30 : 20,
                          vertical: isLargeScreen ? 15 : 12,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isLargeScreen ? 60 : 30),
            commonWidgets.buildFooter(), // Call on instance
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(Map<String, String> guide, bool isLargeScreen, bool isMediumScreen, BuildContext cardContext) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Image.network(
              guide['imageUrl']!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.location_city, size: isLargeScreen ? 80 : 60, color: Colors.grey[600]),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 20 : (isMediumScreen ? 15 : 10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide['title']!,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : (isMediumScreen ? 18 : 16),
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    guide['description']!,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 14 : (isMediumScreen ? 13 : 12),
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(cardContext).showSnackBar( // Use passed context
                          SnackBar(content: Text('Reading guide for ${guide['title']}... (coming soon!)')),
                        );
                      },
                      child: Text(
                        'Read More',
                        style: TextStyle(color: Color(0xFF1E90FF), fontWeight: FontWeight.bold),
                      ),
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

  // Sample local guides data
  static const List<Map<String, String>> _localGuides = [
    {
      'title': 'The Vibrant Heart of Downtown',
      'description': 'Discover the best restaurants, entertainment, and cultural spots in the bustling downtown area. Perfect for city lovers.',
      'imageUrl': 'https://placehold.co/600x400/A0C4FF/0A66C2?text=Downtown+Guide',
    },
    {
      'title': 'Suburban Serenity: Family-Friendly Living',
      'description': 'A comprehensive guide to the quiet, green suburbs, highlighting top schools, parks, and community events.',
      'imageUrl': 'https://placehold.co/600x400/B8E0D4/0A66C2?text=Suburban+Guide',
    },
    {
      'title': 'Coastal Charm: Beachfront Properties',
      'description': 'Explore the stunning coastal neighborhoods, from luxury beachfront homes to cozy seaside cottages. Includes beach access and local attractions.',
      'imageUrl': 'https://placehold.co/600x400/FFD1DC/0A66C2?text=Coastal+Guide',
    },
    {
      'title': 'Historic Districts: A Glimpse into the Past',
      'description': 'Step back in time with a guide to our city\'s historic districts, featuring architectural marvels and rich heritage.',
      'imageUrl': 'https://placehold.co/600x400/CDB4DB/0A66C2?text=Historic+Guide',
    },
    {
      'title': 'Uptown Living: Modern & Trendy',
      'description': 'A guide to the most fashionable uptown areas, known for their modern apartments, trendy boutiques, and vibrant nightlife.',
      'imageUrl': 'https://placehold.co/600x400/FFC8DD/0A66C2?text=Uptown+Guide',
    },
    {
      'title': 'Mountain View Retreats: Nature\'s Escape',
      'description': 'Find your peaceful retreat in the mountain view communities, offering breathtaking scenery and outdoor activities.',
      'imageUrl': 'https://placehold.co/600x400/BDE0FE/0A66C2?text=Mountain+Guide',
    },
  ];
}
