// /lib/screens/careers_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for kIsWeb
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets

class CareersScreen extends StatefulWidget {
  final AuthService authService; // Receive AuthService to handle auth state

  const CareersScreen({super.key, required this.authService});

  @override
  State<CareersScreen> createState() => _CareersScreenState();
}

class _CareersScreenState extends State<CareersScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _newsletterEmailController = TextEditingController();
  String _currentListingTypeFilter = ''; // Needed for the common app bar buttons
  late CommonWidgets commonWidgets; // Declare commonWidgets

  // Animation controller for passing houses
  late AnimationController _houseController;

  // Mock job data for the grid view
  final List<Map<String, dynamic>> _jobOpenings = [
    {
      "title": "Senior Software Engineer (Flutter)",
      "location": "Nairobi, Kenya (Hybrid)",
      "description": "Develop and maintain our cutting-edge mobile and web applications using Flutter.",
      "requirements": ["5+ years Flutter experience", "Firebase knowledge", "Strong problem-solving skills"],
      "type": "Full-Time"
    },
    {
      "title": "Real Estate Sales Manager",
      "location": "Nairobi, Kenya",
      "description": "Lead our sales team to drive property sales and expand our market presence.",
      "requirements": ["Proven sales track record", "Leadership skills", "Real estate market knowledge"],
      "type": "Full-Time"
    },
    {
      "title": "Marketing Content Creator",
      "location": "Remote",
      "description": "Create engaging content for our social media, blog, and promotional materials.",
      "requirements": ["Strong writing skills", "Graphic design basics", "Understanding of SEO"],
      "type": "Part-Time"
    },
    {
      "title": "Property Manager",
      "location": "Mombasa, Kenya",
      "description": "Oversee the day-to-day operations of our managed properties in the coastal region.",
      "requirements": ["Property management experience", "Excellent communication", "Conflict resolution"],
      "type": "Full-Time"
    },
  ];

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    
    // Initialize house animation controller (25 seconds for a steady scrolling effect)
    _houseController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _houseController.dispose();
    _newsletterEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Match property listing background
      appBar: commonWidgets.buildAppBar(
        currentListingTypeFilter: _currentListingTypeFilter,
      ),
      endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Animated Hero Section
            _buildHeroSection(isLargeScreen, isMediumScreen, screenWidth),

            // 2. Introduction / Why Join Us
            _buildWhyJoinUsSection(isLargeScreen, isMediumScreen),

            // 3. Open Positions
            _buildOpenPositionsSection(isLargeScreen, isMediumScreen),

            // 4. How to Apply Process
            _buildHowToApplySection(isLargeScreen, isMediumScreen),

            // 5. Newsletter Signup (using standard style for consistency)
            _buildNewsletterSection(isLargeScreen, isMediumScreen),

            // 6. Footer
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI SECTIONS
  // ---------------------------------------------------------------------------

  Widget _buildHeroSection(bool isLargeScreen, bool isMediumScreen, double screenWidth) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF87CEEB), Color(0xFFE0F6FF)], // Soft sky gradient
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AnimatedBuilder(
        animation: _houseController,
        builder: (context, child) {
          return Stack(
            children: [
              // Passing Houses / Skyline
              Positioned(
                left: (screenWidth + 200) * _houseController.value - 200,
                bottom: -5,
                child: Icon(Icons.home, color: Colors.white.withOpacity(0.4), size: 80),
              ),
              Positioned(
                left: (screenWidth + 200) * ((_houseController.value + 0.25) % 1.0) - 200,
                bottom: -10,
                child: Icon(Icons.apartment, color: Colors.white.withOpacity(0.5), size: 130),
              ),
              Positioned(
                left: (screenWidth + 200) * ((_houseController.value + 0.5) % 1.0) - 200,
                bottom: -5,
                child: Icon(Icons.house_siding, color: Colors.white.withOpacity(0.3), size: 100),
              ),
              Positioned(
                left: (screenWidth + 200) * ((_houseController.value + 0.75) % 1.0) - 200,
                bottom: -10,
                child: Icon(Icons.location_city, color: Colors.white.withOpacity(0.45), size: 110),
              ),
              // Header Content
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 50 : (isMediumScreen ? 35 : 20),
                  horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Careers at SORA',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0A66C2), // Darker text for light background
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 15 : 10),
                    Text(
                      'Join our team and help build the future of real estate.',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                        color: Colors.blueGrey[800], // Darker text for readability
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWhyJoinUsSection(bool isLargeScreen, bool isMediumScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 80 : 50,
        horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
      ),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Why Work With Us?',
            style: TextStyle(
              fontSize: isLargeScreen ? 36 : (isMediumScreen ? 30 : 24),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A66C2),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLargeScreen ? 50 : 30),
          Flex(
            direction: isLargeScreen ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBenefitItem(
                Icons.trending_up,
                'Growth Opportunities',
                'We invest in our people with continuous learning and career advancement paths.',
                isLargeScreen,
                isMediumScreen,
              ),
              if (!isLargeScreen) SizedBox(height: 30),
              _buildBenefitItem(
                Icons.diversity_3,
                'Inclusive Culture',
                'A collaborative environment where every voice is heard and valued.',
                isLargeScreen,
                isMediumScreen,
              ),
              if (!isLargeScreen) SizedBox(height: 30),
              _buildBenefitItem(
                Icons.lightbulb_outline,
                'Innovative Tech',
                'Work with modern tools like Flutter, Firebase, and AI to revolutionize real estate.',
                isLargeScreen,
                isMediumScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description, bool isLargeScreen, bool isMediumScreen) {
    return Expanded(
      flex: isLargeScreen ? 1 : 0,
      child: Container(
        padding: EdgeInsets.all(isLargeScreen ? 20 : 10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFE0F6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Color(0xFF1E90FF)),
            ),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenPositionsSection(bool isLargeScreen, bool isMediumScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 80 : 50,
        horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
      ),
      child: Column(
        children: [
          Text(
            'Current Openings',
            style: TextStyle(
              fontSize: isLargeScreen ? 36 : (isMediumScreen ? 30 : 24),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A66C2),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Text(
            'Find your next role at SORA Properties.',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLargeScreen ? 50 : 30),
          
          // Job Listings Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Let the outer scroll view handle scrolling
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLargeScreen ? 2 : 1, // 2 columns on desktop, 1 on mobile/tablet
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
              childAspectRatio: isLargeScreen ? 1.8 : (isMediumScreen ? 2.5 : 1.2), // Adjust heights
            ),
            itemCount: _jobOpenings.length,
            itemBuilder: (context, index) {
              final job = _jobOpenings[index];
              return _buildJobCard(job, isLargeScreen, isMediumScreen);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, bool isLargeScreen, bool isMediumScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: EdgeInsets.all(isLargeScreen ? 30 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job['title'],
                  style: TextStyle(
                    fontSize: isLargeScreen ? 22 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFE0F6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  job['type'],
                  style: TextStyle(
                    color: Color(0xFF1E90FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
              SizedBox(width: 5),
              Text(
                job['location'],
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            job['description'],
            style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Spacer(),
          Divider(color: Colors.grey[200]),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _showJobDetailsModal(job);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1E90FF),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View Details & Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showJobDetailsModal(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 600, // Max width for the dialog
            padding: EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          job['title'],
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                      SizedBox(width: 5),
                      Text(job['location'], style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                      SizedBox(width: 20),
                      Icon(Icons.work, size: 18, color: Colors.grey[600]),
                      SizedBox(width: 5),
                      Text(job['type'], style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(job['description'], style: TextStyle(fontSize: 16, height: 1.5)),
                  SizedBox(height: 20),
                  Text('Key Requirements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ...List.generate((job['requirements'] as List).length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, size: 20, color: Color(0xFF1E90FF)),
                          SizedBox(width: 10),
                          Expanded(child: Text(job['requirements'][index], style: TextStyle(fontSize: 16))),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                         Navigator.of(context).pop();
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Application feature coming soon! Please email your CV to soraproperties002@gmail.com'))
                         );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E90FF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text('Apply Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHowToApplySection(bool isLargeScreen, bool isMediumScreen) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 80 : 50,
        horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
      ),
      child: Column(
        children: [
          Text(
            'Our Hiring Process',
            style: TextStyle(
              fontSize: isLargeScreen ? 36 : (isMediumScreen ? 30 : 24),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A66C2),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLargeScreen ? 50 : 30),
          Flex(
            direction: isLargeScreen ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: isLargeScreen ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              _buildProcessStep(1, 'Apply', 'Submit your CV and cover letter online.', isLargeScreen, isMediumScreen),
              if (isLargeScreen) _buildProcessConnector(),
              _buildProcessStep(2, 'Review', 'Our HR team reviews your application.', isLargeScreen, isMediumScreen),
              if (isLargeScreen) _buildProcessConnector(),
              _buildProcessStep(3, 'Interview', 'Meet the team and show your skills.', isLargeScreen, isMediumScreen),
              if (isLargeScreen) _buildProcessConnector(),
              _buildProcessStep(4, 'Offer', 'Welcome to the SORA family!', isLargeScreen, isMediumScreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep(int step, String title, String description, bool isLargeScreen, bool isMediumScreen) {
    if (isLargeScreen) {
      return Expanded(
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF0A66C2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$step',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    } else {
      // Vertical layout for smaller screens
      return Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isLargeScreen ? 60 : 50,
              height: isLargeScreen ? 50 : 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0A66C2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$step',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isLargeScreen ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: isLargeScreen ? 20 : 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : (isMediumScreen ? 15 : 14),
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProcessConnector() {
    return Container(
      width: 50,
      height: 2,
      margin: EdgeInsets.only(top: 30), // Align with the center of the circles
      color: Colors.grey[300],
    );
  }

  Widget _buildNewsletterSection(bool isLargeScreen, bool isMediumScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 60 : 30,
        horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
      ),
      color: const Color(0xFFE0F6FF).withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Stay Updated with SORA Careers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A66C2),
            ),
          ),
          SizedBox(height: isLargeScreen ? 15 : 10),
          Text(
            'Subscribe to our newsletter to be the first to know about new job openings and company updates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
              color: Colors.blueGrey[700],
            ),
          ),
          SizedBox(height: isLargeScreen ? 30 : 20),
          Container(
            constraints: BoxConstraints(maxWidth: isLargeScreen ? 500 : double.infinity),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newsletterEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(30)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                    ),
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_newsletterEmailController.text.isNotEmpty && _newsletterEmailController.text.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Subscribed with ${_newsletterEmailController.text}!'))
                      );
                      _newsletterEmailController.clear();
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a valid email address.'))
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text('Subscribe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}