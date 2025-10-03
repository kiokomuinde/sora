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
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:intl/intl.dart'; // Import for number formatting
import 'package:sora_app/screens/blogs_screen.dart'; // Import for blogs_screen.dart

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
                        'popularCarousel',
                      ),

                      // Hottest Deals Section
                      _buildPropertiesCarousel(
                        context,
                        'Hottest Deals',
                        carouselProperties,
                        _dealsScrollController,
                        isLargeScreen,
                        isMediumScreen,
                        'dealsCarousel',
                      ),

                      // New in Market Section
                      _buildPropertiesCarousel(
                        context,
                        'New in Market',
                        carouselProperties,
                        _newScrollController,
                        isLargeScreen,
                        isMediumScreen,
                        'newCarousel',
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

            // Blog Posts Section (NOW DYNAMIC)
            _buildBlogSection(isLargeScreen, isMediumScreen),

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
            SizedBox(height: isLargeScreen ? 10 : 5), // New "Now Featuring:" typing animation
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
                Navigator.of(context).pushNamed(
                  '/property_listing',
                  arguments: {'listingType': 'Staycation'},
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

  Widget _buildPropertiesCarousel(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> properties,
    ScrollController scrollController,
    bool isLargeScreen,
    bool isMediumScreen,
    String carouselTag, // Add a new parameter for a unique tag
  ) {
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
                'Popular Properties',
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
                    heroTag: 'leftButton$carouselTag', // Unique heroTag
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
                    heroTag: 'rightButton$carouselTag', // Unique heroTag
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
      // Fix for the carousel spacing
    );
  }

  Widget _buildCallToActionSection(bool isLargeScreen, bool isMediumScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 80 : 40,
        horizontal: isLargeScreen ? 100 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.blue.withOpacity(0.8),
            Colors.purple.withOpacity(0.8)
          ],
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

  // NEW: Blog Posts Section with dynamic data
  Widget _buildBlogSection(bool isLargeScreen, bool isMediumScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 60 : 30,
        horizontal: isLargeScreen ? 100 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.5), // Start with a transparent white
            const Color(0xFF4169E1).withOpacity(0.2), // Light Royal Blue
            Colors.white.withOpacity(0.5), // End with a transparent white
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Read Our Latest Blogs',
                style: TextStyle(
                  fontSize: isLargeScreen ? 36 : (isMediumScreen ? 28 : 22),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A66C2),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/blogs');
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
          StreamBuilder<QuerySnapshot>(
            // Limit to 6 latest blog posts
            stream: FirebaseFirestore.instance.collection('blogs').orderBy('timestamp', descending: true).limit(6).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No blog posts available.'));
              }

              final blogs = snapshot.data!.docs.map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }).toList();

              return LayoutBuilder(builder: (context, constraints) {
                int crossAxisCount;
                if (isLargeScreen) {
                  crossAxisCount = 3;
                } else if (isMediumScreen) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 1;
                }
                // Adjusted aspect ratio to make cards smaller
                double childAspectRatio = isLargeScreen ? 0.9 : (isMediumScreen ? 0.8 : 0.95);

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: isLargeScreen ? 30 : 20,
                  crossAxisSpacing: isLargeScreen ? 30 : 20,
                  childAspectRatio: childAspectRatio,
                  children: blogs.map((blog) {
                    return _buildBlogCard(
                      blog: blog,
                      isLargeScreen: isLargeScreen,
                      isMediumScreen: isMediumScreen,
                    );
                  }).toList(),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  // Re-usable widget from blogs_screen.dart, adapted for local use
  Widget _buildBlogCard({
    required Map<String, dynamic> blog,
    required bool isLargeScreen,
    required bool isMediumScreen,
  }) {
    final String imageUrl = blog['imageUrls'] != null && blog['imageUrls'].isNotEmpty
        ? blog['imageUrls'][0]
        : '';
    Timestamp? timestamp = blog['timestamp'] as Timestamp?;
    String date = timestamp != null
        ? DateFormat('MMMM d, yyyy').format(timestamp.toDate())
        : 'Date Unavailable';
    String snippet = blog['snippet'] ?? '';

    // Calculate max lines for snippet based on screen size to prevent overflow
    int maxSnippetLines = isLargeScreen ? 5 : (isMediumScreen ? 4 : 3);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/blog_view',
          arguments: blog,
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                              child: Text(
                                  'Image not found',
                                  style: TextStyle(color: Colors.grey[600]),
                              ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'Image Unavailable',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog['category'] ?? 'Uncategorized',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E90FF),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      blog['title'] ?? 'Untitled Blog Post',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snippet,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: maxSnippetLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/blog_view',
                            arguments: blog,
                          );
                        },
                        child: const Text(
                          'Read More',
                          style: TextStyle(
                            color: Color(0xFF1E90FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
          LayoutBuilder(builder: (context, constraints) {
            int crossAxisCount;
            if (isLargeScreen) {
              crossAxisCount = 3;
            } else if (isMediumScreen) {
              crossAxisCount = 2;
            } else {
              crossAxisCount = 1;
            }
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: isLargeScreen ? 30 : 15,
              crossAxisSpacing: isLargeScreen ? 30 : 15,
              childAspectRatio: 1.5,
              children: testimonials.map((testimonial) {
                return _buildTestimonialCard(
                  quote: testimonial['quote']!,
                  author: testimonial['author']!,
                  location: testimonial['location']!,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard({
    required String quote,
    required String author,
    required String location,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.format_quote, size: 40, color: Color(0xFF0A66C2)),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                quote,
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              author,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              location,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

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
  late FirestoreService _firestoreService;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _isFavorite = false; // Initial state
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final isFav = await _firestoreService.isFavorite(user.uid, widget.property['id']);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      widget.onAuthRequired();
      return;
    }

    try {
      if (_isFavorite) {
        await _firestoreService.removeFavorite(user.uid, widget.property['id']);
      } else {
        await _firestoreService.addFavorite(user.uid, widget.property['id']);
      }
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    } catch (e) {
      print('Error toggling favorite status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely retrieve the image URL from the 'coverImageUrl' field
    String? imageUrl = widget.property['coverImageUrl']?.toString();
    
    final String listingType = widget.property['listingType'] ?? 'Unknown';
    
    // Safely retrieve common nested maps
    final Map<String, dynamic> residentialDetails = widget.property['residentialDetails'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> airbnbDetails = widget.property['airbnbDetails'] as Map<String, dynamic>? ?? {};

    // Variables for Card Display
    final int displayBeds;
    final int displayBaths;
    final int displaySize;
    int guestsCapacity = 0; // Capacity is only relevant for Staycation
    
    // Safely retrieve size from the root of the property map for all property types
    final int rootSize = int.tryParse((widget.property['size'] ?? '0').toString().replaceAll(',', '')) ?? 0;


    // --- START: Conditional Data Parsing for Property Card (FIXED) ---
    if (listingType == 'Staycation') {
      // Staycation: Get guests from airbnbDetails and baths from residentialDetails
      guestsCapacity = int.tryParse((airbnbDetails['guests'] ?? '0').toString().replaceAll(',', '')) ?? 0;
      
      // We don't display 'beds' or 'size' for Staycation, only Guests and Baths
      displayBeds = 0; 
      displaySize = 0; 
      // Use residentialDetails for bathrooms, as it is a common field for the physical property
      displayBaths = int.tryParse((residentialDetails['bathrooms'] ?? '0').toString().replaceAll(',', '')) ?? 0; 

    } else {
      // Residential (Buy, Rent, Lease): Use residentialDetails for beds and baths
      // THIS RESTORES THE ORIGINAL FIX for beds/bedrooms
      displayBeds = int.tryParse((residentialDetails['bedrooms'] ?? '0').toString().replaceAll(',', '')) ?? 0;
      displayBaths = int.tryParse((residentialDetails['bathrooms'] ?? '0').toString().replaceAll(',', '')) ?? 0;
      displaySize = rootSize; // Use the root size field
    }
    // --- END: Conditional Data Parsing for Property Card (FIXED) ---

    // Safely retrieve and parse the price from string to int
    final int price = int.tryParse((widget.property['price'] ?? '0').toString().replaceAll(',', '')) ?? 0;
    final formatter = NumberFormat('#,###', 'en_US');

    // Conditional text for the listing type button
    final String buttonText = listingType == 'Staycation' ? 'Airbnb' : listingType.toUpperCase();

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/view_property',
          arguments: widget.property, // Corrected: Passing the full property map
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: widget.isLargeScreen ? 300 : (widget.isMediumScreen ? 250 : 220),
          height: widget.isLargeScreen ? 380 : (widget.isMediumScreen ? 320 : 280),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      imageUrl ?? 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image, size: 50));
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: _isFavorite ? Colors.transparent : Colors.black54,
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A66C2).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.property['title'] ?? 'Property Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            widget.property['location']?['locality'] ?? 'Location',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // --- PROPERTY FEATURES ROW ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (listingType == 'Staycation') ...[
                          // Show Guests and Baths for Staycation
                          _buildPropertyFeature(Icons.people_alt_rounded, '$guestsCapacity Guests'),
                          _buildPropertyFeature(FontAwesomeIcons.toilet, '$displayBaths Baths'),
                        ] else ...[
                          // Show Beds, Baths, and Size for Residential
                          _buildPropertyFeature(Icons.bed_rounded, '$displayBeds Beds'),
                          _buildPropertyFeature(FontAwesomeIcons.toilet, '$displayBaths Baths'),
                          _buildPropertyFeature(Icons.square_foot, '$displaySize sqft'),
                        ],
                      ],
                    ),
                    // --- END PROPERTY FEATURES ROW ---
                    const SizedBox(height: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'KSH ${formatter.format(price)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // The color is masked by the gradient
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable method for building property features
Widget _buildPropertyFeature(IconData icon, String text) {
  return Expanded(
    child: Row(
      children: [
        FaIcon(icon, size: 16, color: const Color(0xFF0A66C2)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class FadingColorText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const FadingColorText({super.key, required this.text, required this.style});

  @override
  State<FadingColorText> createState() => _FadingColorTextState();
}

class _FadingColorTextState extends State<FadingColorText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: const Color(0xFF1E90FF),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Text(
          widget.text,
          style: widget.style.copyWith(color: _colorAnimation.value),
        );
      },
    );
  }
}

class GlidingBlueFlash extends StatefulWidget {
  final String text;
  final TextStyle style;

  const GlidingBlueFlash({super.key, required this.text, required this.style});

  @override
  State<GlidingBlueFlash> createState() => _GlidingBlueFlashState();
}

class _GlidingBlueFlashState extends State<GlidingBlueFlash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: false);
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [Colors.white, Color(0xFF1E90FF), Colors.white],
              stops: [_animation.value - 0.1, _animation.value, _animation.value + 0.1],
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white), // Use white as base color
          ),
        );
      },
    );
  }
}

class TypingTextAnimation extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const TypingTextAnimation({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<TypingTextAnimation> createState() => _TypingTextAnimationState();
}

class _TypingTextAnimationState extends State<TypingTextAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _textAnimation = IntTween(begin: 0, end: widget.text.length).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        String animatedText = widget.text.substring(0, _textAnimation.value);
        return Text(
          animatedText,
          style: widget.style,
          overflow: TextOverflow.visible,
          softWrap: false,
        );
      },
    );
  }
}

class RollingButton extends StatefulWidget {
  final VoidCallback onPressed;

  const RollingButton({super.key, required this.onPressed});

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
    )..repeat();
    _fontWeightAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.linear),
    );
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