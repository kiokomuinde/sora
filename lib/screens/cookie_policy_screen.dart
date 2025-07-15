// lib/screens/cookie_policy_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';

class CookiePolicyScreen extends StatelessWidget {
  final AuthService authService;

  const CookiePolicyScreen({Key? key, required this.authService}) : super(key: key);

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
                    'Cookie Policy',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Understanding how we use cookies to enhance your experience.',
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
                  _buildSectionTitle('What are Cookies?'),
                  _buildSectionContent(
                    'Cookies are small text files that are placed on your computer or mobile device when you visit a website. They are widely used to make websites work, or work more efficiently, as well as to provide information to the owners of the site.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('How We Use Cookies'),
                  _buildSectionContent(
                    'We use cookies to enhance your browsing experience, analyze site traffic, personalize content and ads, and provide social media features. Specifically, we use cookies for:',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildListItem('Essential Website Cookies: These cookies are strictly necessary to provide you with services available through our Website and to use some of its features, such as access to secure areas.'),
                  _buildListItem('Performance and Functionality Cookies: These cookies are used to enhance the performance and functionality of our Website but are non-essential to their use. However, without these cookies, certain functionality may become unavailable.'),
                  _buildListItem('Analytics and Customization Cookies: These cookies collect information that is used either in aggregate form to help us understand how our Website is being used or how effective our marketing campaigns are, or to help us customize our Website for you.'),
                  _buildListItem('Advertising Cookies: These cookies are used to make advertising messages more relevant to you. They perform functions like preventing the same ad from continuously reappearing, ensuring that ads are properly displayed for advertisers, and in some cases selecting advertisements that are based on your interests.'),
                  _buildSectionTitle('Your Choices Regarding Cookies'),
                  _buildSectionContent(
                    'You have the right to decide whether to accept or reject cookies. You can exercise your cookie preferences by clicking on the appropriate opt-out links provided in the cookie banner or by modifying your browser settings. Most browsers allow you to refuse to accept cookies and to delete cookies.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('Changes to Our Cookie Policy'),
                  _buildSectionContent(
                    'We may update this Cookie Policy from time to time in order to reflect, for example, changes to the cookies we use or for other operational, legal or regulatory reasons. Please therefore re-visit this Cookie Policy regularly to stay informed about our use of cookies and related technologies.',
                    isLargeScreen, isMediumScreen,
                  ),
                  _buildSectionTitle('Contact Us'),
                  _buildSectionContent(
                    'If you have any questions about our use of cookies or other technologies, please email us at cookies@sora.com.',
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

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, color: Colors.grey)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
