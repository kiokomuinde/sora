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

class _ContactScreenState extends State<ContactScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newsletterEmailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  late CommonWidgets commonWidgets;

  String _currentListingTypeFilter = '';
  bool _isEmailValid = false;
  bool _isSubmitting = false;

  // Animation controller for passing houses
  late AnimationController _houseController;

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);

    _emailController.addListener(_validateEmail);

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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _submitContactForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isEmailValid) {
        _showColoredSnackBar('Please enter a valid email address.', Colors.red);
        return;
      }
      
      setState(() {
        _isSubmitting = true;
      });

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
      } finally {
        setState(() {
          _isSubmitting = false;
        });
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
      backgroundColor: const Color(0xFFF9FAFC), // A very light, clean background
      appBar: commonWidgets.buildAppBar(
        currentListingTypeFilter: _currentListingTypeFilter,
      ),
      endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Contact Header Section with Passing Houses Animation
            Container(
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF87CEEB), Color(0xFFE0F6FF)], 
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
                              'Contact Us',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0A66C2),
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: isLargeScreen ? 15 : 10),
                            Text(
                              'We\'re here to help! Reach out to us for any inquiries.',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                                color: Colors.blueGrey[800],
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
                      padding: EdgeInsets.all(isLargeScreen ? 40 : 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A66C2).withOpacity(0.06),
                            spreadRadius: 2,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
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
                            const SizedBox(height: 8),
                            Text(
                              'Fill out the form below and we will get back to you shortly.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: isLargeScreen ? 30 : 20),
                            TextFormField(
                              controller: _nameController,
                              decoration: _buildInputDecoration(
                                labelText: 'Your Name',
                                hintText: 'Enter your full name',
                                icon: Icons.person_outline,
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
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _isEmailValid ? Colors.green : const Color(0xFF1E90FF),
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _emailController.text.isEmpty
                                        ? Colors.transparent
                                        : _isEmailValid
                                            ? Colors.green.withOpacity(0.5)
                                            : Colors.red.withOpacity(0.5),
                                    width: 1.0,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: _emailController.text.isEmpty
                                      ? Colors.grey[600]
                                      : _isEmailValid
                                          ? Colors.green
                                          : Colors.red,
                                ),
                                hintStyle: TextStyle(color: Colors.grey[400]),
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
                              decoration: _buildInputDecoration(
                                labelText: 'Your Message',
                                hintText: 'Type your message here...',
                                icon: Icons.chat_bubble_outline,
                                isTextArea: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Message cannot be empty';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: isLargeScreen ? 35 : 25),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _submitContactForm,
                                icon: _isSubmitting 
                                    ? const SizedBox(
                                        width: 20, 
                                        height: 20, 
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                      )
                                    : const Icon(Icons.send_rounded),
                                label: Text(_isSubmitting ? 'Sending...' : 'Send Message'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E90FF),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
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
                      padding: EdgeInsets.all(isLargeScreen ? 40 : 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A66C2).withOpacity(0.06),
                            spreadRadius: 2,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
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
                          _buildContactInfoItem(Icons.location_on_rounded, '123 Real Estate Avenue, Nairobi, Kenya'),
                          SizedBox(height: isLargeScreen ? 20 : 15),
                          _buildContactInfoItem(Icons.phone_rounded, '+254702778897', onTap: () => _launchPhoneDialer('+254702778897')),
                          SizedBox(height: 10),
                          _buildContactInfoItem(Icons.phone_rounded, '+254712529637', onTap: () => _launchPhoneDialer('+254712529637')),
                          SizedBox(height: isLargeScreen ? 20 : 15),
                          _buildContactInfoItem(Icons.email_rounded, 'soraproperties002@gmail.com', onTap: () => _launchEmail('soraproperties002@gmail.com')),
                          SizedBox(height: isLargeScreen ? 20 : 15),
                          _buildContactInfoItem(Icons.access_time_rounded, 'Available 24/7'),
                          SizedBox(height: isLargeScreen ? 35 : 25),
                          Divider(color: Colors.grey[200], thickness: 1.5),
                          SizedBox(height: isLargeScreen ? 25 : 15),
                          Text(
                            'Follow Us',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Wrap(
                            spacing: 12.0,
                            runSpacing: 12.0,
                            children: [
                              _buildSocialIcon(FontAwesomeIcons.facebookF, 'Facebook', const Color(0xFF1877F2), 'https://www.facebook.com/share/1C3bVnrGCW/'),
                              _buildSocialIcon(FontAwesomeIcons.linkedinIn, 'LinkedIn', const Color(0xFF0A66C2), 'https://linkedin.com'),
                              _buildSocialIcon(FontAwesomeIcons.xTwitter, 'X (Twitter)', Colors.black, 'https://x.com'),
                              _buildSocialIcon(FontAwesomeIcons.youtube, 'YouTube', const Color(0xFFFF0000), 'https://youtube.com/@soraproperties?si=F3sQtcRZoBZL8Llv'),
                              _buildSocialIcon(FontAwesomeIcons.whatsapp, 'WhatsApp', const Color(0xFF25D366), 'https://wa.me/+25493999591'),
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

            // Newsletter Signup Section
            Container(
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
                    'Stay Updated with SORA News',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 15 : 10),
                  Text(
                    'Subscribe to our newsletter for the latest property listings, market insights, and exclusive offers.',
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
            ),

            // Footer
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String labelText, required String hintText, required IconData icon, bool isTextArea = false}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      alignLabelWithHint: isTextArea,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E90FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      prefixIcon: Padding(
        padding: isTextArea ? const EdgeInsets.only(bottom: 110) : EdgeInsets.zero,
        child: Icon(icon, color: Colors.grey[600]),
      ),
      hintStyle: TextStyle(color: Colors.grey[400]),
    );
  }

  Widget _buildContactInfoItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: const Color(0xFF0A66C2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  height: 1.5,
                  decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String socialMediaName, Color color, String url) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            _showColoredSnackBar('Could not open $socialMediaName page.', Colors.red);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: FaIcon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}