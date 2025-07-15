// lib/widgets/common_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Keep this import for User type if needed
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/screens/home_screen.dart'; // Import if needed for navigation from drawer

// This class provides common widgets like AppBar and Footer for consistent UI across screens.
class CommonWidgets {
  final BuildContext context;
  final AuthService authService; // Now required in the constructor

  CommonWidgets({required this.context, required this.authService});

  // Helper method to show login/signup dialog (copied from your original)
  void showLoginSignupDialog() {
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
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                'Log In',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E90FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog first
                Navigator.pushNamed(context, '/signin'); // Navigate to sign-in
              },
            ),
            ElevatedButton(
              child: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A66C2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog first
                Navigator.pushNamed(context, '/signup'); // Navigate to sign-up
              },
            ),
          ],
        );
      },
    );
  }

  // Common AppBar for consistent navigation (re-implemented to include authService logic)
  AppBar buildAppBar({String? currentListingTypeFilter}) {
    final bool isLoggedIn = authService.getCurrentUser() != null;
    final User? user = authService.getCurrentUser();
    final String userEmail = user?.email ?? 'Guest';
    final String displayName = user?.displayName ?? userEmail.split('@')[0];

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: kIsWeb ? 80 : null, // Increase toolbar height for web
      leadingWidth: kIsWeb ? 200 : null,
      leading: Padding(
        padding: kIsWeb
            ? const EdgeInsets.only(left: 40.0)
            : const EdgeInsets.only(left: 8.0),
        child: Align(
          alignment: kIsWeb ? Alignment.centerLeft : Alignment.center,
          child: GestureDetector(
            onTap: () {
              // Ensure navigation to home resets the state of HomeScreen if already there
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/sora_logo.png', height: kIsWeb ? 40 : 30),
                if (kIsWeb) const SizedBox(width: 8),
                if (kIsWeb)
                  const Text(
                    'SORA',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                      fontFamily: 'Inter',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      title: kIsWeb
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Added Home button
                _buildAppBarButton('Home', '/home'),
                const SizedBox(width: 20),
                _buildAppBarButton(
                  'Buy',
                  '/buy',
                  currentListingTypeFilter == 'Buy',
                ),
                const SizedBox(width: 20),
                _buildAppBarButton(
                  'Rent',
                  '/rent',
                  currentListingTypeFilter == 'Rent',
                ),
                const SizedBox(width: 20),
                _buildAppBarButton(
                  'Lease',
                  '/lease',
                  currentListingTypeFilter == 'Lease',
                ),
                const SizedBox(width: 20),
                _buildAppBarButton('About Us', '/about'),
                const SizedBox(width: 20),
                _buildAppBarButton('Agents', '/agents'),
                const SizedBox(width: 20),
                _buildAppBarButton('Contact Us', '/contact'),
                const SizedBox(width: 20),
                _buildAppBarButton('Blog', '/blogs'),
              ],
            )
          : null,
      actions: [
        if (kIsWeb) // Only show on web
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                if (isLoggedIn) ...[
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.grey),
                    tooltip: 'Favorites',
                    onPressed: () {
                      Navigator.pushNamed(context, '/my_favorites');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_home_work, color: Colors.grey),
                    tooltip: 'My Listings',
                    onPressed: () {
                      Navigator.pushNamed(context, '/my_listings');
                    },
                  ),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    onSelected: (String value) async {
                      if (value == 'profile') {
                        Navigator.pushNamed(context, '/profile_settings');
                      } else if (value == 'logout') {
                        await authService.signOut();
                        // Navigate back to home or sign-in after logout
                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Color(0xFF0A66C2)),
                            const SizedBox(width: 8),
                            Text('Profile (${displayName.toCapitalized()})'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF0A66C2),
                      child: Text(
                        displayName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signin'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0A66C2),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A66C2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (!kIsWeb) // Show hamburger menu on mobile
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF0A66C2)),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAppBarButton(String text, String route, [bool isSelected = false]) {
    return TextButton(
      onPressed: () {
        // Use authService.getCurrentUser() != null for login check
        if (text == 'Sell Property' && authService.getCurrentUser() == null) {
          showLoginSignupDialog();
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? const Color(0xFF1E90FF) : const Color(0xFF0A66C2),
        textStyle: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      child: Text(text),
    );
  }

  // Common Drawer for mobile navigation (re-implemented to include authService logic)
  Drawer buildDrawer() {
    final bool isLoggedIn = authService.getCurrentUser() != null;
    final User? user = authService.getCurrentUser();
    final String userEmail = user?.email ?? 'Guest';
    final String displayName = user?.displayName ?? userEmail.split('@')[0];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF0A66C2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoggedIn) ...[
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayName.toCapitalized(),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ] else ...[
                  const Icon(Icons.person_outline, color: Colors.white, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome, Guest!',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
          _buildDrawerItem(Icons.home, 'Home', '/home'),
          _buildDrawerItem(Icons.search, 'Buy', '/buy'),
          _buildDrawerItem(Icons.key, 'Rent', '/rent'),
          _buildDrawerItem(Icons.handshake, 'Lease', '/lease'),
          _buildDrawerItem(Icons.info_outline, 'About Us', '/about'),
          _buildDrawerItem(Icons.people_outline, 'Agents', '/agents'),
          _buildDrawerItem(Icons.phone, 'Contact Us', '/contact'),
          _buildDrawerItem(Icons.article, 'Blog', '/blogs'),
          _buildDrawerItem(Icons.work_outline, 'Careers', '/careers'),
          _buildDrawerItem(Icons.reviews, 'Testimonials', '/testimonials'),
          _buildDrawerItem(Icons.help_outline, 'FAQs', '/faqs'),
          _buildDrawerItem(Icons.map_outlined, 'Local Guides', '/local_guides'),
          _buildDrawerItem(Icons.event_note, 'Events', '/events'), // Added Events

          const Divider(), // Divider before authenticated options
          if (isLoggedIn) ...[
            _buildDrawerItem(Icons.favorite_border, 'My Favorites', '/my_favorites'),
            _buildDrawerItem(Icons.add_home_work, 'My Listings', '/my_listings'),
            _buildDrawerItem(Icons.settings, 'Profile Settings', '/profile_settings'),
            _buildDrawerItem(Icons.logout, 'Logout', '/logout', isLogout: true),
          ] else ...[
            _buildDrawerItem(Icons.login, 'Sign In', '/signin'),
            _buildDrawerItem(Icons.person_add, 'Sign Up', '/signup'),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String route, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF0A66C2)),
      title: Text(
        title,
        style: TextStyle(color: isLogout ? Colors.red : Colors.black87),
      ),
      onTap: () async {
        Navigator.pop(context); // Close the drawer
        if (isLogout) {
          await authService.signOut();
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false); // Go to home after logout
        } else if (title == 'Sell Property' && authService.getCurrentUser() == null) { // Fixed isLoggedIn check
          showLoginSignupDialog();
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  // Common Footer (copied directly from your original)
  Widget buildFooter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 60 : (isMediumScreen ? 40 : 30),
        horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Info Section
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/sora_logo.png', height: 40),
                        const SizedBox(width: 8),
                        const Text(
                          'SORA',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A66C2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'SORA is a leading real estate platform dedicated to connecting people with their dream properties across the globe.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '123 Real Estate Blvd, Suite 456, Property City, PC 78901',
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                    Text(
                      'Email: info@sora.com | Phone: +1 (555) 123-4567',
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              if (isLargeScreen || isMediumScreen) ...[
                const SizedBox(width: 40),
                // Quick Links Section
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Links',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A66C2),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildFooterLink('Home', () => Navigator.pushNamed(context, '/home')),
                      _buildFooterLink('Properties', () => Navigator.pushNamed(context, '/buy')),
                      _buildFooterLink('About Us', () => Navigator.pushNamed(context, '/about')),
                      _buildFooterLink('Agents', () => Navigator.pushNamed(context, '/agents')),
                      _buildFooterLink('Contact Us', () => Navigator.pushNamed(context, '/contact')),
                      _buildFooterLink('Blog', () => Navigator.pushNamed(context, '/blogs')),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // Support & Resources Section
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Support & Resources',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A66C2),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildFooterLink('FAQs', () => Navigator.pushNamed(context, '/faqs')),
                      _buildFooterLink('Support', () => Navigator.pushNamed(context, '/support')),
                      _buildFooterLink('Careers', () => Navigator.pushNamed(context, '/careers')),
                      _buildFooterLink('Terms of Service', () => Navigator.pushNamed(context, '/terms_of_service')),
                      _buildFooterLink('Privacy Policy', () => Navigator.pushNamed(context, '/privacy_policy')),
                      _buildFooterLink('Cookie Policy', () => Navigator.pushNamed(context, '/cookie_policy')),
                      _buildFooterLink('Disclaimer', () => Navigator.pushNamed(context, '/disclaimer')),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 30),
          // Newsletter Signup Section (visible on all screen sizes)
          Align(
            alignment: isLargeScreen ? Alignment.centerRight : Alignment.center,
            child: SizedBox(
              width: isLargeScreen ? 300 : (isMediumScreen ? 250 : double.infinity),
              child: Column(
                crossAxisAlignment: isLargeScreen ? CrossAxisAlignment.end : CrossAxisAlignment.center,
                children: [
                  Text( // Removed const here
                    'Subscribe to our Newsletter',
                    style: const TextStyle( // Kept const here as style is constant
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                    textAlign: isLargeScreen ? TextAlign.right : TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: TextEditingController(), // Use a local controller if not managing state here
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Handle newsletter subscription (e.g., show a snackbar)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Subscription feature coming soon!')),
                      );
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

  // Helper for footer links
  Widget _buildFooterLink(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54, // Changed color to better suit light footer
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

// Moved to common_widgets.dart as a shared utility (copied directly from your original)
extension StringExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}
