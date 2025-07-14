// lib/screens/events_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Corrected import
import 'package:intl/intl.dart'; // For date formatting

class EventsScreen extends StatelessWidget { // Changed back to StatelessWidget
  final AuthService authService;

  const EventsScreen({Key? key, required this.authService}) : super(key: key);

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
            // Events Header Section
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
                    'Upcoming Real Estate Events',
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
                    'Join us for open houses, workshops, and community gatherings.',
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

            // Events List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 150 : (isMediumScreen ? 50 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Events',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 30 : 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_events[index], isLargeScreen, isMediumScreen, context);
                    },
                  ),
                  SizedBox(height: isLargeScreen ? 60 : 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Loading more events... (coming soon!)')),
                        );
                      },
                      icon: Icon(Icons.calendar_month, color: Colors.white),
                      label: Text(
                        'View Full Calendar',
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

  Widget _buildEventCard(Map<String, dynamic> event, bool isLargeScreen, bool isMediumScreen, BuildContext cardContext) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.only(bottom: isLargeScreen ? 30 : 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 25 : (isMediumScreen ? 20 : 15)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Time Column
            Container(
              width: isLargeScreen ? 120 : (isMediumScreen ? 100 : 80),
              padding: EdgeInsets.all(isLargeScreen ? 15 : 10),
              decoration: BoxDecoration(
                color: Color(0xFF0A66C2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM').format(event['date'] as DateTime),
                    style: TextStyle(
                      fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  Text(
                    DateFormat('dd').format(event['date'] as DateTime),
                    style: TextStyle(
                      fontSize: isLargeScreen ? 36 : (isMediumScreen ? 30 : 24),
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E90FF),
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(event['date'] as DateTime),
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : (isMediumScreen ? 14 : 12),
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isLargeScreen ? 25 : 15),
            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']!,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 24 : (isMediumScreen ? 20 : 18),
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    event['description']!,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : (isMediumScreen ? 14 : 13),
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: isLargeScreen ? 20 : 16, color: Colors.grey[600]),
                      SizedBox(width: 5),
                      Text(
                        event['location']!,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 14 : (isMediumScreen ? 13 : 12),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(cardContext).showSnackBar( // Use passed context
                          SnackBar(content: Text('Registering for ${event['title']}... (coming soon!)')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E90FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 20 : 15, vertical: isLargeScreen ? 10 : 8),
                      ),
                      child: Text(
                        'Register Now',
                        style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample events data
  static final List<Map<String, dynamic>> _events = [
    {
      'title': 'First-Time Homebuyer Workshop',
      'description': 'Learn everything you need to know about buying your first home, from financing to closing.',
      'date': DateTime.now().add(Duration(days: 10, hours: 2, minutes: 30)),
      'location': 'SORA Community Center, 123 Main St',
    },
    {
      'title': 'Investment Property Seminar',
      'description': 'Explore strategies for successful real estate investing and market trends with expert speakers.',
      'date': DateTime.now().add(Duration(days: 25, hours: 10, minutes: 0)),
      'location': 'Online Webinar (Zoom)',
    },
    {
      'title': 'Open House Weekend Extravaganza',
      'description': 'Visit a wide selection of open houses across various neighborhoods. Find your perfect home!',
      'date': DateTime.now().add(Duration(days: 40, hours: 14, minutes: 0)),
      'location': 'Various Locations',
    },
    {
      'title': 'Real Estate Tech Innovations Summit',
      'description': 'Discover the latest technological advancements shaping the future of the real estate industry.',
      'date': DateTime.now().add(Duration(days: 60, hours: 9, minutes: 0)),
      'location': 'Convention Center, City Hall',
    },
  ];
}
