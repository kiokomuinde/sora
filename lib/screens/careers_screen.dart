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

  class _CareersScreenState extends State<CareersScreen> {
    final TextEditingController _newsletterEmailController = TextEditingController();
    String _currentListingTypeFilter = ''; // Needed for the common app bar buttons
    late CommonWidgets commonWidgets; // Declare commonWidgets

    // Mock job data for the grid view
    final List<Map<String, dynamic>> _jobOpenings = [
      {
        "title": "Senior Software Engineer (Flutter)",
        "location": "Nairobi, Kenya (Hybrid)",
        "description": "Develop and maintain our cutting-edge mobile and web applications using Flutter.",
        "requirements": ["5+ years Flutter experience", "Firebase knowledge", "Strong problem-solving skills"],
        "department": "Engineering",
        "type": "Full-time",
      },
      {
        "title": "Real Estate Agent (Sales)",
        "location": "Various Locations, Kenya",
        "description": "Drive property sales and rentals, build client relationships, and expand our market presence.",
        "requirements": ["2+ years real estate sales", "Valid real estate license", "Excellent communication"],
        "department": "Sales",
        "type": "Full-time (Commission-based)",
      },
      {
        "title": "Digital Marketing Specialist",
        "location": "Remote (Kenya)",
        "description": "Plan and execute digital marketing campaigns to enhance brand visibility and lead generation.",
        "requirements": ["3+ years digital marketing", "SEO/SEM expertise", "Social media proficiency"],
        "department": "Marketing",
        "type": "Full-time",
      },
      {
        "title": "Customer Support Representative",
        "location": "Nairobi, Kenya",
        "description": "Provide exceptional support to our clients, addressing inquiries and resolving issues promptly.",
        "requirements": ["1+ year customer service", "Strong problem-solving", "Excellent communication"],
        "department": "Customer Service",
        "type": "Full-time",
      },
      {
        "title": "Property Valuer",
        "location": "Nairobi, Kenya",
        "description": "Conduct property valuations for various purposes, including sales, rentals, and investment analysis.",
        "requirements": ["Certified Valuer", "3+ years experience", "Strong analytical skills"],
        "department": "Valuation",
        "type": "Full-time",
      },
      {
        "title": "Intern (Real Estate Operations)",
        "location": "Nairobi, Kenya",
        "description": "Gain hands-on experience in real estate operations, assisting with property management and client relations.",
        "requirements": ["Currently pursuing a degree in Real Estate/Business", "Strong organizational skills"],
        "department": "Operations",
        "type": "Internship",
      },
    ];

    @override
    void initState() {
      super.initState();
      commonWidgets = CommonWidgets(context: context, authService: widget.authService); // Initialize commonWidgets
    }

    @override
    void dispose() {
      _newsletterEmailController.dispose();
      super.dispose();
    }

    // Common dialog for login/signup prompt, copied from home_screen.dart
    void _showLoginSignupDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text(
              'Login or Sign Up Required',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A66C2),
              ),
            ),
            content: const Text(
              'Please log in or create an account to proceed with this action.',
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E90FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Login / Sign Up'),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss dialog
                  Navigator.pushNamed(context, '/signin'); // Navigate to sign-in
                },
              ),
            ],
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final bool isLargeScreen = screenWidth >= 1000;
      final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

      return Scaffold(
        appBar: commonWidgets.buildAppBar(
          currentListingTypeFilter: _currentListingTypeFilter,
        ),
        endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Careers Header Section
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
                      'Careers at SORA',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 20 : 10),
                    Text(
                      'Join our dynamic team and build a rewarding career in real estate.',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Why Join Us Section
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 60 : 30,
                  horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why Join SORA?',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A66C2),
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 20 : 15),
                    _buildBenefitCard(
                      Icons.trending_up,
                      'Growth Opportunities',
                      'We invest in our employees\' professional development and offer clear paths for career advancement.',
                    ),
                    _buildBenefitCard(
                      Icons.lightbulb_outline,
                      'Innovative Environment',
                      'Work with cutting-edge technology and be part of a team that\'s shaping the future of real estate.',
                    ),
                    _buildBenefitCard(
                      Icons.diversity_3,
                      'Collaborative Culture',
                      'Join a supportive and inclusive team where collaboration and mutual respect are highly valued.',
                    ),
                    _buildBenefitCard(
                      Icons.star,
                      'Competitive Compensation',
                      'Enjoy attractive remuneration packages and performance-based incentives.',
                    ),
                  ],
                ),
              ),

              // Current Openings Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 60 : 30,
                  horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                ),
                color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Job Openings',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A66C2),
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 30 : 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
                        crossAxisSpacing: isLargeScreen ? 30 : 20,
                        mainAxisSpacing: isLargeScreen ? 30 : 20,
                        childAspectRatio: isLargeScreen ? 0.9 : (isMediumScreen ? 0.85 : 1.0),
                      ),
                      itemCount: _jobOpenings.length,
                      itemBuilder: (context, index) {
                        final job = _jobOpenings[index];
                        return _buildJobCard(job, isLargeScreen, isMediumScreen);
                      },
                    ),
                  ],
                ),
              ),

              // Application Process Section
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 60 : 30,
                  horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application Process',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A66C2),
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 20 : 15),
                    _buildProcessStep(
                      1,
                      'Browse Openings',
                      'Explore our current job openings and find a role that matches your skills and aspirations.',
                      isLargeScreen,
                      isMediumScreen,
                    ),
                    _buildProcessStep(
                      2,
                      'Submit Application',
                      'Complete our online application form and upload your resume and cover letter.',
                      isLargeScreen,
                      isMediumScreen,
                    ),
                    _buildProcessStep(
                      3,
                      'Interview Process',
                      'Qualified candidates will be invited for interviews to assess their fit with our team and values.',
                      isLargeScreen,
                      isMediumScreen,
                    ),
                    _buildProcessStep(
                      4,
                      'Offer & Onboarding',
                      'Successful candidates will receive an offer and begin their exciting journey with SORA Properties.',
                      isLargeScreen,
                      isMediumScreen,
                    ),
                  ],
                ),
              ),

              // Newsletter Signup Section (from original footer, adapted)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 60 : 30,
                  horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                ),
                color: const Color(0xFFF0F2F5), // Light grey background
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Stay Updated with SORA News',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A66C2),
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 20 : 15),
                    Text(
                      'Subscribe to our newsletter for the latest property listings, market insights, and exclusive offers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 30 : 20),
                    Container(
                      constraints: BoxConstraints(maxWidth: isLargeScreen ? 500 : double.infinity),
                      child: TextField(
                        controller: _newsletterEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_newsletterEmailController.text.isNotEmpty && _newsletterEmailController.text.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Subscribed with ${_newsletterEmailController.text}!')),
                          );
                          _newsletterEmailController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid email address.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E90FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Subscribe'),
                    ),
                  ],
                ),
              ),

              // Footer
              commonWidgets.buildFooter(),
            ],
          ),
        ),
      );
    }

    Widget _buildBenefitCard(IconData icon, String title, String description) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFF1E90FF),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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

    Widget _buildJobCard(Map<String, dynamic> job, bool isLargeScreen, bool isMediumScreen) {
      return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job['title']!,
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : (isMediumScreen ? 18 : 16),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A66C2),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job['location']!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job['department']!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.work, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job['type']!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                job['description']!,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: isLargeScreen ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),
              // Display requirements
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requirements:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  ... (job['requirements'] as List<String>).map((req) => Text(
                    '• $req',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )).toList(),
                ],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Applying for ${job['title']}... (Feature coming soon!)')),
                    );
                    // In a real app, this would navigate to an application form
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Apply Now'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildProcessStep(int step, String title, String description, bool isLargeScreen, bool isMediumScreen) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isLargeScreen ? 50 : 40,
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
