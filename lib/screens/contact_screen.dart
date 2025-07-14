// /lib/screens/contact_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for kIsWeb
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type
import 'package:sora_app/services/auth_service.dart'; // Import AuthService

class ContactScreen extends StatefulWidget {
  final AuthService authService; // Receive AuthService to handle auth state

  const ContactScreen({super.key, required this.authService});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _newsletterEmailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _currentListingTypeFilter = ''; // Needed for the common app bar buttons

  @override
  void dispose() {
    _newsletterEmailController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
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

  void _submitContactForm() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message sent! We will get back to you shortly.')),
    );
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
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
                      'Get In Touch',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 32 : 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We\'re here to help you find your perfect property',
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

            // Contact Form and Info Section
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 32.0),
              child: isLargeScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Contact Form
                        Expanded(
                          flex: 2,
                          child: _buildContactForm(),
                        ),
                        const SizedBox(width: 32),
                        // Contact Info
                        Expanded(
                          child: _buildContactInfo(),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildContactForm(),
                        const SizedBox(height: 32),
                        _buildContactInfo(),
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

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(32),
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
          const Text(
            'Send us a Message',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Name Field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Your Name',
              hintText: 'Enter your full name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0A66C2)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          
          // Email Field
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Your Email',
              hintText: 'Enter your email address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0A66C2)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          
          // Message Field
          TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Your Message',
              hintText: 'Tell us how we can help you',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0A66C2)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 24),
          
          // Submit Button
          ElevatedButton(
            onPressed: _submitContactForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A66C2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              'Send Message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A66C2),
          ),
        ),
        const SizedBox(height: 24),
        
        // Address
        _buildContactInfoItem(
          Icons.location_on,
          'Address',
          'SORA Headquarters\n123 Real Estate Avenue\nNairobi, Kenya',
        ),
        const SizedBox(height: 20),
        
        // Phone
        _buildContactInfoItem(
          Icons.phone,
          'Phone',
          '+254 700 123 456\n+254 722 987 654',
        ),
        const SizedBox(height: 20),
        
        // Email
        _buildContactInfoItem(
          Icons.email,
          'Email',
          'info@sora.com\nsupport@sora.com',
        ),
        const SizedBox(height: 20),
        
        // Working Hours
        _buildContactInfoItem(
          Icons.access_time,
          'Working Hours',
          'Monday - Friday: 8:00 AM - 6:00 PM\nSaturday: 9:00 AM - 4:00 PM\nSunday: Closed',
        ),
        
        const SizedBox(height: 32),
        
        // Map placeholder
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 60,
                  color: Color(0xFF0A66C2),
                ),
                SizedBox(height: 8),
                Text(
                  'Find us on Map',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0A66C2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: const Color(0xFF0A66C2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
              const SizedBox(height: 4),
              Text(
                content,
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
