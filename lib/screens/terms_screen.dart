// lib/screens/terms_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Corrected import

class TermsScreen extends StatelessWidget { // Changed back to StatelessWidget
  final AuthService authService;

  const TermsScreen({Key? key, required this.authService}) : super(key: key);

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
            // Terms Header Section
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
                    'General Terms & Conditions',
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
                    'Understand the guidelines for using the SORA platform and services.',
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

            // Terms Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 150 : (isMediumScreen ? 50 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('1. Acceptance of Terms'),
                  _buildSectionContent(
                    'By accessing or using the SORA platform, you agree to be bound by these Terms and Conditions and all applicable laws and regulations. If you do not agree with any of these terms, you are prohibited from using or accessing this site.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('2. Use License'),
                  _buildSectionContent(
                    'Permission is granted to temporarily download one copy of the materials (information or software) on SORA\'s website for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n'
                    '    a. Modify or copy the materials;\n'
                    '    b. Use the materials for any commercial purpose, or for any public display (commercial or non-commercial);\n'
                    '    c. Attempt to decompile or reverse engineer any software contained on SORA\'s website;\n'
                    '    d. Remove any copyright or other proprietary notations from the materials; or\n'
                    '    e. Transfer the materials to another person or "mirror" the materials on any other server.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('3. Disclaimer'),
                  _buildSectionContent(
                    'The materials on SORA\'s website are provided on an \'as is\' basis. SORA makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('4. Limitations'),
                  _buildSectionContent(
                    'In no event shall SORA or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on SORA\'s website, even if SORA or a SORA authorized representative has been notified orally or in writing of the possibility of such damage.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('5. Revisions and Errata'),
                  _buildSectionContent(
                    'The materials appearing on SORA\'s website could include technical, typographical, or photographic errors. SORA does not warrant that any of the materials on its website are accurate, complete or current. SORA may make changes to the materials contained on its website at any time without notice. SORA does not, however, make any commitment to update the materials.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('6. Links'),
                  _buildSectionContent(
                    'SORA has not reviewed all of the sites linked to its website and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by SORA of the site. Use of any such linked website is at the user\'s own risk.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('7. Modifications to Terms'),
                  _buildSectionContent(
                    'SORA may revise these terms of service for its website at any time without notice. By using this website you are agreeing to be bound by the then current version of these terms of service.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('8. Governing Law'),
                  _buildSectionContent(
                    'These terms and conditions are governed by and construed in accordance with the laws of [Your State/Country] and you irrevocably submit to the exclusive jurisdiction of the courts in that State or location.',
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
