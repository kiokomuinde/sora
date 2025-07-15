// /lib/screens/contact_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for kIsWeb
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets

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
  late CommonWidgets commonWidgets; // Declare commonWidgets

  String _currentListingTypeFilter = ''; // Needed for the common app bar buttons

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService); // Initialize commonWidgets
  }

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

  void _submitContactForm() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    // Here you would typically send the form data to a backend service
    // For this example, we'll just show a success message.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message from ${_nameController.text} sent successfully!')),
    );

    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
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
            // Contact Header Section
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
                    'Contact Us',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'We\'re here to help! Reach out to us for any inquiries.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Contact Form and Info Section
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : 30,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: Flex(
                direction: isLargeScreen ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Form
                  Expanded(
                    flex: isLargeScreen ? 3 : 0,
                    child: Container(
                      padding: EdgeInsets.all(isLargeScreen ? 40 : 20),
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
                          Text(
                            'Send Us a Message',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 28 : (isMediumScreen ? 24 : 20),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0A66C2),
                            ),
                          ),
                          SizedBox(height: isLargeScreen ? 30 : 20),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              hintText: 'Enter your full name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                          SizedBox(height: isLargeScreen ? 20 : 15),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Your Email',
                              hintText: 'Enter your email address',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.email),
                            ),
                          ),
                          SizedBox(height: isLargeScreen ? 20 : 15),
                          TextField(
                            controller: _messageController,
                            maxLines: 6,
                            decoration: InputDecoration(
                              labelText: 'Your Message',
                              hintText: 'Type your message here...',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 100), // Adjust padding to align icon to top
                                child: Icon(Icons.message),
                              ),
                            ),
                          ),
                          SizedBox(height: isLargeScreen ? 30 : 20),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _submitContactForm,
                              icon: const Icon(Icons.send),
                              label: const Text('Send Message'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E90FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: isLargeScreen ? 40 : 0, height: isLargeScreen ? 0 : 30),
                  // Contact Info
                  Expanded(
                    flex: isLargeScreen ? 2 : 0,
                    child: Container(
                      padding: EdgeInsets.all(isLargeScreen ? 40 : 20),
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
                          Text(
                            'Our Contact Details',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 28 : (isMediumScreen ? 24 : 20),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0A66C2),
                            ),
                          ),
                          SizedBox(height: isLargeScreen ? 30 : 20),
                          _buildContactInfoItem(Icons.location_on, '123 Real Estate Avenue, Nairobi, Kenya'),
                          SizedBox(height: isLargeScreen ? 20 : 15),
                          _buildContactInfoItem(Icons.phone, '+254 712 345 678'),
                          SizedBox(height: isLargeScreen ? 20 : 15),
                          _buildContactInfoItem(Icons.email, 'info@sora.com'),
                          SizedBox(height: isLargeScreen ? 20 : 15),
                          _buildContactInfoItem(Icons.access_time, 'Monday - Friday: 9 AM - 5 PM EAT'),
                          SizedBox(height: isLargeScreen ? 30 : 20),
                          Text(
                            'Follow Us',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildSocialIcon(FontAwesomeIcons.facebookF, 'Facebook', const Color(0xFF1877F2)),
                              const SizedBox(width: 15),
                              _buildSocialIcon(FontAwesomeIcons.linkedinIn, 'LinkedIn', const Color(0xFF0A66C2)),
                              const SizedBox(width: 15),
                              _buildSocialIcon(FontAwesomeIcons.xTwitter, 'X (Twitter)', Colors.black),
                            ],
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildContactInfoItem(IconData icon, String title) {
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

  Widget _buildSocialIcon(IconData icon, String socialMediaName, Color color) {
    return IconButton(
      icon: FaIcon(icon, size: 28, color: color),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $socialMediaName page (link not active)')),
        );
      },
      tooltip: 'Visit our $socialMediaName page',
    );
  }
}
