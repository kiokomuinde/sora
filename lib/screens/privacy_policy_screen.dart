// lib/screens/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final AuthService authService;

  const PrivacyPolicyScreen({super.key, required this.authService});

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
                          Icons.security_rounded,
                          size: 300,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -40,
                        child: Icon(
                          Icons.privacy_tip_outlined,
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
                          'DATA PROTECTION',
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
                        'Privacy Policy',
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
                        'Your privacy is our priority. Learn how we protect your data.',
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
                                const Icon(Icons.mark_email_read_outlined, color: Color(0xFF0A66C2), size: 28),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Have questions or concerns about your data? Reach out to our privacy team at soraproperties002@gmail.com.',
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
        'title': '1. Introduction',
        'icon': Icons.info_outline,
        'content': 'SORA Properties ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy outlines how we collect, use, disclose, and safeguard your personal information when you visit our website, use our mobile applications, or interact with our real estate services (collectively, the "Services"). By accessing or using our Services, you consent to the data practices described in this policy.',
      },
      {
        'title': '2. Information We Collect',
        'icon': Icons.data_usage_outlined,
        'content': 'We collect information to provide better services to all our users. The types of data we collect include:\n\n'
            '• Personal Information You Provide: When you register for an account, subscribe to our newsletter, fill out a contact form, or communicate with us, we may collect your name, email address, phone number, mailing address, and financial or payment details if engaging in a transaction.\n'
            '• Automated Data Collection: As you navigate through and interact with our Services, we may use automatic data collection technologies to collect certain information about your equipment, browsing actions, and patterns, including IP addresses, browser types, operating systems, and referring URLs.\n'
            '• Third-Party Information: We may receive information about you from third-party partners, such as real estate brokers, background check services, or public databases.',
      },
      {
        'title': '3. How We Use Your Information',
        'icon': Icons.settings_suggest_outlined,
        'content': 'We use the information we collect for various purposes, including to:\n\n'
            '• Provide, maintain, and improve our real estate platform and user experience.\n'
            '• Process your requests, transactions, and property inquiries.\n'
            '• Send you administrative messages, security alerts, and technical notices.\n'
            '• Communicate with you about property listings, updates, and promotional offers (which you can opt out of at any time).\n'
            '• Monitor and analyze trends, usage, and activities in connection with our Services to detect and prevent fraud.',
      },
      {
        'title': '4. Sharing and Disclosure of Information',
        'icon': Icons.share_outlined,
        'content': 'We do not sell, trade, or rent your personal identification information to others. We may share your information under the following circumstances:\n\n'
            '• With Service Providers: We may share data with trusted third-party vendors who perform services on our behalf, such as payment processing, data analysis, email delivery, and hosting services.\n'
            '• With Agents and Landlords: When you express interest in a property, we may share your contact details with the respective property owner or real estate agent.\n'
            '• Legal Requirements: We may disclose your information if required to do so by law or in response to valid requests by public authorities (e.g., a court or government agency).',
      },
      {
        'title': '5. Cookies and Tracking Technologies',
        'icon': Icons.cookie_outlined,
        'content': 'We use cookies, web beacons, tracking pixels, and other tracking technologies to customize our Platform and improve your experience. Cookies are small files stored on your device that help us remember your preferences and understand how you interact with our website. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent, though some parts of the Service may not function properly without them.',
      },
      {
        'title': '6. Data Security',
        'icon': Icons.security_outlined,
        'content': 'We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse.',
      },
      {
        'title': '7. Data Retention',
        'icon': Icons.storage_outlined,
        'content': 'We will retain your personal information only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use your information to the extent necessary to comply with our legal obligations, resolve disputes, and enforce our policies.',
      },
      {
        'title': '8. Your Privacy Rights',
        'icon': Icons.verified_user_outlined,
        'content': 'Depending on your location, you may have the right to:\n\n'
            '• Request access to the personal data we hold about you.\n'
            '• Request that we correct inaccuracies or update your data.\n'
            '• Request the deletion of your personal data.\n'
            '• Object to or restrict the processing of your personal information.\n'
            'To exercise any of these rights, please contact us using the details provided below.',
      },
      {
        'title': '9. Third-Party Links',
        'icon': Icons.link_outlined,
        'content': 'Our website may contain links to third-party websites and applications of interest, including advertisements and external services, that are not affiliated with us. Once you have used these links to leave our site, any information you provide to these third parties is not covered by this Privacy Policy, and we cannot guarantee the safety and privacy of your data.',
      },
      {
        'title': '10. Children\'s Privacy',
        'icon': Icons.child_care_outlined,
        'content': 'Our Services are not intended for use by children under the age of 18. We do not knowingly solicit information from or market to children under 18. If we learn that we have collected personal information from a child under age 18 without verification of parental consent, we will delete that information as quickly as possible.',
      },
      {
        'title': '11. Changes to This Policy',
        'icon': Icons.edit_outlined, // Replaced edit_document_outlined with edit_outlined
        'content': 'We may update this Privacy Policy from time to time. The updated version will be indicated by an updated "Last Updated" date and the updated version will be effective as soon as it is accessible. We encourage you to review this Privacy Policy frequently to be informed of how we are protecting your information.',
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