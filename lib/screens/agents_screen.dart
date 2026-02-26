// /lib/screens/agents_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:sora_app/services/auth_service.dart'; 
import 'package:sora_app/widgets/common_widgets.dart'; 

class AgentsScreen extends StatefulWidget {
  final AuthService authService; 

  const AgentsScreen({super.key, required this.authService});

  @override
  State<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends State<AgentsScreen> {
  final TextEditingController _newsletterEmailController = TextEditingController();
  late CommonWidgets commonWidgets; 

  String _currentListingTypeFilter = '';

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

  // Mock agent data with updated image paths
  final List<Map<String, String>> _agents = [
    {
      'name': 'Erick Ntongai',
      'title': 'Senior Real Estate Agent',
      'image': 'assets/images/riki_pro.webp', 
      'phone': '+254702778897',
      'email': 'soraproperties001@gmail.com',
      'bio': 'Erick specializes in luxury residential properties and has over 10 years of experience in the Nairobi market. He is dedicated to providing exceptional service and finding the perfect home for his clients.',
    },
    {
      'name': 'Kioko Muinde',
      'title': 'Commercial Property Specialist',
      'image': 'assets/images/kioko_pro.webp', 
      'phone': '+254712529637',
      'email': 'kiokomuinde022soraproperties001@gmail.com',
      'bio': 'Kioko is an expert in commercial real estate, assisting businesses with office spaces, retail locations, and industrial properties across Kenya. His analytical approach ensures optimal investment decisions.',
    },
    {
      'name': 'Regina Wambui',
      'title': 'Rental & Lease Expert',
      'image': 'assets/images/agent3.webp',
      'phone': '+254798111621',
      'email': 'soraproperties002@gmail.com',
      'bio': 'Regina has a deep understanding of the rental market, helping individuals and families find suitable rental properties and managing lease agreements with efficiency and care.',
    },
    {
      'name': 'Kelvin Kithinji',
      'title': 'New Developments Consultant',
      'image': 'assets/images/voke_pro.png',
      'phone': '+254702778897',
      'email': 'soraproperties002@gmail.com',
      'bio': 'Kelvin focuses on new property developments, providing insights into emerging neighborhoods and off-plan investments. He helps clients navigate the complexities of buying into new projects.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    
    // Constraint for ultra-wide monitors
    final double contentMaxWidth = 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Match property listing background
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
                _buildAgentsGrid(isLargeScreen, isMediumScreen, screenWidth),
                _buildJoinTeamCTA(isLargeScreen, isMediumScreen),
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
        bottom: isLargeScreen ? 20 : 10,
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
              'Our Expert Agents',
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
            text: 'Connect with our dedicated team of real estate professionals ready to help you.',
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsGrid(bool isLargeScreen, bool isMediumScreen, double screenWidth) {
    int crossAxisCount;
    double childAspectRatio;

    if (isLargeScreen) {
      crossAxisCount = 3;
      childAspectRatio = 0.70; // Taller cards for desktop
    } else if (isMediumScreen) {
      crossAxisCount = 2;
      childAspectRatio = 0.75; // Slightly wider for tablets
    } else {
      crossAxisCount = 1;
      childAspectRatio = 0.90; // Much wider for mobile so it doesn't stretch too tall
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 30,
        horizontal: isLargeScreen ? 40 : 20,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
          childAspectRatio: childAspectRatio, 
        ),
        itemCount: _agents.length,
        itemBuilder: (context, index) {
          final agent = _agents[index];
          return _buildPremiumAgentCard(agent, isLargeScreen, isMediumScreen);
        },
      ),
    );
  }

  Widget _buildPremiumAgentCard(Map<String, String> agent, bool isLargeScreen, bool isMediumScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section - Updated with errorBuilder for missing images
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC), // Very soft slate background for the image container
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.asset(
                  agent['image']!,
                  fit: BoxFit.contain, // This forces the whole image to remain visible
                  alignment: Alignment.center, 
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Details Section
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          agent['name']!,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 24 : 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white, // Required for ShaderMask
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        agent['title']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        agent['bio']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  // Contact Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildContactButton(
                        icon: Icons.phone_rounded, 
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${agent['phone']}...')),
                          );
                        }
                      ),
                      const SizedBox(width: 15),
                      _buildContactButton(
                        icon: Icons.email_rounded, 
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Emailing ${agent['email']}...')),
                          );
                        }
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A66C2).withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF0A66C2),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildJoinTeamCTA(bool isLargeScreen, bool isMediumScreen) {
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
            Icon(Icons.handshake_rounded, size: isLargeScreen ? 80 : 60, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Join Our Growing Team!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLargeScreen ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Are you a passionate real estate professional looking for your next opportunity? Explore careers with SORA.',
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
                Navigator.pushNamed(context, '/careers');
              },
              icon: const Icon(Icons.work_outline, color: Color(0xFF0A66C2)),
              label: const Text('View Openings'),
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
        vertical: 20,
        horizontal: isLargeScreen ? 60 : (isMediumScreen ? 40 : 20),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: const Text(
              'Stay Updated with SORA News',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white, 
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Subscribe to our newsletter for the latest property listings, market insights, and exclusive offers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 15,
              color: Colors.grey[600],
              height: 1.6,
            ),
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
            padding: const EdgeInsets.all(2), // Gradient border thickness
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
}

/// Custom widget for a smooth "passing cloud" shimmer effect over the description text
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