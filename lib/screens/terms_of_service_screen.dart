// lib/screens/terms_of_service_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';

class TermsOfServiceScreen extends StatelessWidget {
  final AuthService authService;

  const TermsOfServiceScreen({super.key, required this.authService});

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
                          Icons.gavel_rounded,
                          size: 300,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -40,
                        child: Icon(
                          Icons.description_outlined,
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
                          'LEGAL AGREEMENT',
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
                        'Terms of Service',
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
                        'Please read these terms carefully before using SORA.',
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
                                    'Still have questions? Contact our legal team at soraproperties002@gmail.com.',
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
        'content': 'Welcome to SORA Properties! These Terms of Service ("Terms") govern your access to and use of the SORA website, mobile applications, and real estate services (collectively, the "Service"). Please read these Terms carefully before using the Service. By accessing or using the Service, you agree to be bound by these Terms and our Privacy Policy. If you do not agree to these Terms, you may not use the Service.',
      },
      {
        'title': '2. Eligibility',
        'icon': Icons.verified_user_outlined,
        'content': 'You must be at least 18 years old to use the Service. By using the Service, you represent and warrant that you are at least 18 years old, possess the legal capacity to enter into binding contracts, and are not barred from receiving services under applicable laws.',
      },
      {
        'title': '3. Account Registration & Security',
        'icon': Icons.person_add_outlined,
        'content': 'To access certain features, such as saving favorite properties or communicating with agents, you must register for an account. You agree to provide accurate, current, and complete information during registration and to keep this information up to date. You are solely responsible for safeguarding your password and for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.',
      },
      {
        'title': '4. Fees and Payments',
        'icon': Icons.payment_outlined,
        'content': 'While browsing standard listings is free, SORA may charge fees for premium property listings, featured advertisements, or specific management services. All applicable fees will be clearly disclosed before you incur them. Payments are non-refundable unless otherwise explicitly stated in writing.',
      },
      {
        'title': '5. User Conduct',
        'icon': Icons.rule_outlined,
        'content': 'You agree to use the Service only for lawful purposes. You are strictly prohibited from:\n\n'
            '• Posting false, misleading, or fraudulent property listings or information;\n'
            '• Engaging in any form of harassment, hate speech, or discrimination against agents, owners, or other users;\n'
            '• Scraping, data mining, or extracting data from our Service without written consent;\n'
            '• Uploading viruses, malware, or attempting to compromise the security of the Service;\n'
            '• Impersonating any person or entity, or misrepresenting your affiliation with a person or entity.',
      },
      {
        'title': '6. Content and Property Listings',
        'icon': Icons.real_estate_agent_outlined,
        'content': 'SORA allows property owners and agents to post real estate listings. You represent and warrant that you own or have the necessary licenses and permissions to publish the content you submit. SORA does not guarantee the exact accuracy of measurements, property conditions, or availability. We reserve the right, but have no obligation, to review, edit, or remove any content that violates these Terms.',
      },
      {
        'title': '7. Intellectual Property',
        'icon': Icons.copyright_outlined,
        'content': 'All original content, features, and functionality of the Service—including text, graphics, logos, images, and software—are the exclusive property of SORA Properties and its licensors. They are protected by international copyright, trademark, patent, and other intellectual property laws. You may not reproduce, distribute, or create derivative works without our express permission.',
      },
      {
        'title': '8. Third-Party Links & Services',
        'icon': Icons.link_outlined,
        'content': 'Our Service may contain links to third-party websites, advertisers, or services that are not owned or controlled by SORA (e.g., mortgage calculators, external agency sites). We have no control over, and assume no responsibility for, the content, privacy policies, or practices of any third-party web sites or services.',
      },
      {
        'title': '9. Disclaimers',
        'icon': Icons.warning_amber_outlined,
        'content': 'The Service is provided on an "AS IS" and "AS AVAILABLE" basis. SORA makes no representations or warranties of any kind, express or implied, regarding the operation of the Service, or the information, content, or materials included. We do not warrant that the Service will be uninterrupted, secure, or error-free.',
      },
      {
        'title': '10. Limitation of Liability',
        'icon': Icons.shield_outlined,
        'content': 'To the maximum extent permitted by applicable law, in no event shall SORA Properties, its directors, employees, partners, or agents be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from (i) your access to or inability to access the Service; (ii) any conduct or content of any third party; or (iii) unauthorized access or alteration of your transmissions.',
      },
      {
        'title': '11. Dispute Resolution & Governing Law',
        'icon': Icons.balance_outlined,
        'content': 'These Terms shall be governed and construed in accordance with the laws of the Republic of Kenya, without regard to its conflict of law provisions. Any dispute arising from or relating to these Terms or the Service shall be subject to the exclusive jurisdiction of the courts located in Nairobi, Kenya.',
      },
      {
        'title': '12. Termination',
        'icon': Icons.cancel_outlined,
        'content': 'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms. Upon termination, your right to use the Service will immediately cease.',
      },
      {
        'title': '13. Changes to Terms',
        'icon': Icons.update_outlined,
        'content': 'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days\' notice prior to any new terms taking effect. By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms.',
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
              height: 1.7, // Increased line height for better readability
            ),
          ),
        ),
      ],
    );
  }
}