// lib/screens/terms_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';

class TermsScreen extends StatefulWidget {
  final AuthService authService;

  const TermsScreen({super.key, required this.authService});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  late CommonWidgets commonWidgets;

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0A66C2),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[800],
        height: 1.6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: Colors.white,
      // If you are using the activePageRoute fix, you can pass activePageRoute: '/terms' here
      appBar: commonWidgets.buildAppBar(), 
      endDrawer: isMobile ? commonWidgets.buildDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: 50,
                horizontal: isMobile ? 20 : 100,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Terms of Service',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Last Updated: February 2026',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Container(
              constraints: const BoxConstraints(maxWidth: 1000), // Keeps text readable on wide screens
              padding: EdgeInsets.symmetric(
                vertical: 40,
                horizontal: isMobile ? 20 : 50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParagraph(
                    'Welcome to Sora Properties. By accessing or using our website, services, or mobile applications, you agree to be bound by these Terms of Service. Please read them carefully.',
                  ),
                  
                  _buildSectionTitle('1. Acceptance of Terms'),
                  _buildParagraph(
                    'By creating an account, browsing listings, or otherwise using the Sora platform, you confirm that you accept these terms and agree to comply with them. If you do not agree, you must not use our services.',
                  ),

                  _buildSectionTitle('2. User Accounts'),
                  _buildParagraph(
                    'To access certain features, such as saving favorite properties or managing your own listings, you must register for an account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
                  ),

                  _buildSectionTitle('3. Property Listings and Content'),
                  _buildParagraph(
                    'Sora Properties strives to provide accurate information regarding property listings for buying, renting, leasing, and BNB stays. However, we do not guarantee the absolute accuracy, completeness, or reliability of any property descriptions, images, or pricing provided by third-party agents or sellers.',
                  ),

                  _buildSectionTitle('4. Prohibited Activities'),
                  _buildParagraph(
                    'Users agree not to use the platform for any unlawful purpose, to upload malicious code, to attempt to gain unauthorized access to our systems, or to submit false, misleading, or fraudulent property listings.',
                  ),

                  _buildSectionTitle('5. Limitation of Liability'),
                  _buildParagraph(
                    'Sora Properties shall not be liable for any direct, indirect, incidental, or consequential damages resulting from your use of the platform, your inability to use the platform, or any real estate transactions initiated through our service.',
                  ),

                  _buildSectionTitle('6. Contact Us'),
                  _buildParagraph(
                    'If you have any questions or concerns regarding these Terms of Service, please contact us at soraproperties002@gmail.com or via our Contact Us page.',
                  ),
                  
                  const SizedBox(height: 40),
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
}