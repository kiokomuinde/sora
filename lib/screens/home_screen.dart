// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sora_app/screens/property_detail_screen.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import for FaIcon
import 'package:sora_app/data/property_data.dart'; // Import the centralized property data

class HomeScreen extends StatefulWidget {
  final AuthService authService;

  const HomeScreen({super.key, required this.authService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CommonWidgets commonWidgets;
  final TextEditingController _searchController = TextEditingController();

  String _currentListingTypeFilter = '';

  late List<Map<String, dynamic>> _popularPropertiesList;
  late List<Map<String, dynamic>> _hottestPropertiesList;
  late List<Map<String, dynamic>> _newPropertiesList;

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);

    final List<Map<String, dynamic>> mutableAllProperties = List<Map<String, dynamic>>.from(PropertyData.allProperties);

    if (mutableAllProperties.isEmpty) {
      _popularPropertiesList = [];
      _hottestPropertiesList = [];
      _newPropertiesList = [];
      return; // No properties to display
    }

    // Ensure we have enough properties for each list, repeating if necessary
    // This is for demonstration purposes to ensure carousels are never empty.
    final List<Map<String, dynamic>> tempAll = List.from(mutableAllProperties);
    while (tempAll.length < 30) { // Ensure at least 30 properties for better distribution
      tempAll.addAll(List.from(mutableAllProperties)); // Repeat properties if too few
    }
    tempAll.shuffle(); // Shuffle the larger temporary list

    // Populate lists ensuring they always have content for display
    // Take a maximum of 10 items for each, distributing them from the shuffled list
    _popularPropertiesList = tempAll.sublist(0, (tempAll.length * 0.3).toInt()).take(10).toList();
    _hottestPropertiesList = tempAll.sublist((tempAll.length * 0.3).toInt(), (tempAll.length * 0.6).toInt()).take(10).toList();
    _newPropertiesList = tempAll.sublist((tempAll.length * 0.6).toInt()).take(10).toList();

    // Fallback: If any list is still empty (e.g., due to very small initial PropertyData.allProperties),
    // ensure it gets at least one property.
    if (_popularPropertiesList.isEmpty && mutableAllProperties.isNotEmpty) {
      _popularPropertiesList.add(mutableAllProperties[0]);
    }
    if (_hottestPropertiesList.isEmpty && mutableAllProperties.isNotEmpty) {
      _hottestPropertiesList.add(mutableAllProperties[0]); // Could be the same as popular, acceptable for dummy data
    }
    if (_newPropertiesList.isEmpty && mutableAllProperties.isNotEmpty) {
      _newPropertiesList.add(mutableAllProperties[0]); // Could be the same, acceptable for dummy data
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    print('Search query from AppBar: $query');
    // Example: Navigate to property_listings with search query
    // Navigator.pushNamed(context, '/property_listings', arguments: {'searchQuery': query});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isLargeScreen = screenWidth >= 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.buildAppBar(
        showSearchBar: true,
        onSearchChanged: _performSearch,
        currentListingTypeFilter: _currentListingTypeFilter,
      ),
      endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Hero Section ---
            SizedBox(
              width: double.infinity,
              height: isLargeScreen ? 500 : (isMediumScreen ? 400 : 350),
              child: Stack(
                children: [
                  if (kIsWeb)
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/real_estate_hero.webp', // Ensure this asset path is correct
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF1E90FF),
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.white, size: 80),
                            ),
                          );
                        },
                      ),
                    ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            const Color(0xFF1E90FF).withOpacity(0.2),
                            Colors.purple.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your Dream Home Awaits',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isLargeScreen ? 56 : (isMediumScreen ? 48 : 40),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 20.0,
                                  color: Colors.black.withOpacity(0.7),
                                  offset: const Offset(3.0, 3.0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          BlinkingGradientText(
                            text: 'Explore millions of properties across Africa.',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 22 : (isMediumScreen ? 20 : 18),
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  blurRadius: 15.0,
                                  color: Colors.black.withOpacity(0.6),
                                  offset: const Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                            colors: const [
                              Colors.white,
                              Color(0xFF4B0082),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Popular Properties Section ---
            Padding(
              padding: EdgeInsets.only(
                top: 40.0,
                left: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                right: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                bottom: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Popular Properties',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A66C2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.star,
                          size: isLargeScreen ? 36 : (isMediumScreen ? 32 : 28),
                          color: Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _RecommendedPropertiesCarousel(
                      propertiesToDisplay: _popularPropertiesList,
                      isLargeScreen: isLargeScreen,
                      isMediumScreen: isMediumScreen,
                      buildPropertyCard: (property) => PropertyCardWithCarousel(
                        property: property,
                        onFavoriteToggle: (p) {
                          setState(() {
                            // Update favorite status in the centralized list
                            final index = PropertyData.allProperties.indexWhere((prop) => prop['title'] == p['title']);
                            if (index != -1) {
                              PropertyData.allProperties[index]['isFavorite'] = !PropertyData.allProperties[index]['isFavorite'];
                            }
                          });
                        },
                        isLoggedIn: widget.authService.currentUserNotifier.value != null,
                        showLoginPrompt: commonWidgets.showLoginSignupDialog, // Use commonWidgets' method
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Hottest in Sora Section ---
            Padding(
              padding: EdgeInsets.only(
                top: 40.0,
                left: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                right: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                bottom: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hottest in Sora',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A66C2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.local_fire_department,
                          size: isLargeScreen ? 36 : (isMediumScreen ? 32 : 28),
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _RecommendedPropertiesCarousel(
                      propertiesToDisplay: _hottestPropertiesList,
                      isLargeScreen: isLargeScreen,
                      isMediumScreen: isMediumScreen,
                      buildPropertyCard: (property) => PropertyCardWithCarousel(
                        property: property,
                        onFavoriteToggle: (p) {
                          setState(() {
                            // Update favorite status in the centralized list
                            final index = PropertyData.allProperties.indexWhere((prop) => prop['title'] == p['title']);
                            if (index != -1) {
                              PropertyData.allProperties[index]['isFavorite'] = !PropertyData.allProperties[index]['isFavorite'];
                            }
                          });
                        },
                        isLoggedIn: widget.authService.currentUserNotifier.value != null,
                        showLoginPrompt: commonWidgets.showLoginSignupDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- NEW PROPERTIES SECTION (Corrected to include carousel) ---
            Padding(
              padding: EdgeInsets.only(
                top: 40.0,
                left: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                right: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                bottom: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'New Properties',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A66C2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.fiber_new,
                          size: isLargeScreen ? 36 : (isMediumScreen ? 32 : 28),
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _RecommendedPropertiesCarousel(
                      propertiesToDisplay: _newPropertiesList,
                      isLargeScreen: isLargeScreen,
                      isMediumScreen: isMediumScreen,
                      buildPropertyCard: (property) => PropertyCardWithCarousel(
                        property: property,
                        onFavoriteToggle: (p) {
                          setState(() {
                            // Update favorite status in the centralized list
                            final index = PropertyData.allProperties.indexWhere((prop) => prop['title'] == p['title']);
                            if (index != -1) {
                              PropertyData.allProperties[index]['isFavorite'] = !PropertyData.allProperties[index]['isFavorite'];
                            }
                          });
                        },
                        isLoggedIn: widget.authService.currentUserNotifier.value != null,
                        showLoginPrompt: commonWidgets.showLoginSignupDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Why Choose SORA? Section ---
            Container(
              width: double.infinity,
              color: Colors.grey[50],
              padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isLargeScreen ? 900 : (isMediumScreen ? 600 : double.infinity)),
                child: Column(
                  children: [
                    Text(
                      'Why Choose SORA?',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A66C2),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 30.0,
                      runSpacing: 30.0,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildValueCard(
                          icon: Icons.lightbulb_outline,
                          title: 'Innovation',
                          description: 'Leveraging cutting-edge tech for smarter property searches.',
                        ),
                        _buildValueCard(
                          icon: Icons.security,
                          title: 'Trust & Transparency',
                          description: 'Honest dealings and clear information, always.',
                        ),
                        _buildValueCard(
                          icon: Icons.people_alt_outlined,
                          title: 'Client-Centric',
                          description: 'Your needs are our priority, with personalized support.',
                        ),
                        _buildValueCard(
                          icon: Icons.verified_outlined,
                          title: 'Verified Listings',
                          description: 'Access to genuine properties, thoroughly vetted for quality.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- How It Works Section ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isLargeScreen ? 900 : (isMediumScreen ? 700 : double.infinity)),
                child: Column(
                  children: [
                    Text(
                      'How It Works',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A66C2),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        _buildProcessStep(
                          stepNumber: 1,
                          icon: Icons.search,
                          title: 'Explore Listings',
                          description: 'Browse millions of properties with detailed photos and virtual tours. Use our powerful search filters to narrow down your options.',
                          isLargeScreen: isLargeScreen,
                        ),
                        _buildProcessStep(
                          stepNumber: 2,
                          icon: Icons.connect_without_contact,
                          title: 'Connect with Experts',
                          description: 'Get in touch with qualified real estate agents and brokers who can guide you through the process and answer your questions.',
                          isLargeScreen: isLargeScreen,
                        ),
                        _buildProcessStep(
                          stepNumber: 3,
                          icon: Icons.home_work_outlined,
                          title: 'Secure Your Dream Property',
                          description: 'From offers to closing, we\'ll support you every step to make your property acquisition smooth and successful.',
                          isLargeScreen: isLargeScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- Sell Your Property Section ---
            _buildSellSection(isLargeScreen: isLargeScreen || isMediumScreen),

            const SizedBox(height: 40),

            // --- Footer ---
            commonWidgets.buildFooter(), // Use the common footer
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    bool showViewAll = false,
    VoidCallback? onViewAllPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
        vertical: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A66C2),
                ),
              ),
              if (showViewAll && onViewAllPressed != null)
                TextButton(
                  onPressed: onViewAllPressed,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: const Color(0xFF1E90FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: isLargeScreen ? 250 : (isMediumScreen ? 220 : double.infinity),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isLargeScreen ? 60 : 50,
              color: const Color(0xFF1E90FF),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: isLargeScreen ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A66C2),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStep({
    required int stepNumber,
    required IconData icon,
    required String title,
    required String description,
    required bool isLargeScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: isLargeScreen
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF1E90FF),
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 30, color: const Color(0xFF0A66C2)),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      )
          : Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF1E90FF),
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Icon(icon, size: 28, color: const Color(0xFF0A66C2)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSellSection({required bool isLargeScreen}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 80 : 40,
        horizontal: isLargeScreen ? 100 : 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ready to Sell Your Property?',
            style: TextStyle(
              fontSize: isLargeScreen ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'List with Sora for maximum exposure and a seamless selling experience.',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to a "List Your Property" or "Contact Us" page
              commonWidgets.showLoginSignupDialog(); // Or navigate directly if user is logged in
            },
            icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF0A66C2)),
            label: const Text(
              'List Your Property',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              shadowColor: Colors.black.withOpacity(0.4),
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for carousels
class _RecommendedPropertiesCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> propertiesToDisplay;
  final bool isLargeScreen;
  final bool isMediumScreen;
  final Widget Function(Map<String, dynamic> property) buildPropertyCard;

  const _RecommendedPropertiesCarousel({
    required this.propertiesToDisplay,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.buildPropertyCard,
  });

  @override
  State<_RecommendedPropertiesCarousel> createState() => _RecommendedPropertiesCarouselState();
}

class _RecommendedPropertiesCarouselState extends State<_RecommendedPropertiesCarousel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300, // Adjust scroll amount as needed
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300, // Adjust scroll amount as needed
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.propertiesToDisplay.isEmpty) {
      return Center(
        child: Text(
          'No properties available in this category.',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      );
    }

    final double itemWidth = widget.isLargeScreen ? 300 : (widget.isMediumScreen ? 250 : 200);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: widget.isLargeScreen ? 450 : (widget.isMediumScreen ? 400 : 350), // Adjust height as needed
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.propertiesToDisplay.length,
            itemBuilder: (context, index) {
              final property = widget.propertiesToDisplay[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  width: itemWidth,
                  child: widget.buildPropertyCard(property),
                ),
              );
            },
          ),
        ),
        if (widget.propertiesToDisplay.length > (widget.isLargeScreen ? 3 : (widget.isMediumScreen ? 2 : 1))) // Only show arrows if there are more items than fit on screen
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 30),
              onPressed: _scrollLeft,
            ),
          ),
        if (widget.propertiesToDisplay.length > (widget.isLargeScreen ? 3 : (widget.isMediumScreen ? 2 : 1))) // Only show arrows if there are more items than fit on screen
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 30),
              onPressed: _scrollRight,
            ),
          ),
      ],
    );
  }
}

// Property Card Widget (as defined in previous common_widgets or property_card.dart)
// This is a simplified version for demonstration.
// In a real app, this would likely be in its own file.
class PropertyCardWithCarousel extends StatefulWidget {
  final Map<String, dynamic> property;
  final ValueChanged<Map<String, dynamic>> onFavoriteToggle;
  final bool isLoggedIn;
  final VoidCallback showLoginPrompt;

  const PropertyCardWithCarousel({
    super.key,
    required this.property,
    required this.onFavoriteToggle,
    required this.isLoggedIn,
    required this.showLoginPrompt,
  });

  @override
  State<PropertyCardWithCarousel> createState() => _PropertyCardWithCarouselState();
}

class _PropertyCardWithCarouselState extends State<PropertyCardWithCarousel> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailScreen(property: widget.property),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      widget.property['images'][0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        widget.property['isFavorite'] == true ? Icons.favorite : Icons.favorite_border,
                        color: widget.property['isFavorite'] == true ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        if (widget.isLoggedIn) {
                          widget.onFavoriteToggle(widget.property);
                        } else {
                          widget.showLoginPrompt();
                        }
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        widget.property['listingType'],
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.property['price'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.property['title'],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.bed, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.property['bedrooms']} Beds',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.bathtub, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.property['bathrooms']} Baths',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.property['location'],
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Gradient Text Widget (moved from previous common_widgets or home_screen)
class GradientTextWidget extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;

  const GradientTextWidget({
    super.key,
    required this.text,
    required this.style,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

class BlinkingGradientText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;

  const BlinkingGradientText({
    super.key,
    required this.text,
    required this.style,
    required this.colors,
  });

  @override
  State<BlinkingGradientText> createState() => _BlinkingGradientTextState();
}

class _BlinkingGradientTextState extends State<BlinkingGradientText> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkPurple = Color(0xFF4B0082);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final Color interpolatedColor = Color.lerp(Colors.white, darkPurple, _animation.value)!;

        return GradientTextWidget(
          text: widget.text,
          style: widget.style.copyWith(color: interpolatedColor), // Apply interpolated color to style
          colors: widget.colors, // Still pass original colors for the gradient effect
        );
      },
    );
  }
}
