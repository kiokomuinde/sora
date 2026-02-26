// /lib/screens/about_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sora_app/screens/home_screen.dart'; 
import 'package:sora_app/services/auth_service.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:sora_app/widgets/common_widgets.dart'; 

class AboutScreen extends StatefulWidget { 
  final AuthService authService; 

  const AboutScreen({super.key, required this.authService}); 

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final TextEditingController _newsletterEmailController = TextEditingController();
  String _currentListingTypeFilter = ''; 
  late CommonWidgets commonWidgets; 

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService); 
  }

  @override
  void dispose() {
    _newsletterEmailController.dispose();
    super.dispose();
  }

  void _showLoginSignupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)],
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Login / Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).pop(); 
                  Navigator.pushNamed(context, '/signin'); 
                },
              ),
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

    final double contentMaxWidth = 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: commonWidgets.buildAppBar(
        currentListingTypeFilter: _currentListingTypeFilter,
      ),
      endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Column(
              children: [
                _buildHeader(isLargeScreen, isMediumScreen),
                _buildStorySection(isLargeScreen, isMediumScreen),
                _buildMissionVisionSection(isLargeScreen, isMediumScreen),
                _buildValuesSection(isLargeScreen, isMediumScreen),
                _buildTeamCTA(isLargeScreen, isMediumScreen),
                _buildNewsletterSection(isLargeScreen, isMediumScreen),
                commonWidgets.buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI SECTIONS
  // ---------------------------------------------------------------------------

  Widget _buildHeader(bool isLargeScreen, bool isMediumScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: isLargeScreen ? 60 : 40,
        bottom: isLargeScreen ? 40 : 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)], 
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'About SORA Properties',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLargeScreen ? 52 : (isMediumScreen ? 42 : 32),
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _PassingCloudText(
            text: 'Your trusted partner in real estate, committed to excellence and client satisfaction.',
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(bool isLargeScreen, bool isMediumScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: isLargeScreen ? 60 : (isMediumScreen ? 40 : 20),
      ),
      child: _PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Our Story'),
            const SizedBox(height: 20),
            Text(
              'Founded in 2010, SORA Properties began with a vision to revolutionize the real estate industry in Kenya. We started as a small team of passionate individuals dedicated to helping people find their dream homes and make sound investments. Over the years, we have grown into a leading real estate agency, known for our integrity, expertise, and client-centric approach.',
              style: _bodyTextStyle(isLargeScreen),
            ),
            const SizedBox(height: 15),
            Text(
              'Our journey has been marked by continuous innovation, adapting to market trends, and embracing technology to provide seamless and efficient services. We pride ourselves on building lasting relationships with our clients, guiding them through every step of their real estate journey, whether it\'s buying, selling, or leasing properties.',
              style: _bodyTextStyle(isLargeScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionVisionSection(bool isLargeScreen, bool isMediumScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: isLargeScreen ? 60 : (isMediumScreen ? 40 : 20),
      ),
      child: isLargeScreen || isMediumScreen
          // FIXED: Added IntrinsicHeight to resolve the unbounded vertical constraint error
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildMissionVisionCard('Mission', Icons.flag_rounded, 'To empower individuals and families to achieve their real estate goals by providing expert guidance, innovative solutions, and unparalleled service.', isLargeScreen)),
                  const SizedBox(width: 30),
                  Expanded(child: _buildMissionVisionCard('Vision', Icons.visibility_rounded, 'To be the most trusted and innovative real estate platform in Africa, recognized for our commitment to client success and community development.', isLargeScreen)),
                ],
              ),
            )
          : Column(
              children: [
                _buildMissionVisionCard('Mission', Icons.flag_rounded, 'To empower individuals and families to achieve their real estate goals by providing expert guidance, innovative solutions, and unparalleled service.', isLargeScreen),
                const SizedBox(height: 20),
                _buildMissionVisionCard('Vision', Icons.visibility_rounded, 'To be the most trusted and innovative real estate platform in Africa, recognized for our commitment to client success and community development.', isLargeScreen),
              ],
            ),
    );
  }

  Widget _buildMissionVisionCard(String title, IconData icon, String text, bool isLargeScreen) {
    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildGradientIcon(icon, isLargeScreen ? 36 : 28),
              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: isLargeScreen ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            text,
            style: _bodyTextStyle(isLargeScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildValuesSection(bool isLargeScreen, bool isMediumScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: isLargeScreen ? 60 : (isMediumScreen ? 40 : 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildSectionTitle('Our Values', center: true),
          const SizedBox(height: 30),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildValueCard(Icons.handshake_rounded, 'Integrity', 'We operate with the highest ethical standards, ensuring transparency and honesty in all our dealings.', isLargeScreen),
              _buildValueCard(Icons.lightbulb_rounded, 'Innovation', 'We embrace technology and creative solutions to deliver cutting-edge real estate services.', isLargeScreen),
              _buildValueCard(Icons.people_rounded, 'Client-Centricity', 'Our clients are at the heart of everything we do. We are dedicated to understanding and exceeding their expectations.', isLargeScreen),
              _buildValueCard(Icons.diversity_3_rounded, 'Community', 'We believe in giving back and contributing positively to the communities we serve.', isLargeScreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(IconData icon, String title, String description, bool isLargeScreen) {
    double cardWidth = isLargeScreen ? 450 : 350;

    return Container(
      width: cardWidth,
      child: _PremiumCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A66C2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: _buildGradientIcon(icon, isLargeScreen ? 32 : 26),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: _bodyTextStyle(isLargeScreen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCTA(bool isLargeScreen, bool isMediumScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 40,
        horizontal: isLargeScreen ? 60 : (isMediumScreen ? 40 : 20),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isLargeScreen ? 50 : 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B21B6).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.groups_rounded, size: isLargeScreen ? 80 : 60, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Meet Our Exceptional Team',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLargeScreen ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We are building a dedicated section to introduce you to the passionate professionals behind SORA Properties.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/agents'); 
              },
              icon: const Icon(Icons.person_search, color: Color(0xFF0A66C2)),
              label: const Text('Find an Agent'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0A66C2),
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 30 : 20, 
                  vertical: isLargeScreen ? 20 : 15
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsletterSection(bool isLargeScreen, bool isMediumScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 40,
        horizontal: isLargeScreen ? 60 : (isMediumScreen ? 40 : 20),
      ),
      child: Column(
        children: [
          _buildSectionTitle('Stay Updated with SORA News', center: true),
          const SizedBox(height: 15),
          Text(
            'Subscribe to our newsletter for the latest property listings, market insights, and exclusive offers.',
            textAlign: TextAlign.center,
            style: _bodyTextStyle(isLargeScreen),
          ),
          const SizedBox(height: 30),
          Container(
            constraints: BoxConstraints(maxWidth: isLargeScreen ? 600 : double.infinity),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)], 
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A66C2).withOpacity(0.2),
                  blurRadius: 15.0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2), 
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newsletterEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0A66C2)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)],
                        ),
                      ),
                      child: ElevatedButton(
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
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                        ),
                        child: const Text('Subscribe', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS & STYLES
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(String title, {bool center = false}) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        title,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white, 
        ),
      ),
    );
  }

  Widget _buildGradientIcon(IconData icon, double size) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Icon(
        icon,
        size: size,
        color: Colors.white, 
      ),
    );
  }

  TextStyle _bodyTextStyle(bool isLargeScreen) {
    return TextStyle(
      fontSize: isLargeScreen ? 16 : 15,
      color: Colors.grey[600],
      height: 1.6,
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;

  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PassingCloudText extends StatefulWidget {
  final String text;
  
  const _PassingCloudText({Key? key, required this.text}) : super(key: key);

  @override
  __PassingCloudTextState createState() => __PassingCloudTextState();
}

class __PassingCloudTextState extends State<_PassingCloudText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500), 
      vsync: this,
    )..repeat(); 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn, 
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.grey[500]!, 
                Colors.blue[400]!, 
                Colors.grey[500]!, 
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-3.0 + (_controller.value * 6.0), 0.0),
              end: Alignment(-1.0 + (_controller.value * 6.0), 0.0),
            ).createShader(bounds);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w500,
                color: Colors.white, 
              ),
            ),
          ),
        );
      },
    );
  }
}