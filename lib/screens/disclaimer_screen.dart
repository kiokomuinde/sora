// lib/screens/disclaimer_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';

class DisclaimerScreen extends StatelessWidget {
  final AuthService authService;

  const DisclaimerScreen({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final commonWidgets = CommonWidgets(context: context, authService: authService);
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
                    'Disclaimer',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Important information regarding the use of our services and content.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : 30,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('General Information'),
                  _buildSectionContent(
                    'The information provided by SORA Properties on our website and mobile application is for general informational purposes only. All information is provided in good faith, however, we make no representation or warranty of any kind, express or implied, regarding the accuracy, adequacy, validity, reliability, availability, or completeness of any information on the Site or our mobile application.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('External Links Disclaimer'),
                  _buildSectionContent(
                    'Our Services may contain links to external websites that are not provided or maintained by or in any way affiliated with SORA Properties. Please note that the SORA Properties does not guarantee the accuracy, relevance, timeliness, or completeness of any information on these external websites.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('Professional Advice Disclaimer'),
                  _buildSectionContent(
                    'The information provided on our Services is not intended as, and shall not be understood or construed as, financial, legal, tax, or other professional advice. While the employees and contributors of SORA Properties are professionals, the information provided on this website is not a substitute for professional advice. Accordingly, before making any decisions or taking any actions, you should consult with a qualified professional.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('Errors and Omissions Disclaimer'),
                  _buildSectionContent(
                    'Every effort has been made to ensure the accuracy of the information presented on our Services. However, SORA Properties assumes no responsibility for any errors or omissions in the contents of the Service. In no event shall SORA Properties be liable for any special, direct, indirect, consequential, or incidental damages or any damages whatsoever, whether in an action of contract, negligence, or other tort, arising out of or in connection with the use of the Service or the contents of the Service.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('Fair Use Disclaimer'),
                  _buildSectionContent(
                    'SORA Properties may use copyrighted material which has not always been specifically authorized by the copyright owner. We are making such material available in our efforts to advance understanding of environmental, political, human rights, economic, scientific, and social justice issues, etc. We believe this constitutes a "fair use" of any such copyrighted material as provided for in section 107 of the US Copyright Law.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('Contact Us'),
                  _buildSectionContent(
                    'If you have any questions about this Disclaimer, please contact us at disclaimer@sora.com.',
                    isLargeScreen, isMediumScreen,
                  ),
                  SizedBox(height: isLargeScreen ? 40 : 20),
                  Text(
                    'Last updated: July 15, 2025',
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
            commonWidgets.buildFooter(),
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
