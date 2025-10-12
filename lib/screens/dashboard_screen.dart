// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
// Import the actual Firestore service
import 'package:sora_app/services/firestore_service.dart'; 

class DashboardScreen extends StatefulWidget {
  final AuthService authService;
  
  // NOTE: If you are using dependency injection, you should also pass FirestoreService here.
  // For simplicity, we initialize it in initState.

  const DashboardScreen({Key? key, required this.authService}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late CommonWidgets commonWidgets;
  
  // State variables for dynamic data
  int _listingCount = 0;
  int _favoritesCount = 0;
  bool _isLoading = true; // Tracks the data fetching state

  // Initialize the Firestore service
  final FirestoreService _firestoreService = FirestoreService(); 

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    _fetchDashboardData();
  }
  
  // Data Fetching Method
  Future<void> _fetchDashboardData() async {
    // 1. Get the current user's ID
    // NOTE: Ensure your AuthService has a working getCurrentUserUid() method.
    final String? userId = widget.authService.getCurrentUserUid();

    if (userId == null) {
      print('User ID is null. Cannot fetch dashboard data.');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // 2. Fetch data concurrently using Future.wait
      final Future<int> listingsFuture = _firestoreService.getMyListingsCount(userId);
      final Future<int> favoritesFuture = _firestoreService.getFavoritesCount(userId);

      final List<int> results = await Future.wait([listingsFuture, favoritesFuture]);

      // 3. Update state with fetched data
      if (mounted) {
        setState(() {
          _listingCount = results[0];
          _favoritesCount = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading even if there's an error
        });
        // Optionally show a user-friendly error message
      }
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
                    'Dashboard',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Welcome to your personal dashboard. Manage your properties and account settings.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Dashboard Content
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : (isMediumScreen ? 40 : 30),
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: Column(
                children: [
                  // Quick Stats Cards
                  // Show loading indicator while data is being fetched
                  _isLoading 
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: Color(0xFF0A66C2)),
                      ),
                    )
                  : GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isLargeScreen ? 4 : (isMediumScreen ? 2 : 1),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: isLargeScreen ? 1.2 : 1.5,
                    children: [
                      _buildStatCard(
                        'My Listings',
                        // AUTOMATED VALUE
                        _listingCount.toString(), 
                        Icons.add_home_work,
                        Color(0xFF0A66C2),
                        () => Navigator.pushNamed(context, '/my_listings'),
                      ),
                      _buildStatCard(
                        'Favorites',
                        // AUTOMATED VALUE
                        _favoritesCount.toString(), 
                        Icons.favorite,
                        Colors.red,
                        () => Navigator.pushNamed(context, '/my_favorites'),
                      ),
                      _buildStatCard(
                        'Recently Viewed',
                        '8',
                        Icons.history,
                        Colors.orange,
                        () => Navigator.pushNamed(context, '/recently_viewed'),
                      ),
                      _buildStatCard(
                        'Profile Settings',
                        '',
                        Icons.settings,
                        Colors.grey,
                        () => Navigator.pushNamed(context, '/profile_settings'),
                      ),
                    ],
                  ),

                  SizedBox(height: isLargeScreen ? 60 : 40),

                  // Recent Activity Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildActivityItem(
                          'Viewed "Luxury Villa in Westlands"',
                          '2 hours ago',
                          Icons.visibility,
                        ),
                        _buildActivityItem(
                          'Added "Modern Apartment in Kilimani" to favorites',
                          '1 day ago',
                          Icons.favorite,
                        ),
                        _buildActivityItem(
                          'Listed "3BR House in Karen"',
                          '3 days ago',
                          Icons.add_home_work,
                        ),
                        _buildActivityItem(
                          'Updated profile information',
                          '1 week ago',
                          Icons.person,
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (value.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF0A66C2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Color(0xFF0A66C2)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}