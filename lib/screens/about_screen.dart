// /lib/screens/about_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sora_app/screens/home_screen.dart'; // Import HomeScreen
import 'package:sora_app/services/auth_service.dart'; // Import AuthService

class AboutScreen extends StatelessWidget {
  final AuthService authService; // Receive AuthService

  const AboutScreen({super.key, required this.authService}); // Add authService to constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A66C2)), // Back button color
          onPressed: () {
            // Navigate back to the HomeScreen, passing the authService
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (routeContext) => HomeScreen(authService: authService)), // Use routeContext here
              (route) => false,
            );
          },
        ),
        title: const Text(
          'About SORA',
          style: TextStyle(
            color: Color(0xFF0A66C2),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true, // Extend body behind transparent app bar
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section for About Page
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/about_hero.webp'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 80.0, left: 24.0, right: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Connecting Dreams to Addresses',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            // Main Content Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Story',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'SORA was founded with a clear vision: to revolutionize the real estate experience across Africa. We saw a need for a platform that combines advanced technology with a deep understanding of local markets, ensuring that finding, buying, selling, or leasing property is as seamless and transparent as possible. From our humble beginnings, we’ve grown into a trusted name, committed to empowering individuals and families to achieve their property dreams.',
                    style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'To be the most innovative and trusted real estate platform in Africa, providing unparalleled access to property listings and expert guidance, making every property journey a success story.',
                    style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Our Values',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildValueRow(
                    icon: Icons.lightbulb_outline,
                    title: 'Innovation',
                    description: 'We continuously explore and implement cutting-edge technologies to enhance the user experience and simplify complex processes.',
                  ),
                  _buildValueRow(
                    icon: Icons.security,
                    title: 'Trust & Transparency',
                    description: 'We believe in honest dealings, clear communication, and providing all necessary information to build lasting trust with our clients.',
                  ),
                  _buildValueRow(
                    icon: Icons.people_alt_outlined,
                    title: 'Client-Centricity',
                    description: 'Your needs and aspirations are at the heart of everything we do. We strive to provide personalized solutions and exceptional support.',
                  ),
                  _buildValueRow(
                    icon: Icons.verified_outlined,
                    title: 'Excellence',
                    description: 'We are committed to delivering the highest quality in every aspect of our service, from our platform\'s performance to our customer interactions.',
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Meet the Team',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Wrap(
                      spacing: 20.0,
                      runSpacing: 20.0,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildTeamMemberCard(
                          name: 'Dr. Alex Mwaura',
                          title: 'Founder & CEO',
                          imageAsset: 'assets/images/team_alex.webp',
                        ),
                        _buildTeamMemberCard(
                          name: 'Sarah Njoroge',
                          title: 'Chief Operations Officer',
                          imageAsset: 'assets/images/team_sarah.webp',
                        ),
                        _buildTeamMemberCard(
                          name: 'David Kimani',
                          title: 'Head of Technology',
                          imageAsset: 'assets/images/team_david.webp',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            // Call to Action / Footer Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
              color: const Color(0xFFE3F2FD), // Light blue background
              child: Column(
                children: [
                  const Text(
                    'Ready to Start Your Property Journey?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Whether you are looking to buy, sell, or lease, SORA is here to guide you every step of the way.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/property_listings');
                    },
                    icon: const Icon(Icons.home_outlined, size: 28),
                    label: const Text('Explore Properties'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Social Media Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pass context to _buildSocialIcon
                      _buildSocialIcon(context, FontAwesomeIcons.facebookF, 'Facebook', const Color(0xFF1877F2)),
                      const SizedBox(width: 20),
                      _buildSocialIcon(context, FontAwesomeIcons.linkedinIn, 'LinkedIn', const Color(0xFF0A66C2)),
                      const SizedBox(width: 20),
                      _buildSocialIcon(context, FontAwesomeIcons.xTwitter, 'X (Twitter)', Colors.black),
                      const SizedBox(width: 20),
                      _buildSocialIcon(context, FontAwesomeIcons.instagram, 'Instagram', const Color(0xFFE1306C)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '© 2025 SORA Properties. All rights reserved.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
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

  Widget _buildValueRow({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: const Color(0xFF1E90FF)),
          const SizedBox(width: 15),
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
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard({required String name, required String title, required String imageAsset}) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(imageAsset),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 15),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Updated _buildSocialIcon to accept BuildContext
  Widget _buildSocialIcon(BuildContext context, IconData icon, String socialMediaName, Color color) {
    return IconButton(
      icon: FaIcon(icon, size: 28, color: color),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar( // Now context is available
          SnackBar(content: Text('Opening $socialMediaName...')),
        );
      },
      tooltip: 'Visit our $socialMediaName page',
    );
  }
}
