// /lib/screens/agents_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for kIsWeb
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import for Font Awesome icons
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type
import 'package:sora_app/services/auth_service.dart'; // Import AuthService

class AgentsScreen extends StatefulWidget {
  final AuthService authService; // Receive AuthService to handle auth state

  const AgentsScreen({super.key, required this.authService});

  @override
  State<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends State<AgentsScreen> {
  final TextEditingController _newsletterEmailController = TextEditingController();

  // This variable is used by the common AppBar button, even if not directly
  // filtering content on this screen. It needs to be present for the button helper.
  String _currentListingTypeFilter = '';

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
                        // Search bar is omitted as it's not directly needed on Agents screen,
                        // but if a global search is desired, it could be re-added.
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
              height: 100.0,
              decoration: const BoxDecoration(
                color: Color(0xFF1E90FF),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ValueListenableBuilder<User?>(
                    valueListenable: widget.authService.currentUserNotifier,
                    builder: (context, user, child) {
                      return Text(
                        user != null ? 'Hello, ${user.email?.split('@').first ?? "User"}' : 'SORA Menu',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Builder(
              builder: (BuildContext innerContext) {
                return ListTile(
                  title: const Text('Buy'),
                  onTap: () {
                    Scaffold.of(innerContext).closeEndDrawer();
                    Navigator.pushNamed(
                      innerContext,
                      '/property_listings',
                      arguments: {'listingType': 'Buy'},
                    );
                  },
                );
              },
            ),
            Builder(
              builder: (BuildContext innerContext) {
                return ListTile(
                  title: const Text('Rent'),
                  onTap: () {
                    Scaffold.of(innerContext).closeEndDrawer();
                    Navigator.pushNamed(
                      innerContext,
                      '/property_listings',
                      arguments: {'listingType': 'Rent'},
                    );
                  },
                );
              },
            ),
            Builder(
              builder: (BuildContext innerContext) {
                return ListTile(
                  title: const Text('Lease'),
                  onTap: () {
                    Scaffold.of(innerContext).closeEndDrawer();
                    Navigator.pushNamed(
                      innerContext,
                      '/property_listings',
                      arguments: {'listingType': 'Lease'},
                    );
                  },
                );
              },
            ),
            Builder(
              builder: (BuildContext innerContext) {
                return ListTile(
                  title: const Text('Sell'),
                  onTap: () {
                    Scaffold.of(innerContext).closeEndDrawer();
                    if (widget.authService.currentUserNotifier.value == null) {
                      _showLoginSignupDialog();
                    } else {
                      ScaffoldMessenger.of(innerContext).showSnackBar(
                        const SnackBar(content: Text('Redirecting to sell property page (coming soon)!')),
                      );
                    }
                  },
                );
              },
            ),
            ListTile(
              title: const Text('Agents'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/agents');
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/about');
              },
            ),
            ListTile(
              title: const Text('Contact'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/contact');
              },
            ),
            ListTile(
              title: const Text('Careers'), // Added Careers link
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/careers');
              },
            ),
            ValueListenableBuilder<User?>(
              valueListenable: widget.authService.currentUserNotifier,
              builder: (context, user, child) {
                if (user != null) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0A66C2),
                      child: (user.email != null && user.email!.isNotEmpty)
                          ? Text(
                              user.email![0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            )
                          : const Icon(Icons.person, color: Colors.white),
                    ),
                    title: const Text('Logout'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      _handleSignOut();
                    },
                  );
                } else {
                  return ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Login'),
                    onTap: () {
                      Navigator.of(context).pop();
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
            // Main content for the Agents Screen
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meet Our Agents',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Our team of dedicated real estate professionals is here to help you find your perfect property or sell your current one. Get to know them!',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Example Agent Grid (you can expand this with actual agent data)
                  _buildAgentGrid(isLargeScreen: isLargeScreen, isMediumScreen: isMediumScreen, isSmallScreen: isSmallScreen),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- Footer ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 24.0),
              color: Colors.grey[100],
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isLargeScreen ? 1200 : (isMediumScreen ? 800 : double.infinity)),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 40.0,
                      runSpacing: 20.0,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFooterColumn('Sora', ['About', 'Agents', 'Contact', 'Careers', 'Blog', 'Testimonials'],
                          onLinkTapped: (linkText) {
                            if (linkText == 'About') {
                              Navigator.pushNamed(context, '/about');
                            } else if (linkText == 'Agents') {
                              Navigator.pushNamed(context, '/agents');
                            } else if (linkText == 'Contact') {
                              Navigator.pushNamed(context, '/contact');
                            } else if (linkText == 'Careers') { // Added Careers link
                              Navigator.pushNamed(context, '/careers');
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$linkText functionality coming soon!')),
                              );
                            }
                          },
                        ),
                        _buildFooterColumn('Resources', ['Buy', 'Rent', 'Lease', 'FAQs', 'Support', 'Terms'],
                          onLinkTapped: (linkText) {
                            if (linkText == 'Buy') {
                              Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Buy'});
                            } else if (linkText == 'Rent') {
                              Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Rent'});
                            } else if (linkText == 'Lease') {
                              Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Lease'});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$linkText functionality coming soon!')),
                              );
                            }
                          },
                        ),
                        _buildFooterColumn('Community', ['Local Guides', 'Events'],
                          onLinkTapped: (linkText) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$linkText functionality coming soon!')),
                            );
                          },
                        ),
                        _buildFooterColumn('Legal', ['Privacy Policy', 'Terms of Service', 'Sitemap'],
                          onLinkTapped: (linkText) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$linkText functionality coming soon!')),
                            );
                          },
                        ),
                        _buildNewsletterSection(),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(FontAwesomeIcons.facebookF, 'Facebook', const Color(0xFF1877F2)),
                        const SizedBox(width: 20),
                        _buildSocialIcon(FontAwesomeIcons.discord, 'Discord', const Color(0xFF5865F2)),
                        const SizedBox(width: 20),
                        _buildSocialIcon(FontAwesomeIcons.linkedinIn, 'LinkedIn', const Color(0xFF0A66C2)),
                        const SizedBox(width: 20),
                        _buildSocialIcon(FontAwesomeIcons.instagram, 'Instagram', const Color(0xFFE1306C)),
                        const SizedBox(width: 20),
                        _buildSocialIcon(FontAwesomeIcons.tiktok, 'TikTok', Colors.black),
                        const SizedBox(width: 20),
                        _buildSocialIcon(FontAwesomeIcons.xTwitter, 'X (Twitter)', Colors.black),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    Text(
                      '© 2025 SORA Properties. All rights reserved.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for AppBar buttons
  Widget _buildAppBarButton(String text, VoidCallback onPressed, {bool isSelected = false, bool isFilled = false, IconData? icon}) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : const Color(0xFF0A66C2),
        backgroundColor: isSelected ? const Color(0xFF0A66C2) : (isFilled ? const Color(0xFF0A66C2) : Colors.transparent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: isFilled ? BorderSide.none : const BorderSide(color: Color(0xFF0A66C2), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: isSelected || isFilled ? Colors.white : const Color(0xFF0A66C2)),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected || isFilled ? FontWeight.bold : FontWeight.normal,
              color: isSelected || isFilled ? Colors.white : const Color(0xFF0A66C2),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for Footer columns
  Widget _buildFooterColumn(String title, List<String> links, {ValueChanged<String>? onLinkTapped}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A66C2),
          ),
        ),
        const SizedBox(height: 10),
        ...links.where((link) => link != 'Sell').map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () {
              if (onLinkTapped != null) {
                // Specific navigation for 'About', 'Agents', 'Contact', 'Careers'
                if (link == 'About') {
                  Navigator.pushNamed(context, '/about');
                } else if (link == 'Agents') {
                  Navigator.pushNamed(context, '/agents');
                } else if (link == 'Contact') {
                  Navigator.pushNamed(context, '/contact');
                } else if (link == 'Careers') { // Added Careers link
                  Navigator.pushNamed(context, '/careers');
                }
                // Navigation for property listing types
                else if (link == 'Buy') {
                  Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Buy'});
                } else if (link == 'Rent') {
                  Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Rent'});
                } else if (link == 'Lease') {
                  Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Lease'});
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$link functionality coming soon!')),
                  );
                }
              }
            },
            child: Text(
              link,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        )).toList(),
      ],
    );
  }

  // Helper method for Newsletter section in Footer
  Widget _buildNewsletterSection() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscribe to our Newsletter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newsletterEmailController,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
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
    );
  }

  // Helper method for Social Icons in Footer
  Widget _buildSocialIcon(IconData icon, String socialMediaName, Color color) {
    return IconButton(
      icon: FaIcon(icon, size: 28, color: color),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $socialMediaName...')),
        );
      },
      tooltip: 'Visit our $socialMediaName page',
    );
  }

  // Example Agent Grid layout
  Widget _buildAgentGrid({required bool isLargeScreen, required bool isMediumScreen, required bool isSmallScreen}) {
    final List<Map<String, String>> agents = [
      {
        "name": "Alice Johnson",
        "title": "Senior Real Estate Agent",
        "image": "assets/images/agent1.webp",
        "phone": "+123-456-7890",
        "email": "alice.j@sora.com",
      },
      {
        "name": "Bob Williams",
        "title": "Property Consultant",
        "image": "assets/images/agent2.webp",
        "phone": "+123-456-7891",
        "email": "bob.w@sora.com",
      },
      {
        "name": "Carol Davis",
        "title": "Luxury Property Specialist",
        "image": "assets/images/agent3.webp",
        "phone": "+123-456-7892",
        "email": "carol.d@sora.com",
      },
      {
        "name": "David Brown",
        "title": "Commercial Real Estate",
        "image": "assets/images/agent4.webp",
        "phone": "+123-456-7893",
        "email": "david.b@sora.com",
      },
      // Add more agents as needed
    ];

    int crossAxisCount;
    if (isLargeScreen) {
      crossAxisCount = 4;
    } else if (isMediumScreen) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the grid itself
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        childAspectRatio: isSmallScreen ? 0.8 : 0.75, // Adjust aspect ratio for different screen sizes
      ),
      itemCount: agents.length,
      itemBuilder: (context, index) {
        final agent = agents[index];
        return _buildAgentCard(agent);
      },
    );
  }

  Widget _buildAgentCard(Map<String, String> agent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
            child: Image.asset(
              agent['image']!,
              height: 180, // Fixed height for agent image
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.person, size: 80, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  agent['name']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A66C2),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  agent['title']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.phone, color: Color(0xFF1E90FF)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${agent['phone']}...')),
                        );
                        // Implement actual phone call logic here (e.g., using url_launcher)
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.email, color: Color(0xFF1E90FF)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Emailing ${agent['email']}...')),
                        );
                        // Implement actual email logic here (e.g., using url_launcher)
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
