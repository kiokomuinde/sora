// lib/screens/sitemap_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Corrected import

class SitemapScreen extends StatelessWidget { // Changed back to StatelessWidget
  final AuthService authService;

  const SitemapScreen({Key? key, required this.authService}) : super(key: key);

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
            // Sitemap Header Section
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
                    'SORA Website Sitemap',
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
                    'A comprehensive overview of all pages on the SORA platform.',
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

            // Sitemap Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 150 : (isMediumScreen ? 50 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSitemapSection('Main Navigation', [
                    {'title': 'Home', 'route': '/home'},
                    {'title': 'Buy Properties', 'route': '/property_listings', 'args': {'listingType': 'Buy'}},
                    {'title': 'Rent Properties', 'route': '/property_listings', 'args': {'listingType': 'Rent'}},
                    {'title': 'Lease Properties', 'route': '/property_listings', 'args': {'listingType': 'Lease'}},
                    {'title': 'List Property', 'route': '/list_property_placeholder'}, // Placeholder for future
                  ], context), // Pass context here
                  _buildSitemapSection('About SORA', [
                    {'title': 'About Us', 'route': '/about'},
                    {'title': 'Our Agents', 'route': '/agents'},
                    {'title': 'Contact Us', 'route': '/contact'},
                    {'title': 'Careers', 'route': '/careers'},
                    {'title': 'Blog', 'route': '/blogs'},
                    {'title': 'Testimonials', 'route': '/testimonials'},
                  ], context), // Pass context here
                  _buildSitemapSection('Resources', [
                    {'title': 'FAQs', 'route': '/faqs'},
                    {'title': 'Support', 'route': '/support'},
                    {'title': 'General Terms', 'route': '/terms'},
                    {'title': 'Local Guides', 'route': '/local_guides'},
                    {'title': 'Events', 'route': '/events'},
                  ], context), // Pass context here
                  _buildSitemapSection('Legal & Privacy', [
                    {'title': 'Privacy Policy', 'route': '/privacy_policy_placeholder'}, // Placeholder for future
                    {'title': 'Terms of Service', 'route': '/terms_of_service'},
                    {'title': 'Sitemap', 'route': '/sitemap'},
                  ], context), // Pass context here
                  _buildSitemapSection('User Account', [
                    {'title': 'Sign In', 'route': '/signin'},
                    {'title': 'Sign Up', 'route': '/signup'},
                    {'title': 'User Profile', 'route': '/profile_placeholder'}, // Placeholder for future
                  ], context), // Pass context here
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

  // Helper method now accepts BuildContext as a parameter
  Widget _buildSitemapSection(String title, List<Map<String, dynamic>> links, BuildContext sectionContext) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          const Divider(color: Colors.grey, thickness: 1, height: 20),
          ...links.map((link) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                if (link['route'] != null) {
                  if (link['route'].endsWith('_placeholder')) {
                    // Use the passed sectionContext
                    ScaffoldMessenger.of(sectionContext).showSnackBar(
                      SnackBar(content: Text('${link['title']} functionality coming soon!')),
                    );
                  } else {
                    // Use the passed sectionContext
                    Navigator.pushNamed(sectionContext, link['route'] as String, arguments: link['args']);
                  }
                }
              },
              child: Text(
                '• ${link['title']}',
                style: TextStyle(
                  fontSize: 16,
                  color: link['route'] != null && !link['route'].endsWith('_placeholder') ? Color(0xFF1E90FF) : Colors.grey[700],
                  decoration: link['route'] != null && !link['route'].endsWith('_placeholder') ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
}
