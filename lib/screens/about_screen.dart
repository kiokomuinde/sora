// /lib/screens/about_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for kIsWeb
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sora_app/screens/home_screen.dart'; // Import HomeScreen
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets

class AboutScreen extends StatefulWidget { // Changed to StatefulWidget to manage state for app bar/footer
  final AuthService authService; // Receive AuthService

  const AboutScreen({super.key, required this.authService}); // Add authService to constructor

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final TextEditingController _newsletterEmailController = TextEditingController();
  String _currentListingTypeFilter = ''; // Needed for the common app bar buttons
  late CommonWidgets commonWidgets; // Declare commonWidgets

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService); // Initialize commonWidgets
  }

  @override
  void dispose() {
    _newsletterEmailController.dispose();
    super.dispose();
  }

  // Common dialog for login/signup prompt, copied from home_screen.dart
  void _showLoginSignupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Login or Sign Up Required',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          content: const Text(
            'Please log in or create an account to proceed with this action.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E90FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Login / Sign Up'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                Navigator.pushNamed(context, '/signin'); // Navigate to sign-in
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      appBar: commonWidgets.buildAppBar(
        currentListingTypeFilter: _currentListingTypeFilter,
      ),
      endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // About Us Header Section
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
                    'About SORA Properties',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Your trusted partner in real estate, committed to excellence and client satisfaction.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Our Story Section
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : 30,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Story',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 15),
                  Text(
                    'Founded in 2010, SORA Properties began with a vision to revolutionize the real estate industry in Kenya. We started as a small team of passionate individuals dedicated to helping people find their dream homes and make sound investments. Over the years, we have grown into a leading real estate agency, known for our integrity, expertise, and client-centric approach.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : (isMediumScreen ? 15 : 14),
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 15),
                  Text(
                    'Our journey has been marked by continuous innovation, adapting to market trends, and embracing technology to provide seamless and efficient services. We pride ourselves on building lasting relationships with our clients, guiding them through every step of their real estate journey, whether it\'s buying, selling, or leasing properties.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : (isMediumScreen ? 15 : 14),
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Our Mission & Vision Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : 30,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Mission & Vision',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.flag, size: isLargeScreen ? 40 : 30, color: const Color(0xFF1E90FF)),
                      SizedBox(width: isLargeScreen ? 20 : 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mission:',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'To empower individuals and families to achieve their real estate goals by providing expert guidance, innovative solutions, and unparalleled service.',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 16 : (isMediumScreen ? 15 : 14),
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isLargeScreen ? 30 : 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.visibility, size: isLargeScreen ? 40 : 30, color: const Color(0xFF1E90FF)),
                      SizedBox(width: isLargeScreen ? 20 : 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vision:',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'To be the most trusted and innovative real estate platform in Africa, recognized for our commitment to client success and community development.',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 16 : (isMediumScreen ? 15 : 14),
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Our Values Section
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : 30,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Values',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 15),
                  _buildValueItem(
                    Icons.handshake,
                    'Integrity',
                    'We operate with the highest ethical standards, ensuring transparency and honesty in all our dealings.',
                    isLargeScreen,
                    isMediumScreen,
                  ),
                  _buildValueItem(
                    Icons.lightbulb,
                    'Innovation',
                    'We embrace technology and creative solutions to deliver cutting-edge real estate services.',
                    isLargeScreen,
                    isMediumScreen,
                  ),
                  _buildValueItem(
                    Icons.people,
                    'Client-Centricity',
                    'Our clients are at the heart of everything we do. We are dedicated to understanding and exceeding their expectations.',
                    isLargeScreen,
                    isMediumScreen,
                  ),
                  _buildValueItem(
                    Icons.diversity_3,
                    'Community',
                    'We believe in giving back and contributing positively to the communities we serve.',
                    isLargeScreen,
                    isMediumScreen,
                  ),
                ],
              ),
            ),

            // Team Section (Placeholder)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : 30,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meet Our Team',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 15),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.groups,
                          size: isLargeScreen ? 100 : 70,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Our amazing team is coming soon!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'We\'re building a dedicated section to introduce you to the passionate professionals behind SORA Properties.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 16 : (isMediumScreen ? 14 : 13),
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/agents'); // Navigate to Agents screen
                          },
                          icon: const Icon(Icons.person_search),
                          label: const Text('Find an Agent'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A66C2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Newsletter Signup Section (from original footer, adapted)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : 30,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              color: const Color(0xFFF0F2F5), // Light grey background
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Stay Updated with SORA News',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 15),
                  Text(
                    'Subscribe to our newsletter for the latest property listings, market insights, and exclusive offers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 30 : 20),
                  Container(
                    constraints: BoxConstraints(maxWidth: isLargeScreen ? 500 : double.infinity),
                    child: TextField(
                      controller: _newsletterEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_newsletterEmailController.text.isNotEmpty && _newsletterEmailController.text.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Subscribed with ${_newsletterEmailController.text}!')),
                        );
                        _newsletterEmailController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid email address.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Subscribe'),
                  ),
                ],
              ),
            ),

            // Footer
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  // Helper method for Values Section
  Widget _buildValueItem(IconData icon, String title, String description, bool isLargeScreen, bool isMediumScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: isLargeScreen ? 36 : 28,
            color: const Color(0xFF1E90FF),
          ),
          SizedBox(width: isLargeScreen ? 20 : 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : (isMediumScreen ? 15 : 14),
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
