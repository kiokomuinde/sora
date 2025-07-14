// lib/widgets/common_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/services/auth_service.dart';

// This class provides common widgets like AppBar and Footer for consistent UI across screens.
class CommonWidgets {
  final BuildContext context;
  final AuthService authService;

  CommonWidgets({required this.context, required this.authService});

  // Helper method to show login/signup dialog
  void showLoginSignupDialog() { // Made public for direct access from other widgets
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E90FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sign Up'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
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
                Navigator.of(dialogContext).pop();
                Navigator.pushNamed(context, '/signin'); // Navigate to signin screen
              },
            ),
          ],
        );
      },
    );
  }

  // Handles user sign out
  Future<void> _handleSignOut() async {
    try {
      await authService.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully!')),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An unknown error occurred.";
      if (e.code == 'network-request-failed') {
        errorMessage = "Network error. Please check your internet connection and try again.";
      } else if (e.code == 'requires-recent-login') {
        errorMessage = "This operation is sensitive and requires recent authentication. Please log in again.";
      } else {
        errorMessage = "Sign out failed: ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred during sign out: $e')),
      );
    }
  }

  // Builds the consistent AppBar for all screens
  PreferredSizeWidget buildAppBar({
    bool showSearchBar = false,
    TextEditingController? searchController, // Added parameter for search bar controller
    ValueChanged<String>? onSearchChanged, // Added parameter for search bar onChanged callback
    String currentListingTypeFilter = '',
    ValueChanged<String>? onListingTypeFilterChanged, // Added parameter for listing type filter changes
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;

    Widget _buildAppBarButton(String text, VoidCallback onPressed, {bool isSelected = false, bool isFilled = false, IconData? icon}) {
      return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : const Color(0xFF0A66C2),
          backgroundColor: isSelected ? const Color(0xFF0A66C2) : (isFilled ? const Color(0xFF0A66C2) : Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: isFilled ? BorderSide.none : const BorderSide(color: Color(0xFF0A66C2), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: isSelected || isFilled ? Colors.white : const Color(0xFF0A66C2)),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected || isFilled ? FontWeight.bold : FontWeight.normal,
                color: isSelected || isFilled ? Colors.white : const Color(0xFF0A66C2),
              ),
            ),
          ],
        ),
      );
    }

    return PreferredSize(
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
                Navigator.pushNamed(context, '/home');
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/sora_logo.png', // Ensure this asset path is correct
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
                          // Use onListingTypeFilterChanged if provided, otherwise push named
                          if (onListingTypeFilterChanged != null) {
                            onListingTypeFilterChanged('Buy');
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/property_listings',
                              arguments: {'listingType': 'Buy'},
                            );
                          }
                        },
                        isSelected: currentListingTypeFilter == 'Buy',
                      ),
                      const SizedBox(width: 20),
                      _buildAppBarButton(
                        'Rent',
                            () {
                          // Use onListingTypeFilterChanged if provided, otherwise push named
                          if (onListingTypeFilterChanged != null) {
                            onListingTypeFilterChanged('Rent');
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/property_listings',
                              arguments: {'listingType': 'Rent'},
                            );
                          }
                        },
                        isSelected: currentListingTypeFilter == 'Rent',
                      ),
                      const SizedBox(width: 20),
                      _buildAppBarButton(
                        'Lease',
                            () {
                          // Use onListingTypeFilterChanged if provided, otherwise push named
                          if (onListingTypeFilterChanged != null) {
                            onListingTypeFilterChanged('Lease');
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/property_listings',
                              arguments: {'listingType': 'Lease'},
                            );
                          }
                        },
                        isSelected: currentListingTypeFilter == 'Lease',
                      ),
                      const SizedBox(width: 40),
                      if (showSearchBar)
                        SizedBox(
                          width: 250,
                          child: TextField(
                            controller: searchController, // Assign the controller
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            ),
                            onChanged: onSearchChanged, // Assign the onChanged callback
                          ),
                        ),
                      if (showSearchBar) const SizedBox(width: 20),
                      _buildAppBarButton('List Property', () {
                        if (authService.currentUserNotifier.value == null) {
                          showLoginSignupDialog(); // Use instance method
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Redirecting to list property page (coming soon)!')),
                          );
                        }
                      }, isFilled: true),
                      const SizedBox(width: 20),
                      ValueListenableBuilder<User?>(
                        valueListenable: authService.currentUserNotifier,
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
    );
  }

  // Builds the consistent Drawer for smaller screens
  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 100.0,
            decoration: const BoxDecoration(
              color: Color(0xFF1E90FF),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ValueListenableBuilder<User?>(
                  valueListenable: authService.currentUserNotifier,
                  builder: (context, user, child) {
                    return Text(
                      user != null ? 'Hello, ${user.email?.split('@').first ?? "User"}' : 'SORA Menu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            title: const Text('Buy'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Buy'});
            },
          ),
          ListTile(
            title: const Text('Rent'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Rent'});
            },
          ),
          ListTile(
            title: const Text('Lease'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Lease'});
            },
          ),
          ListTile(
            title: const Text('List Property'),
            onTap: () {
              Navigator.pop(context);
              if (authService.currentUserNotifier.value == null) {
                showLoginSignupDialog(); // Use instance method
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Redirecting to list property page (coming soon)!')),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Agents'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/agents');
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            title: const Text('Contact'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contact');
            },
          ),
          ListTile(
            title: const Text('Careers'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/careers');
            },
          ),
          ListTile(
            title: const Text('Blog'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/blogs');
            },
          ),
          // New links for the requested screens
          ListTile(
            title: const Text('Testimonials'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/testimonials');
            },
          ),
          ListTile(
            title: const Text('FAQs'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/faqs');
            },
          ),
          ListTile(
            title: const Text('Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/support');
            },
          ),
          ListTile(
            title: const Text('General Terms'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/terms');
            },
          ),
          ListTile(
            title: const Text('Local Guides'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/local_guides');
            },
          ),
          ListTile(
            title: const Text('Events'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/events');
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/terms_of_service');
            },
          ),
          ListTile(
            title: const Text('Sitemap'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/sitemap');
            },
          ),
          // Conditionally render Login/Logout button in drawer
          ValueListenableBuilder<User?>(
            valueListenable: authService.currentUserNotifier,
            builder: (context, user, child) {
              if (user != null) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0A66C2),
                    child: (user.email != null && user.email!.isNotEmpty)
                        ? Text(
                            user.email![0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : const Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text('Logout'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    _handleSignOut();
                  },
                );
              } else {
                return ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Login'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/signin');
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Builds the consistent Footer for all screens
  Widget buildFooter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    TextEditingController _newsletterEmailController = TextEditingController();

    Widget _buildFooterColumn(String title, List<Map<String, dynamic>> links) {
      return Column(
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
          const SizedBox(height: 10),
          ...links.map((link) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                if (link['route'] != null) {
                  if (link['route'].endsWith('_placeholder')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${link['title']} functionality coming soon!')),
                    );
                  } else {
                    Navigator.pushNamed(context, link['route'] as String, arguments: link['args']);
                  }
                }
              },
              child: Text(
                link['title'] as String,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          )).toList(),
        ],
      );
    }

    Widget _buildNewsletterSection() {
      return Container(
        width: 300,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subscribe to our Newsletter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A66C2),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newsletterEmailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
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
      );
    }

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 24.0),
      color: Colors.grey[100], // Consistent background color
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isLargeScreen ? 1200 : (isMediumScreen ? 800 : double.infinity)),
        child: Column(
          children: [
            Wrap(
              spacing: 40.0,
              runSpacing: 20.0,
              alignment: WrapAlignment.center,
              children: [
                _buildFooterColumn('Sora', [
                  {'title': 'About', 'route': '/about'},
                  {'title': 'Agents', 'route': '/agents'},
                  {'title': 'Contact', 'route': '/contact'},
                  {'title': 'Careers', 'route': '/careers'},
                  {'title': 'Blog', 'route': '/blogs'},
                  {'title': 'Testimonials', 'route': '/testimonials'},
                ]),
                _buildFooterColumn('Resources', [
                  {'title': 'Buy', 'route': '/property_listings', 'args': {'listingType': 'Buy'}},
                  {'title': 'Rent', 'route': '/property_listings', 'args': {'listingType': 'Rent'}},
                  {'title': 'Lease', 'route': '/property_listings', 'args': {'listingType': 'Lease'}},
                  {'title': 'FAQs', 'route': '/faqs'},
                  {'title': 'Support', 'route': '/support'},
                  {'title': 'General Terms', 'route': '/terms'},
                ]),
                _buildFooterColumn('Community', [
                  {'title': 'Local Guides', 'route': '/local_guides'},
                  {'title': 'Events', 'route': '/events'},
                ]),
                _buildFooterColumn('Legal', [
                  {'title': 'Privacy Policy', 'route': '/privacy_policy_placeholder'},
                  {'title': 'Terms of Service', 'route': '/terms_of_service'},
                  {'title': 'Sitemap', 'route': '/sitemap'},
                ]),
                _buildNewsletterSection(),
              ],
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
      ),
    );
  }
}

// Moved to common_widgets.dart as a shared utility
extension StringExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}
