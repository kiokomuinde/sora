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
    } else {
      // Initialize property lists with sample data.
      // For a real app, this would come from a backend or more complex filtering.
      _popularPropertiesList = List.from(mutableAllProperties.where((p) => p['listingType'] == 'Rent').take(5));
      _hottestPropertiesList = List.from(mutableAllProperties.where((p) => p['listingType'] == 'Buy').take(5));
      _newPropertiesList = List.from(mutableAllProperties.where((p) => p['listingType'] == 'Lease').take(5));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      appBar: commonWidgets.buildAppBar(
        // Pass the currentListingTypeFilter to AppBar if it uses it for highlighting
        currentListingTypeFilter: _currentListingTypeFilter,
        // No need to pass onSearchChanged, onListingTypeFilterChanged, showLoginSignupDialog, authService
        // as common_widgets.buildAppBar doesn't accept them directly in its current signature.
        // authService is already part of the CommonWidgets instance.
      ),
      endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null, // Use drawer for mobile/tablet
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(isLargeScreen, isMediumScreen),

            // Removed Search Section as per request

            // Categories Section (existing)
            _buildCategoriesSection(isLargeScreen, isMediumScreen),

            // Popular Properties Section (Now a horizontal carousel)
            _buildPropertiesCarousel(
              context,
              'Popular Properties',
              _popularPropertiesList,
              isLargeScreen,
              isMediumScreen,
            ),

            // Hottest Deals Section (Now a horizontal carousel)
            _buildPropertiesCarousel(
              context,
              'Hottest Deals',
              _hottestPropertiesList,
              isLargeScreen,
              isMediumScreen,
            ),

            // New in Market Section (Now a horizontal carousel)
            _buildPropertiesCarousel(
              context,
              'New in Market',
              _newPropertiesList,
              isLargeScreen,
              isMediumScreen,
            ),

            // Call to Action Section (existing)
            _buildCallToActionSection(isLargeScreen, isMediumScreen),

            // Testimonials Section (existing)
            _buildTestimonialsSection(isLargeScreen, isMediumScreen),

            // Footer
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isLargeScreen, bool isMediumScreen) {
    return Container(
      width: double.infinity,
      height: isLargeScreen ? 500 : (isMediumScreen ? 400 : 300),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/hero_image.webp'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlinkingGradientText(
              text: 'Find Your Dream Home',
              style: TextStyle(
                fontSize: isLargeScreen ? 60 : (isMediumScreen ? 45 : 30),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              colors: const [Colors.white, Color(0xFF4B0082)], // White to Dark Purple
            ),
            SizedBox(height: isLargeScreen ? 20 : 10),
            Text(
              'Explore thousands of properties for sale, rent, and lease.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLargeScreen ? 20 : (isMediumScreen ? 16 : 14),
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: isLargeScreen ? 40 : 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeroButton('Buy', () => Navigator.pushNamed(context, '/buy')),
                SizedBox(width: isLargeScreen ? 20 : 10),
                _buildHeroButton('Rent', () => Navigator.pushNamed(context, '/rent')),
                SizedBox(width: isLargeScreen ? 20 : 10),
                _buildHeroButton('Lease', () => Navigator.pushNamed(context, '/lease')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E90FF), // Dodger Blue
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 5,
      ),
      child: Text(text),
    );
  }

  // Removed _buildSearchBarSection entirely.

  Widget _buildCategoriesSection(bool isLargeScreen, bool isMediumScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 60 : 30,
        horizontal: isLargeScreen ? 100 : 20,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Categories',
            style: TextStyle(
              fontSize: isLargeScreen ? 36 : (isMediumScreen ? 28 : 22),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A66C2),
            ),
          ),
          SizedBox(height: isLargeScreen ? 40 : 20),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (isLargeScreen) {
                crossAxisCount = 4;
              } else if (isMediumScreen) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 1;
              }
              double childAspectRatio = isLargeScreen ? 1.2 : (isMediumScreen ? 1.5 : 2.0);

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                mainAxisSpacing: isLargeScreen ? 30 : 20,
                crossAxisSpacing: isLargeScreen ? 30 : 20,
                children: [
                  _buildCategoryCard(Icons.house, 'Buy Property', 'Find your dream home to own.', () {
                    Navigator.pushNamed(context, '/buy'); // Changed to /buy
                  }),
                  _buildCategoryCard(Icons.apartment, 'Rent Property', 'Discover perfect apartments and houses for rent.', () {
                    Navigator.pushNamed(context, '/rent'); // Changed to /rent
                  }),
                  _buildCategoryCard(Icons.store, 'Commercial Lease', 'Browse commercial spaces for your business.', () {
                    Navigator.pushNamed(context, '/lease'); // Changed to /lease
                  }),
                  _buildCategoryCard(Icons.agriculture, 'Land & Plots', 'Invest in land for future development.', () {
                    // This will navigate to a generic property listing, might need a specific '/plots' route
                    Navigator.pushNamed(context, '/buy', arguments: {'listingType': 'Plot'});
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String title, String description, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: const Color(0xFF1E90FF)),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A66C2),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesCarousel(BuildContext context, String title, List<Map<String, dynamic>> properties, bool isLargeScreen, bool isMediumScreen) {
    if (properties.isEmpty) {
      return const SizedBox.shrink(); // Don't show section if no properties
    }
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 60 : 30,
        horizontal: isLargeScreen ? 100 : 20,
      ),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isLargeScreen ? 36 : (isMediumScreen ? 28 : 22),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A66C2),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to the full property listing page based on title
                  String listingType = '';
                  if (title == 'Popular Properties') {
                    listingType = 'Rent'; // Example: Popular shows Rent
                  } else if (title == 'Hottest Deals') {
                    listingType = 'Buy'; // Example: Hottest shows Buy
                  } else if (title == 'New in Market') {
                    listingType = 'Lease'; // Example: New shows Lease
                  }
                  Navigator.pushNamed(context, '/property_listing', arguments: {'listingType': listingType});
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF1E90FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 40 : 20),
          SizedBox(
            height: isLargeScreen ? 380 : (isMediumScreen ? 320 : 280), // Adjust height for carousel
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: _buildPropertyCard(context, property, isLargeScreen, isMediumScreen),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, Map<String, dynamic> property, bool isLargeScreen, bool isMediumScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(property: property),
          ),
        );
      },
      child: Container(
        width: isLargeScreen ? 300 : (isMediumScreen ? 250 : 220),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                property['images']![0],
                height: isLargeScreen ? 200 : (isMediumScreen ? 160 : 140),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['price']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property['location']!,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (property['bedrooms'] > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${property['bedrooms']} Beds',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                  if (property['bathrooms'] > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.bathtub, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${property['bathrooms']} Baths',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                  if (property['area'] != null && property['area'] != "0") ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.square_foot, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${property['area']} sqft',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallToActionSection(bool isLargeScreen, bool isMediumScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 80 : 40,
        horizontal: isLargeScreen ? 100 : 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A66C2), Color(0xFF1E90FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to find your perfect property?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isLargeScreen ? 40 : (isMediumScreen ? 32 : 26),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLargeScreen ? 30 : 20),
          Text(
            'Contact our expert agents today for personalized assistance and guidance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : (isMediumScreen ? 16 : 14),
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: isLargeScreen ? 40 : 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/contact');
            },
            icon: const Icon(Icons.phone, size: 28),
            label: const Text(
              'Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0A66C2),
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 40 : 30,
                vertical: isLargeScreen ? 20 : 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(bool isLargeScreen, bool isMediumScreen) {
    // Mock testimonials data
    final List<Map<String, String>> testimonials = [
      {
        'quote': 'SORA made finding our dream apartment effortless! Their agents were incredibly helpful and guided us every step of the way. Highly recommend!',
        'author': 'Alice Johnson',
        'location': 'Nairobi, Kenya',
      },
      {
        'quote': 'Selling our home through SORA was a breeze. The process was transparent, and we got a fantastic offer much faster than we expected. Thank you, SORA!',
        'author': 'Bob Williams',
        'location': 'Mombasa, Kenya',
      },
      {
        'quote': 'As a first-time homebuyer, I was overwhelmed. SORA\'s resources and patient team made the journey enjoyable and stress-free. I\'m so happy in my new home!',
        'author': 'Carol Davis',
        'location': 'Kisumu, Kenya',
      },
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 60 : 30,
        horizontal: isLargeScreen ? 100 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'What Our Clients Say',
                style: TextStyle(
                  fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A66C2),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/testimonials');
                },
                child: const Text(
                  'View All Testimonials',
                  style: TextStyle(
                    color: Color(0xFF1E90FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 30 : 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
              crossAxisSpacing: isLargeScreen ? 30 : 20,
              mainAxisSpacing: isLargeScreen ? 30 : 20,
              childAspectRatio: isLargeScreen ? 1.0 : (isMediumScreen ? 0.9 : 1.1),
            ),
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              final testimonial = testimonials[index];
              return _buildTestimonialCard(testimonial);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, String> testimonial) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.format_quote, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              testimonial['quote']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 15),
            Text(
              '- ${testimonial['author']!}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A66C2),
              ),
            ),
            Text(
              testimonial['location']!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
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

class GradientTextWidget extends StatelessWidget {
  const GradientTextWidget({
    super.key,
    required this.text,
    required this.style,
    required this.colors,
  });

  final String text;
  final TextStyle style;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(text, style: style),
    );
  }
}
