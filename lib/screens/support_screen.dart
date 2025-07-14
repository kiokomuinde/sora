// lib/screens/support_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Corrected import

class SupportScreen extends StatelessWidget { // Changed back to StatelessWidget
  final AuthService authService;

  const SupportScreen({Key? key, required this.authService}) : super(key: key);

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
            // Support Header Section
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
                    'SORA Support Center',
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
                    'How can we help you today? Reach out to us for assistance.',
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

            // Support Options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 150 : (isMediumScreen ? 50 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Options',
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
                      if (constraints.maxWidth > 700) {
                        crossAxisCount = 2;
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: isLargeScreen ? 40 : 20,
                          mainAxisSpacing: isLargeScreen ? 40 : 20,
                          childAspectRatio: isLargeScreen ? 2.5 : (isMediumScreen ? 2.0 : 1.5),
                        ),
                        itemCount: _supportOptions.length,
                        itemBuilder: (context, index) {
                          return _buildSupportOptionCard(_supportOptions[index], isLargeScreen, isMediumScreen, context);
                        },
                      );
                    },
                  ),
                  SizedBox(height: isLargeScreen ? 60 : 30),
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : (isMediumScreen ? 28 : 24),
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Before contacting us, please check our comprehensive FAQ section. Your question might already be answered!',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 15),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/faqs');
                      },
                      icon: Icon(Icons.help_outline, color: Colors.white),
                      label: Text(
                        'Visit our FAQs',
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

  Widget _buildSupportOptionCard(Map<String, dynamic> option, bool isLargeScreen, bool isMediumScreen, BuildContext cardContext) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Placeholder for action
          ScaffoldMessenger.of(cardContext).showSnackBar( // Use passed context
            SnackBar(content: Text('${option['title']} clicked! Functionality coming soon.')),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(isLargeScreen ? 25 : (isMediumScreen ? 20 : 15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(option['icon'] as IconData, size: isLargeScreen ? 48 : 36, color: Color(0xFF0A66C2)),
              SizedBox(height: isLargeScreen ? 15 : 10),
              Text(
                option['title']!,
                style: TextStyle(
                  fontSize: isLargeScreen ? 22 : (isMediumScreen ? 20 : 18),
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A66C2),
                ),
              ),
              SizedBox(height: 8),
              Text(
                option['description']!,
                style: TextStyle(
                  fontSize: isLargeScreen ? 16 : (isMediumScreen ? 14 : 13),
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sample support options data
  static const List<Map<String, dynamic>> _supportOptions = [
    {
      'title': 'Submit a Ticket',
      'description': 'For detailed inquiries or technical issues, submit a support ticket and our team will get back to you.',
      'icon': Icons.receipt_long,
    },
    {
      'title': 'Live Chat',
      'description': 'Chat with a support representative in real-time for immediate assistance during business hours.',
      'icon': Icons.chat,
    },
    {
      'title': 'Call Us',
      'description': 'Speak directly with our support team. Available Monday-Friday, 9 AM - 5 PM EST.',
      'icon': Icons.phone,
    },
    {
      'title': 'Email Support',
      'description': 'Send us an email with your questions, and we\'ll respond as soon as possible.',
      'icon': Icons.email,
    },
  ];
}
