// lib/screens/faqs_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Corrected import

class FAQsScreen extends StatelessWidget { // Corrected class name to FAQsScreen
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
                  colors: [const Color(0xFF1E90FF).withOpacity(0.8), const Color(0xFF0A66C2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Text(
                'Frequently Asked Questions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // FAQs List Section
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return ExpansionTile(
                    title: Text(
                      faq['question']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          faq['answer']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, String>> faqs = [
  {
    'question': 'How do I list my property on SORA?',
    'answer': 'To list your property, you must first create an account and sign in. Once logged in, navigate to the "Add Property" page from your dashboard and fill in the required details about your property. Once submitted, our team will review the listing before it goes live.',
  },
  {
    'question': 'What kind of properties can I find on SORA?',
    'answer': 'SORA features a wide range of properties for sale, rent, and lease, including residential homes, apartments, commercial spaces, and land plots.',
  },
  {
    'question': 'How do I contact a property agent?',
    'answer': 'Each property listing includes contact details for the agent. You can either call them directly or use the contact form provided on the property details page to send an inquiry.',
  },
  {
    'question': 'Is SORA available on mobile?',
    'answer': 'Yes, SORA is a Flutter-based application that is designed to work seamlessly on both mobile (iOS and Android) and web platforms.',
  },
  {
    'question': 'How can I save my favorite properties?',
    'answer': 'You can save properties to your favorites by clicking the heart icon on any property card. You must be logged in to use this feature. Your favorites can be viewed from your user dashboard.',
  },
];