// lib/widgets/common_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/screens/home_screen.dart';

// Extension for capitalizing first letter of a string
extension StringExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}

// This class provides common widgets like AppBar and Footer for consistent UI across screens.
class CommonWidgets {
  final BuildContext context;
  final AuthService authService;

  CommonWidgets({required this.context, required this.authService});

  // Helper method to show login/signup dialog
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
                Navigator.of(dialogContext).pop();
                Navigator.pushNamed(context, '/signin');
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
                Navigator.of(dialogContext).pop();
                Navigator.pushNamed(context, '/signup');
              },
            ),
          ],
        );
      },
    );
  }

  // Helper method to check if screen is small (for responsive design)
  bool _isSmallScreen() {
    return MediaQuery.of(context).size.width < 1024;
  }

  // Common AppBar for consistent navigation
  AppBar buildAppBar({String? currentListingTypeFilter}) {
    final bool isLoggedIn = authService.getCurrentUser() != null;
    final User? user = authService.getCurrentUser();
    final String userEmail = user?.email ?? 'Guest';
    final String displayName = user?.displayName ?? userEmail.split('@')[0];

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: kIsWeb ? 80 : null,
      leadingWidth: kIsWeb ? 200 : null,
      leading: Padding(
        padding: kIsWeb
            ? const EdgeInsets.only(left: 40.0)
            : const EdgeInsets.only(left: 8.0),
        child: Align(
          alignment: kIsWeb ? Alignment.centerLeft : Alignment.center,
          child: GestureDetector(
            onTap: () {
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
      title: kIsWeb && !_isSmallScreen()
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
        if (kIsWeb && !_isSmallScreen()) // Only show on web and large screens
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                if (isLoggedIn) ...[
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    onSelected: (String value) async {
                      if (value == 'dashboard') {
                        Navigator.pushNamed(context, '/dashboard');
                      } else if (value == 'my_listings') {
                        Navigator.pushNamed(context, '/my_listings');
                      } else if (value == 'my_favorites') {
                        Navigator.pushNamed(context, '/my_favorites');
                      } else if (value == 'recently_viewed') {
                        Navigator.pushNamed(context, '/recently_viewed');
                      } else if (value == 'profile_settings') {
                        Navigator.pushNamed(context, '/profile_settings');
                      } else if (value == 'logout') {
                        await authService.signOut();
                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'dashboard',
                        child: Row(
                          children: [
                            const Icon(Icons.dashboard, color: Color(0xFF0A66C2)),
                            const SizedBox(width: 8),
                            const Text('Dashboard'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'my_listings',
                        child: Row(
                          children: [
                            const Icon(Icons.add_home_work, color: Color(0xFF0A66C2)),
                            const SizedBox(width: 8),
                            const Text('My Listings'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'my_favorites',
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_border, color: Color(0xFF0A66C2)),
                            const SizedBox(width: 8),
                            const Text('My Favorites'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'recently_viewed',
                        child: Row(
                          children: [
                            const Icon(Icons.history, color: Color(0xFF0A66C2)),
                            const SizedBox(width: 8),
                            const Text('Recently Viewed'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'profile_settings',
                        child: Row(
                          children: [
                            const Icon(Icons.settings, color: Color(0xFF0A66C2)),
                            const SizedBox(width: 8),
                            Text('Profile Settings (${displayName.toCapitalized()})'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            const Text('Logout'),
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
        if (!kIsWeb || _isSmallScreen()) // Show hamburger menu on mobile or small web screens
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
        // Only 'Sell Property' requires login check for general links
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

  // Common Drawer for mobile navigation
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
          _buildDrawerItem(Icons.event_note, 'Events', '/events'),

          const Divider(),
          if (isLoggedIn) ...[
            _buildDrawerItem(Icons.dashboard, 'Dashboard', '/dashboard'),
            _buildDrawerItem(Icons.favorite_border, 'My Favorites', '/my_favorites'),
            _buildDrawerItem(Icons.add_home_work, 'My Listings', '/my_listings'),
            _buildDrawerItem(Icons.history, 'Recently Viewed', '/recently_viewed'),
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
        Navigator.pop(context);
        // Only user-specific routes require login check
        if (['dashboard', 'my_listings', 'my_favorites', 'recently_viewed', 'profile_settings'].any((userRoute) => route.contains(userRoute))) {
          if (authService.getCurrentUser() == null) {
            showLoginSignupDialog();
            return;
          }
        }
        
        if (isLogout) {
          await authService.signOut();
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  // Common Footer for consistent bottom navigation
  Widget buildFooter() {
    return Container(
      color: const Color(0xFF0A66C2),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          // Main footer content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/sora_logo.png', height: 30, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'SORA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your trusted partner in finding the perfect property. We connect buyers, sellers, and renters with exceptional real estate opportunities.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    // Social Media Icons
                    Row(
                      children: [
                        _buildSocialIcon(FontAwesomeIcons.facebook),
                        const SizedBox(width: 12),
                        _buildSocialIcon(FontAwesomeIcons.twitter),
                        const SizedBox(width: 12),
                        _buildSocialIcon(FontAwesomeIcons.instagram),
                        const SizedBox(width: 12),
                        _buildSocialIcon(FontAwesomeIcons.linkedin),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
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
                    _buildFooterLink('Home', '/home'),
                    _buildFooterLink('Buy', '/buy'),
                    _buildFooterLink('Rent', '/rent'),
                    _buildFooterLink('Lease', '/lease'),
                    _buildFooterLink('About Us', '/about'),
                    _buildFooterLink('Agents', '/agents'),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              // Services
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFooterLink('Property Valuation', '/valuation'),
                    _buildFooterLink('Market Analysis', '/market_analysis'),
                    _buildFooterLink('Investment Consulting', '/investment'),
                    _buildFooterLink('Property Management', '/management'),
                    _buildFooterLink('Legal Services', '/legal'),
                    _buildFooterLink('Mortgage Assistance', '/mortgage'),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              // Contact Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactInfo(Icons.phone, '+1 (555) 123-4567'),
                    _buildContactInfo(Icons.email, 'info@sora.com'),
                    _buildContactInfo(Icons.location_on, '123 Real Estate Ave\nCity, State 12345'),
                    _buildContactInfo(Icons.access_time, 'Mon-Fri: 9AM-6PM\nSat-Sun: 10AM-4PM'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Bottom bar
          Container(
            padding: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white24, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '© 2024 SORA Real Estate. All rights reserved.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Row(
                  children: [
                    _buildFooterLink('Privacy Policy', '/privacy', isBottomLink: true),
                    const Text(' | ', style: TextStyle(color: Colors.white70)),
                    _buildFooterLink('Terms of Service', '/terms', isBottomLink: true),
                    const Text(' | ', style: TextStyle(color: Colors.white70)),
                    _buildFooterLink('Cookie Policy', '/cookies', isBottomLink: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildFooterLink(String text, String route, {bool isBottomLink = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isBottomLink ? 0 : 8),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Text(
          text,
          style: TextStyle(
            color: isBottomLink ? Colors.white70 : Colors.white,
            fontSize: isBottomLink ? 14 : 14,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Moved this method inside the class definition to fix the compilation error
  Widget buildCallToActionButton({
    required String text,
    required VoidCallback onPressed,
    Color? color,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, color: Colors.white) : Container(),
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? const Color(0xFF0A66C2),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
    );
  }
}