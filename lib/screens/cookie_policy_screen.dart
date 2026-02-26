// lib/screens/cookie_policy_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';

class CookiePolicyScreen extends StatelessWidget {
  final AuthService authService;

  const CookiePolicyScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final commonWidgets = CommonWidgets(context: context, authService: authService);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC), // Clean, light background
      appBar: commonWidgets.buildAppBar(),
      endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header Section
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: isLargeScreen ? 350 : 280,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E90FF), Color(0xFF0A66C2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Subtle background icon pattern
                      Positioned(
                        right: -50,
                        top: -20,
                        child: Icon(
                          Icons.cookie_outlined,
                          size: 300,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -40,
                        child: Icon(
                          Icons.web_asset_outlined,
                          size: 200,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                ),
                // Header Text
                Padding(
                  padding: EdgeInsets.only(bottom: isLargeScreen ? 60 : 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'COOKIE PREFERENCES',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cookie Policy',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 52 : (isMediumScreen ? 42 : 32),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Understanding how we use cookies to enhance your experience.',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Main Content Area (Overlapping the header)
            Transform.translate(
              offset: Offset(0, isLargeScreen ? -80 : -50),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 40 : 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Container(
                      padding: EdgeInsets.all(isLargeScreen ? 50 : (isMediumScreen ? 30 : 20)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A66C2).withOpacity(0.08),
                            spreadRadius: 0,
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.update, color: Colors.grey[500], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Last Updated: February 26, 2026',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Divider(color: Colors.grey[200], thickness: 1.5),
                          const SizedBox(height: 30),
                          
                          // Dynamically building the expanded content sections
                          ..._buildAllSections(isLargeScreen, isMediumScreen),
                          
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F6FF).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF87CEEB).withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.help_outline, color: Color(0xFF0A66C2), size: 28),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'If you have any questions about our use of cookies or other technologies, please email us at soraproperties002@gmail.com.',
                                    style: TextStyle(
                                      color: Colors.blueGrey[800],
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Footer
            Transform.translate(
              offset: Offset(0, isLargeScreen ? -30 : -20),
              child: commonWidgets.buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAllSections(bool isLargeScreen, bool isMediumScreen) {
    final List<Map<String, dynamic>> sections = [
      {
        'title': '1. What are Cookies?',
        'icon': Icons.cookie_outlined,
        'content': 'Cookies are small text files that are placed on your computer or mobile device when you visit a website. They are widely used to make websites work, or work more efficiently, as well as to provide information to the owners of the site. They allow a website to recognize your device and remember if you\'ve been to the website before.',
      },
      {
        'title': '2. How We Use Cookies',
        'icon': Icons.settings_suggest_outlined,
        'content': 'We use cookies to enhance your browsing experience, analyze site traffic, personalize content and ads, and provide social media features. By understanding how you use our site, we can improve its layout, functionality, and tailor our property recommendations to better suit your needs.',
      },
      {
        'title': '3. Types of Cookies We Use',
        'icon': Icons.category_outlined,
        'content': 'Our website employs several categories of cookies to optimize your experience:\n\n'
            '• Essential Website Cookies: These cookies are strictly necessary to provide you with services available through our Website and to use some of its features, such as access to secure areas and authenticating user logins.\n\n'
            '• Performance and Functionality Cookies: These cookies are used to enhance the performance and functionality of our Website but are non-essential to their use. However, without these cookies, certain functionality (like remembering your region or favorite listings) may become unavailable.\n\n'
            '• Analytics and Customization Cookies: These cookies collect information that is used either in aggregate form to help us understand how our Website is being used or how effective our marketing campaigns are, or to help us customize our Website for you.\n\n'
            '• Advertising Cookies: These cookies are used to make advertising messages more relevant to you. They perform functions like preventing the same ad from continuously reappearing, ensuring that ads are properly displayed for advertisers, and in some cases selecting advertisements that are based on your property interests.',
      },
      {
        'title': '4. Your Choices Regarding Cookies',
        'icon': Icons.toggle_on_outlined,
        'content': 'You have the right to decide whether to accept or reject cookies. You can exercise your cookie preferences by clicking on the appropriate opt-out links provided in our cookie banner or by modifying your browser settings. Most web browsers automatically accept cookies, but you can usually modify your browser setting to decline cookies if you prefer. Please note that if you choose to decline cookies, you may not be able to fully experience the interactive features of the SORA Properties services or websites you visit.',
      },
      {
        'title': '5. Changes to Our Cookie Policy',
        'icon': Icons.update_outlined,
        'content': 'We may update this Cookie Policy from time to time in order to reflect, for example, changes to the cookies we use or for other operational, legal or regulatory reasons. Please therefore re-visit this Cookie Policy regularly to stay informed about our use of cookies and related technologies. The "Last Updated" date at the top of this policy indicates when it was last revised.',
      },
    ];

    List<Widget> sectionWidgets = [];
    for (int i = 0; i < sections.length; i++) {
      sectionWidgets.add(
        _buildSection(
          title: sections[i]['title'],
          content: sections[i]['content'],
          icon: sections[i]['icon'],
          isLargeScreen: isLargeScreen,
          isMediumScreen: isMediumScreen,
        ),
      );
      if (i < sections.length - 1) {
        sectionWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: Divider(color: Colors.grey[100], thickness: 1),
          ),
        );
      }
    }
    return sectionWidgets;
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required bool isLargeScreen,
    required bool isMediumScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A66C2).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0A66C2),
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isLargeScreen ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Text(
            content,
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : (isMediumScreen ? 15 : 14),
              color: Colors.grey[700],
              height: 1.7, 
            ),
          ),
        ),
      ],
    );
  }
}