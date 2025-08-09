// lib/screens/profile_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets
import 'package:firebase_auth/firebase_auth.dart'; // Import for User

class ProfileSettingsScreen extends StatefulWidget {
  final AuthService authService;

  const ProfileSettingsScreen({super.key, required this.authService});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late CommonWidgets commonWidgets;
  User? _currentUser;

  // Sample data for demonstration
  String _userName = 'John Doe';
  String _userEmail = 'john.doe@example.com';
  String _userPhone = '+1 (555) 123-4567';
  String _userAddress = '123 Real Estate Ave, City, Country';

  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    setState(() {
      _currentUser = widget.authService.getCurrentUser();
      if (_currentUser != null) {
        _userEmail = _currentUser!.email ?? 'N/A';
        _userName = _currentUser!.displayName ?? 'N/A';
        // In a real app, you'd fetch phone, address, etc., from a database
      }
    });
  }

  Future<void> _signOut() async {
    await widget.authService.signOut();
    // Navigate back to home or sign-in screen after signOut
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
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
                    'Profile Settings',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Manage your personal information, account settings, and preferences.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                vertical: 30,
              ),
              child: _currentUser == null
                  ? Column(
                      children: [
                        const Text(
                          'You are not logged in.',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signin');
                          },
                          child: const Text('Login Now'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Profile Information
                        _buildSectionCard(
                          title: 'Personal Information',
                          children: [
                            _buildInfoRow('Name', _userName),
                            _buildInfoRow('Email', _userEmail),
                            _buildInfoRow('Phone', _userPhone),
                            _buildInfoRow('Address', _userAddress),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement edit profile functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Edit Profile coming soon!'))
                                  );
                                },
                                child: const Text('Edit Profile'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Account Settings
                        _buildSectionCard(
                          title: 'Account Settings',
                          children: [
                            _buildSettingItem(
                              'Change Password',
                              'Update your account password',
                              Icons.lock_outline,
                              () {
                                // TODO: Implement change password functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Change Password coming soon!'))
                                );
                              },
                            ),
                            _buildSettingItem(
                              'Change Email',
                              'Update your account email address',
                              Icons.email_outlined,
                              () {
                                // TODO: Implement change email functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Change Email coming soon!'))
                                );
                              },
                            ),
                            _buildSettingItem(
                              'Delete Account',
                              'Permanently delete your account',
                              Icons.delete_forever,
                              () {
                                // TODO: Implement delete account functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Delete Account coming soon!'))
                                );
                              },
                              isDestructive: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Notification Preferences
                        _buildSectionCard(
                          title: 'Notification Preferences',
                          children: [
                            _buildToggleSetting(
                              'Email Notifications',
                              'Receive updates via email',
                              _emailNotifications,
                              (bool value) {
                                setState(() {
                                  _emailNotifications = value;
                                  // TODO: Update notification preference in backend
                                });
                              },
                            ),
                            _buildToggleSetting(
                              'SMS Notifications',
                              'Receive alerts via SMS',
                              _smsNotifications,
                              (bool value) {
                                setState(() {
                                  _smsNotifications = value;
                                  // TODO: Update notification preference in backend
                                });
                              },
                            ),
                            _buildToggleSetting(
                              'Push Notifications',
                              'Get instant app notifications',
                              _pushNotifications,
                              (bool value) {
                                setState(() {
                                  _pushNotifications = value;
                                  // TODO: Update notification preference in backend
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Privacy Settings
                        _buildSectionCard(
                          title: 'Privacy Settings',
                          children: [
                            _buildSettingItem(
                              'Manage Data Permissions',
                              'Control how your data is used',
                              Icons.privacy_tip_outlined,
                              () {
                                // TODO: Implement data permissions management
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Data Permissions coming soon!'))
                                );
                              },
                            ),
                            _buildSettingItem(
                              'View Privacy Policy',
                              'Review our privacy policy',
                              Icons.policy_outlined,
                              () {
                                Navigator.pushNamed(context, '/privacy_policy');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Linked Accounts (Placeholder)
                        _buildSectionCard(
                          title: 'Linked Accounts',
                          children: [
                            _buildSettingItem(
                              'Connect Social Accounts',
                              'Link your social media profiles',
                              Icons.link,
                              () {
                                // TODO: Implement social account linking
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Social Account Linking coming soon!'))
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Subscription/Membership Details (Placeholder)
                        _buildSectionCard(
                          title: 'Subscription Details',
                          children: [
                            _buildInfoRow('Plan', 'Premium User'),
                            _buildInfoRow('Expires On', '2025-12-31'),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement manage subscription functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Manage Subscription coming soon!'))
                                  );
                                },
                                child: const Text('Manage Subscription'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Activity Log (Placeholder)
                        _buildSectionCard(
                          title: 'Activity Log',
                          children: [
                            _buildActivityLogItem('Logged in from new device', '2025-07-30 10:00 AM'),
                            _buildActivityLogItem('Updated profile picture', '2025-07-28 03:15 PM'),
                            _buildActivityLogItem('Viewed "Luxury Villa in Westlands"', '2025-07-25 11:00 AM'),
                            _buildActivityLogItem('Added "Modern Apartment in Kilimani" to favorites', '2025-07-20 09:00 AM'),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Sign Out Button
                        Center(
                          child: ElevatedButton(
                            onPressed: _signOut,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Background color
                              foregroundColor: Colors.white, // Text color
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A66C2),
              ),
            ),
            const Divider(height: 30, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150, // Increased width for labels
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF0A66C2)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildToggleSetting(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF0A66C2),
    );
  }

  Widget _buildActivityLogItem(String activity, String timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  timestamp,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
