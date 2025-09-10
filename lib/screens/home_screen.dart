// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import for FaIcon
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for direct Firestore access
import 'package:sora_app/data/property_data.dart'; // Import the centralized property data
import 'package:sora_app/services/firestore_service.dart'; // NEW: Import the Firestore service
import 'package:sora_app/screens/airbnb_screen.dart'; // New Import

class HomeScreen extends StatefulWidget {
  final AuthService authService;

  const HomeScreen({super.key, required this.authService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CommonWidgets commonWidgets;
  late Future<List<Map<String, dynamic>>> _propertiesFuture;
  late FirestoreService _firestoreService;

  // Controllers for the carousels
  final ScrollController _popularScrollController = ScrollController();
  final ScrollController _dealsScrollController = ScrollController();
  final ScrollController _newScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    _firestoreService = FirestoreService();
    _propertiesFuture = _fetchAllProperties();
  }

  @override
  void dispose() {
    _popularScrollController.dispose();
    _dealsScrollController.dispose();
    _newScrollController.dispose();
    super.dispose();
  }

  // Method to fetch all properties from the 'properties' collection
  Future<List<Map<String, dynamic>>> _fetchAllProperties() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('properties').get();
      return querySnapshot.docs.map((doc) => {
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }).toList();
    } catch (e) {
      print('Error fetching properties: $e');
      return [];
    }
  }

  // A method to show the login/signup popup
  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log In to Save Favorites'),
          content: const Text('You must be logged in to save properties to your favorites.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushNamed(context, '/signup'); // Navigate to sign up
              },
              child: const Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushNamed(context, '/signin'); // Navigate to sign in
              },
              child: const Text('Sign In'),
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

    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with enhanced design and user experience
            _buildHeroSection(isLargeScreen, isMediumScreen),

            // Use FutureBuilder to handle the asynchronous data fetching
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _propertiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A66C2)),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  print('Error in FutureBuilder: ${snapshot.error}');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text('No properties found.'),
                    ),
                  );
                } else {
                  final properties = snapshot.data!;
                  // Segregate properties for carousels
                  final List<Map<String, dynamic>> staycationProperties =
                      properties.where((p) => p['listingType'] == 'Staycation').toList();
                  final List<Map<String, dynamic>> otherProperties =
                      properties.where((p) => p['listingType'] != 'Staycation').toList();

                  // Create the combined list of 10 properties for each carousel
                  List<Map<String, dynamic>> carouselProperties = [];
                  final int numStaycations = staycationProperties.length > 3 ? 3 : staycationProperties.length;
                  final int numOthers = 10 - numStaycations;
                  carouselProperties.addAll(staycationProperties.take(numStaycations));
                  carouselProperties.addAll(otherProperties.take(numOthers));

                  return Column(
                    children: [
                      // Popular Properties Section
                      _buildPropertiesCarousel(
                        context,
                        'Popular Properties',
                        carouselProperties,
                        _popularScrollController,
                        isLargeScreen,
                        isMediumScreen,
                      ),

                      // Hottest Deals Section
                      _buildPropertiesCarousel(
                        context,
                        'Hottest Deals',
                        carouselProperties,
                        _dealsScrollController,
                        isLargeScreen,
                        isMediumScreen,
                      ),

                      // New in Market Section
                      _buildPropertiesCarousel(
                        context,
                        'New in Market',
                        carouselProperties,
                        _newScrollController,
                        isLargeScreen,
                        isMediumScreen,
                      ),
                    ],
                  );
                }
              },
            ),

            // Call to Action Section
            _buildCallToActionSection(isLargeScreen, isMediumScreen),

            // Categories Section
            _buildCategoriesSection(isLargeScreen, isMediumScreen),

            // Testimonials Section
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
            FadingColorText(
              text: 'Find Your Dream Home',
              style: TextStyle(
                fontSize: isLargeScreen ? 60 : (isMediumScreen ? 45 : 30),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: isLargeScreen ? 10 : 5),
            GlidingBlueFlash(
              text: 'Explore thousands of properties for sale, rent, and lease.',
              style: TextStyle(
                fontSize: isLargeScreen ? 20 : (isMediumScreen ? 16 : 14),
                color: Colors.white,
              ),
            ),
            SizedBox(height: isLargeScreen ? 10 : 5),
            // New "Now Featuring:" typing animation
            TypingTextAnimation(
              text: 'Now Featuring:',
              style: TextStyle(
                fontSize: isLargeScreen ? 18 : (isMediumScreen ? 14 : 12),
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: isLargeScreen ? 20 : 10), // Increased top margin
            // Airbnb button with new rolling animation
            RollingButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AirbnbScreen(authService: widget.authService)),
                );
              },
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
        backgroundColor: const Color(0xFF1E90FF),
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
                    Navigator.pushNamed(context, '/buy');
                  }),
                  _buildCategoryCard(Icons.apartment, 'Rent Property', 'Discover perfect apartments and houses for rent.', () {
                    Navigator.pushNamed(context, '/rent');
                  }),
                  _buildCategoryCard(Icons.store, 'Commercial Lease', 'Browse commercial spaces for your business.', () {
                    Navigator.pushNamed(context, '/lease');
                  }),
                  _buildCategoryCard(Icons.agriculture, 'Land & Plots', 'Invest in land for future development.', () {
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: const Color(0xFF1E90FF)),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A66C2),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesCarousel(BuildContext context, String title, List<Map<String, dynamic>> properties, ScrollController scrollController, bool isLargeScreen, bool isMediumScreen) {
    if (properties.isEmpty) {
      return const SizedBox.shrink();
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
                  String listingType = '';
                  if (title == 'Popular Properties') {
                    listingType = 'Rent';
                  } else if (title == 'Hottest Deals') {
                    listingType = 'Buy';
                  } else if (title == 'New in Market') {
                    listingType = 'Lease';
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
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: isLargeScreen ? 380 : (isMediumScreen ? 320 : 280),
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: properties.map((property) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        // Use the new _PropertyCard widget
                        child: _PropertyCard(
                          property: property,
                          isLargeScreen: isLargeScreen,
                          isMediumScreen: isMediumScreen,
                          authService: widget.authService,
                          onAuthRequired: _showAuthDialog,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Left Carousel Button
              Positioned(
                left: 0,
                child: Opacity(
                  opacity: 0.7,
                  child: FloatingActionButton(
                    onPressed: () {
                      scrollController.animateTo(
                        scrollController.offset - (isLargeScreen ? 320 : (isMediumScreen ? 270 : 240)),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    mini: true,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.chevron_left, color: Color(0xFF0A66C2)),
                  ),
                ),
              ),
              // Right Carousel Button
              Positioned(
                right: 0,
                child: Opacity(
                  opacity: 0.7,
                  child: FloatingActionButton(
                    onPressed: () {
                      scrollController.animateTo(
                        scrollController.offset + (isLargeScreen ? 320 : (isMediumScreen ? 270 : 240)),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    mini: true,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.chevron_right, color: Color(0xFF0A66C2)),
                  ),
                ),
              ),
            ],
          ),
        ],
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
        'author': 'Grace Kwamboka',
        'location': 'Nairobi, Kenya',
      },
      {
        'quote': 'Selling our home through SORA was a breeze. The process was transparent, and we got a fantastic offer much faster than we expected. Thank you, SORA!',
        'author': 'David Mwangi',
        'location': 'Mombasa, Kenya',
      },
      {
        'quote': 'As a first-time homebuyer, I was overwhelmed. SORA\'s resources and patient team made the journey enjoyable and stress-free. I\'m so happy in my new home!',
        'author': 'Carol Ngetich',
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

// A new StatefulWidget for the individual property cards
class _PropertyCard extends StatefulWidget {
  final Map<String, dynamic> property;
  final bool isLargeScreen;
  final bool isMediumScreen;
  final AuthService authService;
  final VoidCallback onAuthRequired;

  const _PropertyCard({
    required this.property,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.authService,
    required this.onAuthRequired,
  });

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> {
  bool _isFavorite = false;
  late FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final user = widget.authService.getCurrentUser();
    if (user != null && widget.property['id'] != null) {
      final isFav = await _firestoreService.isFavorite(user.uid, widget.property['id']);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    }
  }

  // New method to show a confirmation dialog for removing a favorite
  void _showRemoveFavoriteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove from Favorites?'),
          content: const Text('Are you sure you want to remove this property from your favorites?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Do not remove
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Remove
              },
              child: const Text('Yes, Remove'),
            ),
          ],
        );
      },
    ).then((confirmed) async {
      if (confirmed != null && confirmed) {
        final user = widget.authService.getCurrentUser();
        final propertyId = widget.property['id']?.toString();
        if (user != null && propertyId != null) {
          await _firestoreService.removeFavorite(user.uid, propertyId);
          if (mounted) {
            setState(() {
              _isFavorite = false;
            });
          }
        }
      }
    });
  }

  void _toggleFavorite() async {
    final user = widget.authService.getCurrentUser();
    if (user == null) {
      widget.onAuthRequired();
      return;
    }

    final propertyId = widget.property['id']?.toString();
    if (propertyId == null) {
      print('Property ID is null, cannot save favorite.');
      return;
    }

    if (_isFavorite) {
      _showRemoveFavoriteDialog();
    } else {
      await _firestoreService.addFavorite(user.uid, propertyId);
      if (mounted) {
        setState(() {
          _isFavorite = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.property['coverImageUrl']?.toString() ?? 'https://via.placeholder.com/150';

    // Map the listingType from the database to the display text
    String listingTypeDisplay = 'Unknown';
    if (widget.property['listingType'] != null) {
      switch (widget.property['listingType']) {
        case 'For Sale':
          listingTypeDisplay = 'Buy';
          break;
        case 'For Lease':
          listingTypeDisplay = 'Lease';
          break;
        case 'For Rent':
          listingTypeDisplay = 'Rent';
          break;
        case 'Staycation':
          listingTypeDisplay = 'Staycation';
          break;
        default:
          listingTypeDisplay = 'Unknown';
      }
    }

    return GestureDetector(
      onTap: () {
        // Updated to use the named route '/view_property'
        Navigator.pushNamed(context, '/view_property', arguments: widget.property);
      },
      child: Container(
        width: widget.isLargeScreen ? 300 : (widget.isMediumScreen ? 250 : 220),
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    imageUrl,
                    height: widget.isLargeScreen ? 200 : (widget.isMediumScreen ? 160 : 140),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: widget.isLargeScreen ? 200 : (widget.isMediumScreen ? 160 : 140),
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KSh ${widget.property['price']?.toString() ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A66C2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.property['title']?.toString() ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (widget.property['location'] != null && widget.property['location']['town'] != null)
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.property['location']['town'].toString(),
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (widget.property['residentialDetails'] != null) ...[
                        if (widget.property['residentialDetails']['bedrooms'] != null)
                          Row(
                            children: [
                              Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                              const SizedBox(height: 4),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.property['residentialDetails']['bedrooms']} Beds',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        if (widget.property['residentialDetails']['bathrooms'] != null)
                          Row(
                            children: [
                              Icon(Icons.bathtub, size: 16, color: Colors.grey[600]),
                              const SizedBox(height: 4),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.property['residentialDetails']['bathrooms']} Baths',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                      ],
                      if (widget.property['area'] != null && widget.property['area'] != "0")
                        Row(
                          children: [
                            Icon(Icons.square_foot, size: 16, color: Colors.grey[600]),
                            const SizedBox(height: 4),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.property['area']} sqft',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                    ].whereType<Widget>().toList(),
                  ),
                ),
              ],
            ),
            // Listing type button - Moved to top left
            Positioned(
              top: 10,
              left: 10,
              child: ElevatedButton(
                onPressed: () {
                  // This button is for display, so onPressed is empty
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A66C2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size.zero, // Set this to wrap the content tightly
                ),
                child: Text(listingTypeDisplay),
              ),
            ),
            // Favorite button - New position on top right
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                  size: 30,
                ),
                onPressed: _toggleFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fixed: This widget now uses a ShaderMask to create the blue cloud passing effect.
class FadingColorText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const FadingColorText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<FadingColorText> createState() => _FadingColorTextState();
}

class _FadingColorTextState extends State<FadingColorText> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double gradientPosition = _animationController.value;
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [Colors.white, Colors.blue, Colors.white],
              stops: [
                gradientPosition - 0.1,
                gradientPosition,
                gradientPosition + 0.1,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: widget.style.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}


class GlidingBlueFlash extends StatefulWidget {
  final String text;
  final TextStyle style;

  const GlidingBlueFlash({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<GlidingBlueFlash> createState() => _GlidingBlueFlashState();
}

class _GlidingBlueFlashState extends State<GlidingBlueFlash> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Changed from 2 to 4 seconds
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double gradientPosition = _animationController.value;

        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Colors.white,
                Colors.blue,
                Colors.white,
              ],
              stops: [
                gradientPosition - 0.1,
                gradientPosition,
                gradientPosition + 0.1,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: widget.style.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}

class TypingTextAnimation extends StatefulWidget {
  final String text;
  final TextStyle style;
  const TypingTextAnimation({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<TypingTextAnimation> createState() => _TypingTextAnimationState();
}

class _TypingTextAnimationState extends State<TypingTextAnimation> {
  String _currentText = '';
  int _charIndex = 0;
  bool _isDeleting = false;
  bool _showCursor = true;
  int _colorIndex = 0;
  final List<Color> _colors = [Colors.blue, Colors.white];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      if (!_isDeleting) {
        // Typing animation
        if (_charIndex < widget.text.length) {
          _currentText = widget.text.substring(0, _charIndex + 1);
          _charIndex++;
          await Future.delayed(const Duration(milliseconds: 100)); // Typing speed
        } else {
          _isDeleting = true;
          // Blinking cursor
          for (int i = 0; i < 5; i++) {
            _showCursor = !_showCursor;
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      } else {
        // Deleting animation
        if (_charIndex > 0) {
          _currentText = widget.text.substring(0, _charIndex - 1);
          _charIndex--;
          await Future.delayed(const Duration(milliseconds: 100)); // Deleting speed
        } else {
          _isDeleting = false;
          _charIndex = 0; // Reset index for the next cycle
          _colorIndex = (_colorIndex + 1) % _colors.length; // Change color for the next cycle
          await Future.delayed(const Duration(milliseconds: 500)); // Pause before starting over
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentText + (_showCursor ? '|' : ''),
      style: widget.style.copyWith(
        color: _colors[_colorIndex],
      ),
    );
  }
}

// NEW: A custom button for the rolling, fading animation
class RollingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget? child;

  const RollingButton({
    super.key,
    required this.onPressed,
    this.child,
  });

  @override
  State<RollingButton> createState() => _RollingButtonState();
}

class _RollingButtonState extends State<RollingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fontWeightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _controller.forward(); // Run the animation once

    _fontWeightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.linear),
    ));
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
        final FontWeight animatedFontWeight = FontWeight.lerp(
          FontWeight.w200,
          FontWeight.w900,
          _fontWeightAnimation.value,
        )!;

        // Animate the gradient position
        final double gradientPosition = _controller.value;

        return TextButton(
          onPressed: widget.onPressed,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: const [Colors.white, Colors.blue, Colors.white],
                stops: [
                  gradientPosition - 0.1,
                  gradientPosition,
                  gradientPosition + 0.1,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            child: Text(
              'Airbnb',
              style: TextStyle(
                fontSize: 50,
                fontWeight: animatedFontWeight,
                color: Colors.white, // This ensures the base text is white
              ),
            ),
          ),
        );
      },
    );
  }
}