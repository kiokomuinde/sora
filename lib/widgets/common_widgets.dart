// lib/widgets/common_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// === NEW IMPORT ===
import 'package:sora_app/services/firestore_service.dart'; 

// Extension for capitalizing first letter of a string
extension StringExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}

// This class provides common widgets like AppBar and Footer for consistent UI across screens.
class CommonWidgets {
  final BuildContext context;
  final AuthService authService;
  
  // === NEW FIELD: Instantiate FirestoreService ===
  final FirestoreService _firestoreService = FirestoreService(); 

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
    final String? userId = user?.uid; // Get UID for admin check
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
                _buildAppBarButton('Airbnb', '/airbnb'),
                const SizedBox(width: 20),
                _buildAppBarButton('About Us', '/about'),
                const SizedBox(width: 20),
                _buildAppBarButton('Agents', '/agents'),
                const SizedBox(width: 20),
                _buildAppBarButton('Contact Us', '/contact'),
                const SizedBox(width: 20),
                _buildAppBarButton('Blog', '/blogs'),
                // === MODIFICATION: Check for Admin status for 'Create Blog' button ===
                if (isLoggedIn && userId != null)
                  FutureBuilder<bool>(
                    future: _firestoreService.checkAdminStatus(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
                        return Row(
                          children: [
                            const SizedBox(width: 20),
                            _buildAppBarButton('Create Blog', '/create_blog')
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                // === END MODIFICATION ===
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
                            const Text('Profile Settings'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            const Icon(Icons.logout, color: Colors.redAccent),
                            const SizedBox(width: 8),
                            const Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.person, color: Color(0xFF1E90FF)),
                          const SizedBox(width: 8),
                          Text(
                            displayName.toCapitalized(),
                            style: const TextStyle(
                              color: Color(0xFF0A66C2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFF0A66C2)),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/signin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A66C2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0A66C2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Color(0xFF0A66C2)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (!kIsWeb || _isSmallScreen()) // Mobile menu icon
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey[200],
          height: 1.0,
        ),
      ),
    );
  }

  // Common Drawer for mobile navigation
  Drawer buildDrawer() {
    final bool isLoggedIn = authService.getCurrentUser() != null;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A66C2), Color(0xFF1E90FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/sora_logo.png', height: 40),
                const SizedBox(height: 8),
                const Text(
                  'SORA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.apartment),
            title: const Text('Buy'),
            onTap: () {
              Navigator.pushNamed(context, '/buy');
            },
          ),
          ListTile(
            leading: const Icon(Icons.house),
            title: const Text('Rent'),
            onTap: () {
              Navigator.pushNamed(context, '/rent');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Lease'),
            onTap: () {
              Navigator.pushNamed(context, '/lease');
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.airbnb, size: 24),
            title: const Text('Airbnb'),
            onTap: () {
              Navigator.pushNamed(context, '/airbnb');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Agents'),
            onTap: () {
              Navigator.pushNamed(context, '/agents');
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pushNamed(context, '/contact');
            },
          ),
          const Divider(),
          if (isLoggedIn) ...[
            // This is the mobile drawer version of the button
            // It should also respect the admin status
            // === MODIFICATION: Check for Admin status for 'Create Blog' button in Drawer ===
            if (authService.getCurrentUser()?.uid != null)
              FutureBuilder<bool>(
                future: _firestoreService.checkAdminStatus(authService.getCurrentUser()!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
                    return ListTile(
                      leading: const FaIcon(FontAwesomeIcons.plus, size: 20),
                      title: const Text('Create Blog'),
                      onTap: () {
                        Navigator.pushNamed(context, '/create_blog');
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            // === END MODIFICATION ===

            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_home_work),
              title: const Text('My Listings'),
              onTap: () {
                Navigator.pushNamed(context, '/my_listings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('My Favorites'),
              onTap: () {
                Navigator.pushNamed(context, '/my_favorites');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Recently Viewed'),
              onTap: () {
                Navigator.pushNamed(context, '/recently_viewed');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await authService.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ] else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign In'),
              onTap: () {
                Navigator.pushNamed(context, '/signin');
              },
            ),
        ],
      ),
    );
  }

  // Common Footer for consistent UI
  Widget buildFooter() {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    // Get the user ID here to check if they are logged in
    final String? userId = authService.getCurrentUser()?.uid;

    return Container(
      color: const Color(0xFF0A66C2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      // UPDATED: Wrap the Column in a Stack to position the FloatingActionButton
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Corrected image path to fix the asset loading error
                            Image.asset('assets/images/sora_logo.png', height: 40),
                            const SizedBox(width: 8),
                            const Text(
                              'SORA',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sora is a leading platform for finding, buying, renting and leasing properties. We connect you to a vast network of listings and trusted agents.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        // Replaced Row with Wrap for responsive social media icons
                        Wrap(
                          spacing: 16.0,
                          runSpacing: 8.0,
                          children: [
                            // UPDATED SOCIAL MEDIA LINKS
                            _buildSocialButton(FontAwesomeIcons.xTwitter, 'https://x.com'),
                            _buildSocialButton(FontAwesomeIcons.facebookF, 'https://www.facebook.com/share/1C3bVnrGCW/'),
                            _buildSocialButton(FontAwesomeIcons.instagram, 'https://www.instagram.com/sora.properties?igsh=MTFzM2dhOXZ5Z3E2eA=='),
                            _buildSocialButton(FontAwesomeIcons.linkedinIn, 'https://linkedin.com'),
                            _buildSocialButton(FontAwesomeIcons.youtube, 'https://youtube.com/@soraproperties?si=F3sQtcRZoBZL8Llv'),
                            // WhatsApp link updated to use the provided number for 'wa.me'
                            _buildSocialButton(FontAwesomeIcons.whatsapp, 'https://wa.me/+25493999591'),
                            // TikTok link corrected with 'https://' prefix
                            _buildSocialButton(FontAwesomeIcons.tiktok, 'https://tiktok.com/@sora_properties.l'),
                            _buildSocialButton(FontAwesomeIcons.pinterest, 'https://pinterest.com'),
                            // Google link corrected with 'https://' prefix
                            _buildSocialButton(FontAwesomeIcons.google, 'https://business.google.com'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isSmallScreen) ...[
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 1,
                      child: _buildFooterColumn('Quick Links', [
                        _buildFooterLink('Home', '/home'),
                        // Add Airbnb after Home
                        _buildFooterLink('Airbnb', '/airbnb'),
                        // Add Buy, Rent, and Lease in place of Properties
                        _buildFooterLink('Buy', '/buy'),
                        _buildFooterLink('Rent', '/rent'),
                        _buildFooterLink('Lease', '/lease'),
                        _buildFooterLink('Agents', '/agents'),
                        _buildFooterLink('Blog', '/blogs'),
                        _buildFooterLink('Contact Us', '/contact'),
                      ]),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildFooterColumn('Legal', [
                        _buildFooterLink('Terms of Service', '/terms'),
                        _buildFooterLink('Privacy Policy', '/privacy'),
                        _buildFooterLink('Cookie Policy', '/cookies'),
                      ]),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildFooterColumn('Contact Us', [
                        _buildContactInfo(Icons.location_on, '123 Real Estate Avenue, Nairobi, Kenya'),
                        _buildContactInfo(
                          Icons.phone,
                          '+254702778897',
                          onTap: () {
                            launchUrl(Uri(scheme: 'tel', path: '+254702778897'));
                          },
                        ),
                        _buildContactInfo(
                          Icons.phone,
                          '+254712529637',
                          onTap: () {
                            launchUrl(Uri(scheme: 'tel', path: '+254712529637'));
                          },
                        ),
                        _buildContactInfo(
                          Icons.email,
                          'soraproperties002@gmail.com',
                          onTap: () async {
                            final email = 'soraproperties002@gmail.com';
                            final url = kIsWeb
                              ? Uri.parse('https://mail.google.com/mail/?view=cm&fs=1&to=$email')
                              : Uri(scheme: 'mailto', path: email);
                            if (!await launchUrl(url)) {
                              // Handle error, e.g., show a snackbar
                            }
                          },
                        ),
                      ]),
                    ),
                  ],
                ],
              ),
              // Restructured the footer for small screens to use a Column to prevent overflow
              if (isSmallScreen) ...[
                const SizedBox(height: 20),
                _buildFooterColumn('Quick Links', [
                  _buildFooterLink('Home', '/home'),
                  // Add Airbnb after Home
                  _buildFooterLink('Airbnb', '/airbnb'),
                  // Add Buy, Rent, and Lease in place of Properties
                  _buildFooterLink('Buy', '/buy'),
                  _buildFooterLink('Rent', '/rent'),
                  _buildFooterLink('Lease', '/lease'),
                  _buildFooterLink('Agents', '/agents'),
                  _buildFooterLink('Blog', '/blogs'),
                  _buildFooterLink('Contact Us', '/contact'),
                ]),
                const SizedBox(height: 20),
                _buildFooterColumn('Legal', [
                  _buildFooterLink('Terms of Service', '/terms'),
                  _buildFooterLink('Privacy Policy', '/privacy'),
                  _buildFooterLink('Cookie Policy', '/cookies'),
                ]),
                const SizedBox(height: 20),
                _buildFooterColumn('Contact Us', [
                  _buildContactInfo(Icons.location_on, '123 Real Estate Avenue, Nairobi, Kenya'),
                  _buildContactInfo(
                    Icons.phone,
                    '+254702778897',
                    onTap: () {
                      launchUrl(Uri(scheme: 'tel', path: '+254702778897'));
                    },
                  ),
                  _buildContactInfo(
                    Icons.phone,
                    '+254712529637',
                    onTap: () {
                      launchUrl(Uri(scheme: 'tel', path: '+254712529637'));
                    },
                  ),
                  _buildContactInfo(
                    Icons.email,
                    'soraproperties002@gmail.com',
                    onTap: () async {
                      final email = 'soraproperties002@gmail.com';
                      final url = kIsWeb
                          ? Uri.parse('https://mail.google.com/mail/?view=cm&fs=1&to=$email')
                          : Uri(scheme: 'mailto', path: email);
                      if (!await launchUrl(url)) {
                        // Handle error, e.g., show a snackbar
                      }
                    },
                  ),
                ]),
              ],
              const Divider(color: Colors.white24, height: 40),
              Center(
                child: Text(
                  '© ${DateTime.now().year} Sora Properties Ltd. All rights reserved.',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          // NEW: Floating Action Button for Admin Screen (visible only on Web)
          // === Logic: Only visible if user is logged in AND is admin ===
          if (kIsWeb && userId != null)
            Positioned(
              left: 20,
              bottom: 20,
              // Wrap the button container in a FutureBuilder to check the admin status
              child: FutureBuilder<bool>(
                // Fetch the admin status from Firestore
                future: _firestoreService.checkAdminStatus(userId),
                builder: (context, snapshot) {
                  // Only render the button if the data is loaded and is true
                  if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
                    return Container(
                      // Added Container and Decoration to apply gradient
                      width: 56.0, // Default FAB size
                      height: 56.0, // Default FAB size
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28.0), // Half of size for circle
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E90FF), // Blue
                            Color(0xFF8A2BE2), // Blue Violet (Purple)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/admin');
                        },
                        // Set background color to transparent to show the gradient Container
                        backgroundColor: Colors.transparent,
                        // Remove shadow/elevation
                        elevation: 0,
                        // Ensure the splash effect is contained within the gradient
                        highlightElevation: 0,
                        tooltip: 'Admin Screen',
                        child: const Icon(Icons.shield, color: Colors.white),
                      ),
                    );
                  }
                  // If not logged in, not admin, or still loading, show nothing.
                  return const SizedBox.shrink();
                },
              ),
            ),
          // === END MODIFICATION ===
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: IconButton(
        icon: FaIcon(icon, color: Colors.white),
        onPressed: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            // Log error or show a snackbar to the user
          }
        },
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFooterLink(String text, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton(String text, String route, [bool isSelected = false]) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0A66C2) : const Color(0xFF0A66C2),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
          if (isSelected)
            Container(
              height: 2,
              width: 50,
              color: const Color(0xFF0A66C2),
            ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
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
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  // ADDED: Method to display a sign-in prompt screen
  Widget buildSignInPromptScreen(String destination) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Please sign in to view your listings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You need to be logged in to access your listings.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Sign In Now'),
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ADDED: Method to display a message when there is no data
  Widget buildEmptyState(String title, String subtitle, VoidCallback onAction, String actionLabel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A custom reusable header widget.
class CustomHeader extends StatelessWidget {
  final String text;

  const CustomHeader({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0A66C2),
      ),
    );
  }
}

// A custom reusable text field widget.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText = '',
    this.maxLines = 1,
    this.validator,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: validator,
    );
  }
}

// A custom reusable dropdown widget.
class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final List<DropdownMenuItem<T>>? items;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}

// A new custom widget for number picking.
class CustomNumberPicker extends StatelessWidget {
  final String labelText;
  final int value;
  final ValueChanged<int> onChanged;

  const CustomNumberPicker({
    Key? key,
    required this.labelText,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
              ),
              Text(
                '$value',
                style: const TextStyle(fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}