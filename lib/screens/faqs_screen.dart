// lib/screens/faqs_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Corrected import

class FAQsScreen extends StatelessWidget { // Changed back to StatelessWidget as per original intention
  final AuthService authService;

  const FAQsScreen({Key? key, required this.authService}) : super(key: key);

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
            // FAQs Header Section
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
                    'Frequently Asked Questions',
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
                    'Find answers to common questions about SORA and real estate.',
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

            // FAQs Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 150 : (isMediumScreen ? 50 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _faqs.map((faq) => _buildFAQItem(faq, isLargeScreen, isMediumScreen)).toList(),
              ),
            ),
            SizedBox(height: isLargeScreen ? 60 : 30),
            commonWidgets.buildFooter(), // Call on instance
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, String> faq, bool isLargeScreen, bool isMediumScreen) {
    return Card(
      margin: EdgeInsets.only(bottom: isLargeScreen ? 20 : 15),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 25 : (isMediumScreen ? 20 : 15),
          vertical: isLargeScreen ? 15 : (isMediumScreen ? 10 : 8),
        ),
        title: Text(
          faq['question']!,
          style: TextStyle(
            fontSize: isLargeScreen ? 20 : (isMediumScreen ? 18 : 16),
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A66C2),
          ),
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: isLargeScreen ? 25 : (isMediumScreen ? 20 : 15),
              right: isLargeScreen ? 25 : (isMediumScreen ? 20 : 15),
              bottom: isLargeScreen ? 20 : (isMediumScreen ? 15 : 10),
            ),
            child: Text(
              faq['answer']!,
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : (isMediumScreen ? 14 : 13),
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sample FAQ data
  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I list my property on SORA?',
      'answer': 'To list your property, simply navigate to the "List Property" button in the top right corner of the navigation bar. You will need to be logged in to access the listing form. Follow the steps to provide details, photos, and pricing for your property.',
    },
    {
      'question': 'What are the fees for using SORA?',
      'answer': 'SORA operates on a transparent, no-brokerage model for direct transactions between buyers, sellers, and renters. While listing is generally free, premium features or specific services might have associated costs, which will always be clearly communicated.',
    },
    {
      'question': 'How can I search for properties in a specific area?',
      'answer': 'You can use the search bar in the navigation bar or on the home page to enter a location, or utilize the advanced search filters on the "Buy," "Rent," or "Lease" pages to narrow down your search by location, property type, price range, and more.',
    },
    {
      'question': 'Is SORA available in all regions?',
      'answer': 'SORA is continuously expanding its coverage. Please check our property listings or contact our support team to confirm availability in your desired region.',
    },
    {
      'question': 'How do I contact an agent?',
      'answer': 'On each property detail page, you will find contact information for the listing agent or property owner. You can also visit our "Agents" page to browse agent profiles and connect directly with them.',
    },
    {
      'question': 'What is the "Local Guides" section?',
      'answer': 'The "Local Guides" section provides curated information about various neighborhoods, including amenities, schools, transport, and lifestyle insights, to help you make informed decisions about where to live.',
    },
    {
      'question': 'How can I report an issue or provide feedback?',
      'answer': 'You can report issues or provide feedback through our "Support" page, where you\'ll find options to contact us directly or submit a support ticket.',
    },
  ];
}
