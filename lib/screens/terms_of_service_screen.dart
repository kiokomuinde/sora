// lib/screens/terms_of_service_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Corrected import

class TermsOfServiceScreen extends StatelessWidget { // Changed back to StatelessWidget
  final AuthService authService;

  const TermsOfServiceScreen({Key? key, required this.authService}) : super(key: key);

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
            // Terms of Service Header Section
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
                    'SORA Terms of Service',
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
                    'Your agreement to use our platform and services.',
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

            // Terms of Service Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 150 : (isMediumScreen ? 50 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('1. Introduction'),
                  _buildSectionContent(
                    'Welcome to SORA! These Terms of Service ("Terms") govern your access to and use of the SORA website, mobile applications, and services (collectively, the "Service"). Please read these Terms carefully before using the Service. By accessing or using the Service, you agree to be bound by these Terms and our Privacy Policy. If you do not agree to these Terms, you may not use the Service.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('2. Eligibility'),
                  _buildSectionContent(
                    'You must be at least 18 years old to use the Service. By using the Service, you represent and warrant that you are at least 18 years old and have the legal capacity to enter into these Terms.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('3. Account Registration'),
                  _buildSectionContent(
                    'To access certain features of the Service, you may be required to register for an account. You agree to provide accurate, current, and complete information during the registration process and to update such information to keep it accurate, current, and complete. You are responsible for safeguarding your password and for all activities that occur under your account.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('4. User Conduct'),
                  _buildSectionContent(
                    'You agree not to use the Service for any unlawful purpose or in any way that could harm SORA, its users, or any third party. Prohibited activities include, but are not limited to:\n\n'
                    '    a. Posting false, misleading, or fraudulent information;\n'
                    '    b. Engaging in any form of harassment, hate speech, or discrimination;\n'
                    '    c. Violating any intellectual property rights;\n'
                    '    d. Uploading viruses or malicious code;\n'
                    '    e. Interfering with the operation of the Service.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('5. Content and Listings'),
                  _buildSectionContent(
                    'SORA allows users to post real estate listings and related content. You are solely responsible for the content you post, and you represent and warrant that you have all necessary rights to post such content. SORA reserves the right to remove any content that violates these Terms or is otherwise objectionable.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('6. Disclaimers'),
                  _buildSectionContent(
                    'The Service is provided "as is" and "as available" without warranties of any kind, either express or implied. SORA does not warrant that the Service will be uninterrupted, error-free, or secure. SORA does not endorse or guarantee the accuracy, completeness, or reliability of any listings or content posted by users.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('7. Limitation of Liability'),
                  _buildSectionContent(
                    'To the fullest extent permitted by law, SORA shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses, resulting from (a) your access to or use of or inability to access or use the Service; (b) any conduct or content of any third party on the Service; or (c) unauthorized access, use, or alteration of your transmissions or content.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('8. Governing Law'),
                  _buildSectionContent(
                    'These Terms shall be governed and construed in accordance with the laws of [Your State/Country], without regard to its conflict of law provisions.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('9. Changes to Terms'),
                  _buildSectionContent(
                    'SORA reserves the right to modify these Terms at any time. We will notify you of any changes by posting the new Terms on this page. Your continued use of the Service after any such changes constitutes your acceptance of the new Terms.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('10. Contact Us'),
                  _buildSectionContent(
                    'If you have any questions about these Terms, please contact us at support@sora.com.',
                    isLargeScreen, isMediumScreen,
                  ),
                  SizedBox(height: isLargeScreen ? 40 : 20),
                  Text(
                    'Last updated: July 10, 2025',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 14 : 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0A66C2),
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content, bool isLargeScreen, bool isMediumScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        content,
        style: TextStyle(
          fontSize: isLargeScreen ? 16 : (isMediumScreen ? 15 : 14),
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    );
  }
}
