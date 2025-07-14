  // /lib/screens/careers_screen.dart

  import 'package:flutter/material.dart';
  import 'package:flutter/foundation.dart' show kIsWeb; // Needed for kIsWeb
  import 'package:font_awesome_flutter/font_awesome_flutter.dart';
  import 'package:firebase_auth/firebase_auth.dart'; // Import for User type
  import 'package:sora_app/services/auth_service.dart'; // Import AuthService

  class CareersScreen extends StatefulWidget {
    final AuthService authService; // Receive AuthService to handle auth state

    const CareersScreen({super.key, required this.authService});

    @override
    State<CareersScreen> createState() => _CareersScreenState();
  }

  class _CareersScreenState extends State<CareersScreen> {
    final TextEditingController _newsletterEmailController = TextEditingController();
    String _currentListingTypeFilter = ''; // Needed for the common app bar buttons

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
        "description": "Connect clients with their ideal properties and guide them through the sales process.",
        "requirements": ["Proven sales track record", "Excellent communication skills", "Real estate license (preferred)"],
        "department": "Sales",
        "type": "Commission-based",
      },
      {
        "title": "Digital Marketing Specialist",
        "location": "Nairobi, Kenya (Remote)",
        "description": "Drive our online presence and lead generation through various digital channels.",
        "requirements": ["3+ years digital marketing experience", "SEO/SEM expertise", "Social media proficiency"],
        "department": "Marketing",
        "type": "Full-time",
      },
      {
        "title": "Property Valuation Analyst",
        "location": "Nairobi, Kenya (On-site)",
        "description": "Conduct property valuations and market analysis to support our listing and investment teams.",
        "requirements": ["Degree in Real Estate/Finance", "Valuation certification", "Analytical skills"],
        "department": "Valuation",
        "type": "Full-time",
      },
      {
        "title": "Customer Support Representative",
        "location": "Remote",
        "description": "Provide exceptional support to our clients, assisting with inquiries and platform navigation.",
        "requirements": ["Excellent communication", "Problem-solving ability", "Customer service experience"],
        "department": "Customer Service",
        "type": "Full-time",
      },
      {
        "title": "UI/UX Designer",
        "location": "Nairobi, Kenya (Hybrid)",
        "description": "Design intuitive and engaging user interfaces for our web and mobile platforms.",
        "requirements": ["3+ years UI/UX design", "Proficiency in Figma/Sketch", "Portfolio required"],
        "department": "Design",
        "type": "Full-time",
      },
      {
        "title": "Legal Counsel (Real Estate)",
        "location": "Nairobi, Kenya (On-site)",
        "description": "Provide legal advice and ensure compliance for all real estate transactions.",
        "requirements": ["Law degree", "Admitted to bar", "Experience in property law"],
        "department": "Legal",
        "type": "Full-time",
      },
      {
        "title": "Data Scientist",
        "location": "Remote",
        "description": "Analyze market trends and user behavior to inform business strategies and product development.",
        "requirements": ["Strong statistical skills", "Python/R proficiency", "Experience with large datasets"],
        "department": "Data Analytics",
        "type": "Full-time",
      },
    ];

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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Sign Up'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/signup'); // Navigate to signup screen
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A66C2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Login'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/signin'); // Navigate to signin screen
                },
              ),
            ],
          );
        },
      );
    }

    // Handles sign-out action, copied from home_screen.dart
    Future<void> _handleSignOut() async {
      try {
        await widget.authService.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully!')),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = "An unknown error occurred.";
        if (e.code == 'network-request-failed') {
          errorMessage =
              "Network error. Please check your internet connection and try again.";
        } else if (e.code == 'requires-recent-login') {
          errorMessage =
              "This operation is sensitive and requires recent authentication. Please log in again.";
        } else {
          errorMessage = "Sign out failed: ${e.message}";
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred during sign out: $e')),
          );
        }
      }
    }

    Widget _buildAppBarButton(String text, VoidCallback onPressed,
        {bool isSelected = false, bool isFilled = false, IconData? icon}) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isFilled
              ? const Color(0xFF0A66C2)
              : (isSelected ? const Color(0xFF1E90FF) : Colors.transparent),
          foregroundColor: isFilled
              ? Colors.white
              : (isSelected ? Colors.white : const Color(0xFF0A66C2)),
          elevation: isFilled ? 2 : 0,
          side: !isFilled
              ? const BorderSide(color: Color(0xFF0A66C2), width: 1)
              : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final bool isSmallScreen = screenWidth < 600;
      final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
      final bool isLargeScreen = screenWidth >= 1000;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: isLargeScreen ? 60.0 : 16.0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/home'); // Navigate back to home
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/sora_logo.png',
                        height: 45,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF1E90FF),
                            child: const Center(
                              child: Icon(Icons.home, size: 45, color: Color(0xFF0A66C2)), // Fallback icon
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'SORA',
                        style: TextStyle(
                          color: Color(0xFF0A66C2),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLargeScreen)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildAppBarButton(
                            'Buy',
                                () {
                              Navigator.pushNamed(
                                context,
                                '/property_listings',
                                arguments: {'listingType': 'Buy'},
                              );
                            },
                            isSelected: _currentListingTypeFilter == 'Buy',
                          ),
                          const SizedBox(width: 20),
                          _buildAppBarButton(
                            'Rent',
                                () {
                              Navigator.pushNamed(
                                context,
                                '/property_listings',
                                arguments: {'listingType': 'Rent'},
                              );
                            },
                            isSelected: _currentListingTypeFilter == 'Rent',
                          ),
                          const SizedBox(width: 20),
                          _buildAppBarButton(
                            'Lease',
                                () {
                              Navigator.pushNamed(
                                context,
                                '/property_listings',
                                arguments: {'listingType': 'Lease'},
                              );
                            },
                          ),
                          const SizedBox(width: 40),
                          const SizedBox(width: 20), // Adjusted spacing after removing search bar
                          _buildAppBarButton('List Property', () {
                            if (widget.authService.currentUserNotifier.value == null) {
                              _showLoginSignupDialog();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Redirecting to list property page (coming soon)!')),
                              );
                            }
                          }, isFilled: true),
                          const SizedBox(width: 20),
                          ValueListenableBuilder<User?>(
                            valueListenable: widget.authService.currentUserNotifier,
                            builder: (context, user, child) {
                              if (user != null) {
                                return PopupMenuButton<int>(
                                  icon: CircleAvatar(
                                    backgroundColor: const Color(0xFF0A66C2),
                                    radius: 20,
                                    child: (user.email != null && user.email!.isNotEmpty)
                                        ? Text(
                                            user.email![0].toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          )
                                        : const Icon(Icons.person, color: Colors.white),
                                  ),
                                  onSelected: (item) {
                                    if (item == 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Viewing profile for ${user.email ?? "User"}')),
                                      );
                                    } else if (item == 1) {
                                      _handleSignOut();
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem<int>(
                                      value: 0,
                                      child: Text('View Profile'),
                                    ),
                                    const PopupMenuItem<int>(
                                      value: 1,
                                      child: Text('Sign Out'),
                                    ),
                                  ],
                                );
                              } else {
                                return _buildAppBarButton('Login', () {
                                  Navigator.pushNamed(context, '/signin');
                                }, icon: Icons.login);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            actions: !isLargeScreen
                ? [
                    Builder(
                      builder: (BuildContext innerContext) {
                        return IconButton(
                          icon: const Icon(Icons.menu, color: Color(0xFF0A66C2)),
                          onPressed: () {
                            Scaffold.of(innerContext).openEndDrawer();
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ]
                : null,
          ),
        ),
        endDrawer: !isLargeScreen
            ? Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A66C2), Color(0xFF1E90FF)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'SORA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Color(0xFF0A66C2)),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Color(0xFF0A66C2)),
                title: const Text('Buy'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/property_listings',
                    arguments: {'listingType': 'Buy'},
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.key, color: Color(0xFF0A66C2)),
                title: const Text('Rent'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/property_listings',
                    arguments: {'listingType': 'Rent'},
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.business, color: Color(0xFF0A66C2)),
                title: const Text('Lease'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/property_listings',
                    arguments: {'listingType': 'Lease'},
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_home, color: Color(0xFF0A66C2)),
                title: const Text('List Property'),
                onTap: () {
                  if (widget.authService.currentUserNotifier.value == null) {
                    _showLoginSignupDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Redirecting to list property page (coming soon)!')),
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info, color: Color(0xFF0A66C2)),
                title: const Text('About'),
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
              ListTile(
                leading: const Icon(Icons.people, color: Color(0xFF0A66C2)),
                title: const Text('Agents'),
                onTap: () {
                  Navigator.pushNamed(context, '/agents');
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail, color: Color(0xFF0A66C2)),
                title: const Text('Contact'),
                onTap: () {
                  Navigator.pushNamed(context, '/contact');
                },
              ),
              ListTile(
                leading: const Icon(Icons.work, color: Color(0xFF0A66C2)),
                title: const Text('Careers'),
                onTap: () {
                  Navigator.pushNamed(context, '/careers');
                },
              ),
              ListTile(
                leading: const Icon(Icons.article, color: Color(0xFF0A66C2)),
                title: const Text('Blog'),
                onTap: () {
                  Navigator.pushNamed(context, '/blogs');
                },
              ),
              const Divider(),
              ValueListenableBuilder<User?>(
                valueListenable: widget.authService.currentUserNotifier,
                builder: (context, user, child) {
                  if (user != null) {
                    return ListTile(
                      leading: const Icon(Icons.logout, color: Color(0xFF0A66C2)),
                      title: const Text('Sign Out'),
                      onTap: () {
                        _handleSignOut();
                      },
                    );
                  } else {
                    return ListTile(
                      leading: const Icon(Icons.login, color: Color(0xFF0A66C2)),
                      title: const Text('Login'),
                      onTap: () {
                        Navigator.pushNamed(context, '/signin');
                      },
                    );
                  }
                },
              ),
            ],
          ),
        )
            : null,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                height: isSmallScreen ? 300 : 400,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A66C2), Color(0xFF1E90FF)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Join Our Team',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 32 : 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Build the future of real estate with us',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 24,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Job Openings Section
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Openings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Job Openings Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSmallScreen ? 1 : (isMediumScreen ? 2 : 3),
                        childAspectRatio: isSmallScreen ? 1.2 : 0.9,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _jobOpenings.length,
                      itemBuilder: (context, index) {
                        final job = _jobOpenings[index];
                        return _buildJobCard(job);
                      },
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Why Join Us Section
                    const Text(
                      'Why Join SORA?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Benefits Grid
                    isLargeScreen
                        ? Row(
                            children: [
                              Expanded(child: _buildBenefitCard(Icons.trending_up, 'Growth', 'Opportunities for professional development and career advancement')),
                              const SizedBox(width: 16),
                              Expanded(child: _buildBenefitCard(Icons.work_outline, 'Flexibility', 'Remote work options and flexible scheduling')),
                              const SizedBox(width: 16),
                              Expanded(child: _buildBenefitCard(Icons.people, 'Team', 'Work with passionate professionals in a collaborative environment')),
                            ],
                          )
                        : Column(
                            children: [
                              _buildBenefitCard(Icons.trending_up, 'Growth', 'Opportunities for professional development and career advancement'),
                              const SizedBox(height: 16),
                              _buildBenefitCard(Icons.work_outline, 'Flexibility', 'Remote work options and flexible scheduling'),
                              const SizedBox(height: 16),
                              _buildBenefitCard(Icons.people, 'Team', 'Work with passionate professionals in a collaborative environment'),
                            ],
                          ),
                  ],
                ),
              ),

              // Footer
              Container(
                width: double.infinity,
                color: const Color(0xFF0A66C2),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: [
                    // Footer Content
                    isLargeScreen
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo and Description
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SORA',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Your trusted partner in finding the perfect property across Africa.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Social Media Icons
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.white),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const FaIcon(FontAwesomeIcons.linkedin, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Quick Links
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Quick Links',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildFooterLink('Home', () => Navigator.pushNamed(context, '/home')),
                                    _buildFooterLink('About', () => Navigator.pushNamed(context, '/about')),
                                    _buildFooterLink('Agents', () => Navigator.pushNamed(context, '/agents')),
                                    _buildFooterLink('Contact', () => Navigator.pushNamed(context, '/contact')),
                                    _buildFooterLink('Careers', () => Navigator.pushNamed(context, '/careers')),
                                    _buildFooterLink('Blog', () => Navigator.pushNamed(context, '/blogs')),
                                  ],
                                ),
                              ),

                              // Properties
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Properties',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildFooterLink('Buy Property', () => Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Buy'})),
                                    _buildFooterLink('Rent Property', () => Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Rent'})),
                                    _buildFooterLink('Lease Property', () => Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Lease'})),
                                    _buildFooterLink('List Property', () {
                                      if (widget.authService.currentUserNotifier.value == null) {
                                        _showLoginSignupDialog();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Redirecting to list property page (coming soon)!')),
                                        );
                                      }
                                    }),
                                  ],
                                ),
                              ),

                              // Newsletter
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Newsletter',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Stay updated with the latest properties and market trends.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Newsletter signup
                                    TextField(
                                      controller: _newsletterEmailController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your email',
                                        hintStyle: const TextStyle(color: Colors.white70),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Handle newsletter signup
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Thank you for subscribing to our newsletter!')),
                                        );
                                        _newsletterEmailController.clear();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1E90FF),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Subscribe'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              // Mobile Footer Content
                              const Text(
                                'SORA',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Your trusted partner in finding the perfect property across Africa.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),

                              // Mobile Quick Links
                              Wrap(
                                spacing: 20,
                                runSpacing: 10,
                                children: [
                                  _buildFooterLink('Home', () => Navigator.pushNamed(context, '/home')),
                                  _buildFooterLink('About', () => Navigator.pushNamed(context, '/about')),
                                  _buildFooterLink('Agents', () => Navigator.pushNamed(context, '/agents')),
                                  _buildFooterLink('Contact', () => Navigator.pushNamed(context, '/contact')),
                                  _buildFooterLink('Careers', () => Navigator.pushNamed(context, '/careers')),
                                  _buildFooterLink('Blog', () => Navigator.pushNamed(context, '/blogs')),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Mobile Social Media Icons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.white),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const FaIcon(FontAwesomeIcons.linkedin, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),

                    const SizedBox(height: 30),
                    const Divider(color: Colors.white30),
                    const SizedBox(height: 20),

                    // Copyright
                    Text(
                      '© 2025 SORA. All rights reserved.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildJobCard(Map<String, dynamic> job) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A66C2),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job['location'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A66C2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      job['type'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0A66C2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E90FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      job['department'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E90FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Text(
                'Requirements:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A66C2),
                ),
              ),
              const SizedBox(height: 4),
              ...job['requirements'].take(2).map<Widget>((req) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '• $req',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ).toList(),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Application for ${job['title']} coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A66C2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 36),
                ),
                child: const Text('Apply Now'),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildBenefitCard(IconData icon, String title, String description) {
      return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFF0A66C2),
            ),
            const SizedBox(height: 12),
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
      );
    }

    Widget _buildFooterLink(String text, VoidCallback onPressed) {
      return GestureDetector(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    }
  }
