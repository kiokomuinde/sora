// lib/screens/testimonials_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Corrected import

class TestimonialsScreen extends StatelessWidget {
  final AuthService authService;

  const TestimonialsScreen({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Correctly instantiate CommonWidgets
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
            // Testimonials Header Section
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
                    'What Our Clients Say',
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
                    'Hear directly from those who found their dream properties with SORA.',
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

            // Testimonials Grid/List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;
                  if (constraints.maxWidth > 900) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: isLargeScreen ? 40 : 20,
                      mainAxisSpacing: isLargeScreen ? 40 : 20,
                      childAspectRatio: 1.0, // Adjust as needed for content
                    ),
                    itemCount: _testimonials.length,
                    itemBuilder: (context, index) {
                      return _buildTestimonialCard(_testimonials[index], isLargeScreen, isMediumScreen);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: isLargeScreen ? 60 : 30),
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, String> testimonial, bool isLargeScreen, bool isMediumScreen) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 30 : (isMediumScreen ? 20 : 15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.format_quote, size: isLargeScreen ? 60 : 40, color: Color(0xFF0A66C2).withOpacity(0.7)),
            SizedBox(height: isLargeScreen ? 20 : 10),
            Text(
              testimonial['quote']!,
              style: TextStyle(
                fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                fontStyle: FontStyle.italic,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isLargeScreen ? 20 : 10),
            CircleAvatar(
              radius: isLargeScreen ? 30 : 25,
              backgroundColor: Color(0xFF1E90FF),
              child: Text(
                testimonial['name']![0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isLargeScreen ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              testimonial['name']!,
              style: TextStyle(
                fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A66C2),
              ),
            ),
            Text(
              testimonial['location']!,
              style: TextStyle(
                fontSize: isLargeScreen ? 14 : (isMediumScreen ? 12 : 10),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample testimonial data
  static const List<Map<String, String>> _testimonials = [
    {
      'name': 'Alice Johnson',
      'location': 'New York, NY',
      'quote': 'SORA made finding our dream apartment effortless! Their agents were incredibly helpful and guided us every step of the way. Highly recommend!',
    },
    {
      'name': 'Bob Williams',
      'location': 'Los Angeles, CA',
      'quote': 'Selling our home through SORA was a breeze. The process was transparent, and we got a fantastic offer much faster than we expected. Thank you, SORA!',
    },
    {
      'name': 'Carol Davis',
      'location': 'Chicago, IL',
      'quote': 'As a first-time homebuyer, I was overwhelmed. SORA\'s resources and patient team made the journey enjoyable and stress-free. I\'m so happy in my new home!',
    },
    {
      'name': 'David Brown',
      'location': 'Houston, TX',
      'quote': 'The property listings on SORA are incredibly detailed and accurate. I found exactly what I was looking for without any hassle. A truly professional service.',
    },
    {
      'name': 'Eve Green',
      'location': 'Miami, FL',
      'quote': 'SORA\'s local guides provided invaluable insights into the neighborhoods we were considering. It helped us make a truly informed decision. Excellent service!',
    },
    {
      'name': 'Frank White',
      'location': 'Seattle, WA',
      'quote': 'I\'ve used several real estate platforms, but SORA stands out with its user-friendly interface and responsive support. Top-notch experience!',
    },
  ];
}
