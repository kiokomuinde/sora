// /lib/screens/contact_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  final AuthService authService;

  const ContactScreen({super.key, required this.authService});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newsletterEmailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  late CommonWidgets commonWidgets;

  String _currentListingTypeFilter = '';
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);

    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _newsletterEmailController.dispose();
    _nameController.dispose();
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    final bool isValid = email.contains('@') && email.endsWith('.com');
    if (_isEmailValid != isValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
  }

  void _showColoredSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _showLoginSignupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
            'Please log in or create an account to send a message.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
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
                Navigator.of(dialogContext).pop();
                Navigator.pushNamed(context, '/signin');
              },
            ),
          ],
        );
      },
    );
  }

  void _submitContactForm() async {
    if (widget.authService.getCurrentUser() == null) {
      _showLoginSignupDialog();
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (!_isEmailValid) {
        _showColoredSnackBar('Please enter a valid email address.', Colors.red);
        return;
      }
      try {
        final firestoreService = FirestoreService();
        final success = await firestoreService.addContactMessage(
          _nameController.text,
          _emailController.text,
          _messageController.text,
        );

        if (success) {
          _showColoredSnackBar('Message sent successfully!', Colors.green);
          _nameController.clear();
          _emailController.clear();
          _messageController.clear();
          _formKey.currentState!.reset();
          setState(() {
            _isEmailValid = false;
          });
        } else {
          _showColoredSnackBar('Failed to send message. Please try again.', Colors.red);
        }
      } catch (e) {
        _showColoredSnackBar('An error occurred. Please try again later.', Colors.red);
        print('Error submitting form: $e');
      }
    } else {
      _showColoredSnackBar('Please correct the errors in the form.', Colors.red);
    }
  }

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      _showColoredSnackBar('Could not launch phone app.', Colors.red);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (!await launchUrl(emailUri)) {
      _showColoredSnackBar('Could not launch email app.', Colors.red);
    }
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
                      child: Form(
                        key: _formKey,
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
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Your Name',
                                hintText: 'Enter your full name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.red, width: 2.0),
                                ),
                                prefixIcon: const Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Name cannot be empty';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: isLargeScreen ? 20 : 15),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Your Email',
                                hintText: 'Enter your email address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _emailController.text.isEmpty
                                        ? Colors.grey
                                        : _isEmailValid
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _isEmailValid ? Colors.green : Colors.red,
                                    width: 2.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _emailController.text.isEmpty
                                        ? Colors.grey
                                        : _isEmailValid
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                prefixIcon: const Icon(Icons.email),
                                hintStyle: TextStyle(
                                  color: _isEmailValid ? Colors.green : Colors.red,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email cannot be empty';
                                }
                                if (!_isEmailValid) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: isLargeScreen ? 20 : 15),
                            TextFormField(
                              controller: _messageController,
                              maxLines: 6,
                              decoration: InputDecoration(
                                labelText: 'Your Message',
                                hintText: 'Type your message here...',
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.red, width: 2.0),
                                ),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 100),
                                  child: Icon(Icons.message),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Message cannot be empty';
                                }
                                return null;
                              },
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
                          _buildContactInfoItem(Icons.phone, '+254702778897', onTap: () => _launchPhoneDialer('+254702778897')),
                          SizedBox(height: 10),
                          _buildContactInfoItem(Icons.phone, '+254712529637', onTap: () => _launchPhoneDialer('+254712529637')),
                          SizedBox(height: isLargeScreen ? 20 : 15),
                          _buildContactInfoItem(Icons.email, 'soraproperties002@gmail.com', onTap: () => _launchEmail('soraproperties002@gmail.com')),
                          SizedBox(height: isLargeScreen ? 20 : 15),
                          _buildContactInfoItem(Icons.access_time, '24/7'),
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
                          Wrap(
                            spacing: 15.0,
                            runSpacing: 15.0,
                            children: [
                              _buildSocialIcon(FontAwesomeIcons.facebookF, 'Facebook', const Color(0xFF1877F2), 'https://www.facebook.com/share/1C3bVnrGCW/'),
                              _buildSocialIcon(FontAwesomeIcons.linkedinIn, 'LinkedIn', const Color(0xFF0A66C2), 'https://linkedin.com'),
                              _buildSocialIcon(FontAwesomeIcons.xTwitter, 'X (Twitter)', Colors.black, 'https://x.com'),
                              _buildSocialIcon(FontAwesomeIcons.youtube, 'YouTube', const Color(0xFFFF0000), 'https://youtube.com/@soraproperties?si=F3sQtcRZoBZL8Llv'),
                              // WhatsApp link using wa.me with the phone number
                              _buildSocialIcon(FontAwesomeIcons.whatsapp, 'WhatsApp', const Color(0xFF25D366), 'https://wa.me/+25493999591'),
                              // TikTok link corrected with 'https://' prefix
                              _buildSocialIcon(FontAwesomeIcons.tiktok, 'TikTok', Colors.black, 'https://tiktok.com/@sora_properties.l'),
                              _buildSocialIcon(FontAwesomeIcons.pinterest, 'Pinterest', const Color(0xFFE60023), 'https://pinterest.com'),
                              _buildSocialIcon(FontAwesomeIcons.google, 'Google Business', const Color(0xFF4285F4), 'https://business.google.com'),
                              _buildSocialIcon(FontAwesomeIcons.instagram, 'Instagram', const Color(0xFFE1306C), 'https://www.instagram.com/sora.properties?igsh=MTFzM2dhOXZ5Z3E2eA=='),
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
              color: const Color(0xFFF0F2F5),
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
                    onPressed: () async {
                      if (_newsletterEmailController.text.isNotEmpty && _newsletterEmailController.text.contains('@')) {
                        final firestoreService = FirestoreService();
                        final success = await firestoreService.addNewsletterSubscriber(_newsletterEmailController.text);
                        if (success) {
                          _showColoredSnackBar('Subscribed with ${_newsletterEmailController.text}!', Colors.green);
                          _newsletterEmailController.clear();
                        } else {
                          _showColoredSnackBar('Failed to subscribe. Please try again.', Colors.red);
                        }
                      } else {
                        _showColoredSnackBar('Please enter a valid email address.', Colors.red);
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

  Widget _buildContactInfoItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
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
                      decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
                      decorationColor: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATED: The function now takes a URL and launches it
  Widget _buildSocialIcon(IconData icon, String socialMediaName, Color color, String url) {
    return IconButton(
      icon: FaIcon(icon, size: 28, color: color),
      onPressed: () async {
        final uri = Uri.parse(url);
        // Use canLaunchUrl and LaunchMode.externalApplication for robustness
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showColoredSnackBar('Could not open $socialMediaName page.', Colors.red);
        }
      },
      tooltip: 'Visit our $socialMediaName page',
    );
  }
}