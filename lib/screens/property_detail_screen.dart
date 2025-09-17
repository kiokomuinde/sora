// /lib/screens/property_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For PointerDeviceKind
import 'package:url_launcher/url_launcher.dart'; // For launching calls, emails, etc.
import 'package:share_plus/share_plus.dart'; // For sharing functionality
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For social icons like WhatsApp

class PropertyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  const PropertyDetailScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isFavorite = false;
  int _currentPage = 0; // Track current page of the carousel
  late PageController _pageController;
  bool _showSwipeInstruction = true;
  late ScrollController _similarPropertiesScrollController;

  // Image captions for the carousel
  final List<String> _imageCaptions = const [
    "Elegant exterior design with lush landscaping",
    "Spacious living area, perfect for entertaining guests",
    "Gourmet kitchen with state_of_the_art appliances",
    "Luxurious master suite offering serene comfort",
    "Private backyard oasis with swimming pool",
    "Cozy guest bedroom with ample natural light",
    "Dedicated home office with built-in shelving",
    "Modern bathroom with walk-in shower and soaking tub",
    "Panoramic city views from the rooftop terrace",
    "Inviting dining area for family meals",
  ];

  // Icons for property feature items
  final Map<String, IconData> _featureIcons = {
    'Year Built': Icons.calendar_today,
    'Parking': Icons.local_parking,
    'Heating': Icons.thermostat,
    'Cooling': Icons.ac_unit,
    'Flooring': Icons.texture,
    'Lot Size': Icons.aspect_ratio,
    'Property Type': Icons.home_work,
    'Pets Allowed': Icons.pets,
  };

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.property['isFavorite'] ?? false;
    _pageController = PageController(initialPage: _currentPage);
    _similarPropertiesScrollController = ScrollController();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSwipeInstruction = false;
        });
      }
    });

    _similarPropertiesScrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _similarPropertiesScrollController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Added to favorites!' : 'Removed from favorites.'),
          duration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  void _shareProperty() {
    final String propertyTitle = widget.property['title'] ?? 'Property Details';
    final String propertyId = widget.property['id']?.toString() ?? '123';
    final String propertyUrl = "https://example.com/properties/detail?id=$propertyId";
    Share.share('Check out this amazing property: $propertyTitle\n$propertyUrl');
  }

  // Helper: Build image widget (network or asset)
  Widget _buildImage(String imagePath) {
    final bool isNetwork = imagePath.startsWith('http');
    return isNetwork
        ? Image.network(
            imagePath,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
          );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.broken_image, color: Colors.grey[400], size: 40),
      ),
    );
  }

  // Helper: Build thumbnail image
  Widget _buildThumbnailImage(String imagePath) {
    final bool isNetwork = imagePath.startsWith('http');
    return isNetwork
        ? Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildErrorThumbnail(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              );
            },
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildErrorThumbnail(),
          );
  }

  // Error widget for thumbnails
  Widget _buildErrorThumbnail() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 16),
    );
  }

  void _goToPage(int index) {
    setState(() {
      _currentPage = index;
      _showSwipeInstruction = false;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleContactAction(String action, String value, String agentName) async {
    String uriString = '';
    switch (action) {
      case 'Call':
        uriString = 'tel:$value';
        break;
      case 'WhatsApp':
        final formattedValue = value.replaceAll(RegExp(r'[^\d]'), '');
        uriString = 'https://wa.me/$formattedValue';
        break;
      case 'Email':
        uriString = 'mailto:$value?subject=Inquiry about property ${widget.property['title']}';
        break;
      case 'SMS':
        uriString = 'sms:$value';
        break;
      default:
        return;
    }

    final Uri uri = Uri.parse(uriString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $action for $agentName.'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error launching $action: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final bool isLargeScreen = MediaQuery.of(context).size.width > 768;
    final double carouselHeight = MediaQuery.of(context).size.height * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: Text(property['title'] ?? 'Property Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : null,
            ),
            onPressed: _toggleFavorite,
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProperty,
            tooltip: 'Share property',
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        physics: const ClampingScrollPhysics(),
        children: [
          _buildImageCarousel(property, carouselHeight, isLargeScreen),
          const SizedBox(height: 16),
          _buildPropertyOverview(property),
          const SizedBox(height: 20),
          _buildDescriptionSection(property),
          const SizedBox(height: 20),
          _buildPropertyFeaturesSection(property, isLargeScreen),
          const SizedBox(height: 20),
          _buildAmenitiesSection(isLargeScreen),
          const SizedBox(height: 24),
          _buildContactAgentsSection(context, isLargeScreen),
          const SizedBox(height: 30),
          _buildSimilarPropertiesSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // === IMAGE CAROUSEL SECTION ===
  Widget _buildImageCarousel(Map<String, dynamic> property, double carouselHeight, bool isLargeScreen) {
    final List<dynamic> images = property['images'] ?? [];
    return SizedBox(
      height: carouselHeight,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 1024 : double.infinity,
          ),
          child: Stack(
            children: [
              ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                      _showSwipeInstruction = false;
                    });
                  },
                  itemBuilder: (context, index) {
                    String imagePath = images[index] ?? 'assets/placeholders/image_error.png';
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 24.0 : 8.0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildImage(imagePath),
                            _buildImageCaptionOverlay(index, images.length),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_showSwipeInstruction) _buildSwipeInstructionOverlay(),
              _buildThumbnailNavigationButtons(images),
              // Left navigation button
              Positioned(
                left: isLargeScreen ? 32 : 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: FloatingActionButton(
                    heroTag: 'leftBtn',
                    mini: true,
                    elevation: 4,
                    backgroundColor: Theme.of(context).cardColor,
                    onPressed: _currentPage > 0
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: _currentPage > 0 ? Theme.of(context).primaryColor : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Right navigation button
              Positioned(
                right: isLargeScreen ? 32 : 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: FloatingActionButton(
                    heroTag: 'rightBtn',
                    mini: true,
                    elevation: 4,
                    backgroundColor: Theme.of(context).cardColor,
                    onPressed: _currentPage < images.length - 1
                        ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: _currentPage < images.length - 1 ? Theme.of(context).primaryColor : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
              _buildCarouselPageIndicators(images.length),
            ],
          ),
        ),
      ),
    );
  }

  // Carousel page indicators
  Widget _buildCarouselPageIndicators(int itemCount) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(itemCount, (index) {
          return GestureDetector(
            onTap: () => _goToPage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 8.0,
              width: _currentPage == index ? 24.0 : 8.0,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Caption overlay on each image
  Widget _buildImageCaptionOverlay(int index, int totalImages) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              index < _imageCaptions.length ? _imageCaptions[index] : "Property image ${index + 1}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Image ${index + 1} of $totalImages",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Swipe instruction overlay
  Widget _buildSwipeInstructionOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swipe, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  "Swipe to view more images",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Thumbnail navigation buttons below the carousel
  Widget _buildThumbnailNavigationButtons(List<dynamic> images) {
    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Container(
        height: 60,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => GestureDetector(
                onTap: () => _goToPage(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white,
                      width: _currentPage == index ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildThumbnailImage(images[index]),
                        if (_currentPage != index)
                          Container(
                            color: Colors.black.withOpacity(0.4),
                          ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Property Overview Section
  Widget _buildPropertyOverview(Map<String, dynamic> property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property['price'] ?? 'Price N/A',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  property['location'] ?? 'Location N/A',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip(Icons.bed, "${property['bedrooms'] ?? 'N/A'} Beds"),
              _buildInfoChip(Icons.bathtub, "${property['bathrooms'] ?? 'N/A'} Baths"),
              _buildInfoChip(Icons.square_foot, "${property['area'] ?? 'N/A'} sqft"),
              _buildInfoChip(Icons.home_work, property['type'] ?? 'Property'),
            ],
          ),
        ],
      ),
    );
  }

  // Description Section
  Widget _buildDescriptionSection(Map<String, dynamic> property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            property['description'] ?? 'No description available for this property.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: Colors.black87),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // Property Features Section
  Widget _buildPropertyFeaturesSection(Map<String, dynamic> property, bool isLargeScreen) {
    final Map<String, String> features = {
      'Year Built': property['yearBuilt']?.toString() ?? 'N/A',
      'Parking': property['parking'] ?? 'Available',
      'Heating': property['heating'] ?? 'Central',
      'Cooling': property['cooling'] ?? 'Central A/C',
      'Flooring': property['flooring'] ?? 'Hardwood',
      'Lot Size': property['lotSize'] ?? 'N/A',
      'Property Type': property['propertyType'] ?? 'House',
      'Pets Allowed': property['petsAllowed']?.toString() == 'true' ? 'Yes' : 'No',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Property Features",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLargeScreen ? 3 : 2,
              childAspectRatio: isLargeScreen ? 3.5 : 4.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final entry = features.entries.elementAt(index);
              final icon = _featureIcons[entry.key] ?? Icons.info_outline;
              return _buildFeatureCard(icon, entry.key, entry.value);
            },
          ),
        ],
      ),
    );
  }

  // Feature card
  Widget _buildFeatureCard(IconData icon, String title, String value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Amenities Section
  Widget _buildAmenitiesSection(bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nearby Amenities",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _buildAmenityList(isLargeScreen),
          ),
        ],
      ),
    );
  }

  // Amenity list
  List<Widget> _buildAmenityList(bool isLargeScreen) {
    final List<Map<String, dynamic>> amenities = const [
      {"icon": Icons.school, "title": "School", "subtitle": "2 km away"},
      {"icon": Icons.church, "title": "Church", "subtitle": "1.5 km away"},
      {"icon": Icons.shopping_cart, "title": "Supermarket", "subtitle": "500 m away"},
      {"icon": Icons.local_hospital, "title": "Hospital", "subtitle": "3 km away"},
      {"icon": Icons.park, "title": "Park", "subtitle": "1 km away"},
      {"icon": Icons.restaurant, "title": "Restaurant", "subtitle": "800 m away"},
      {"icon": Icons.directions_bus, "title": "Bus Stop", "subtitle": "100 m away"},
      {"icon": Icons.train, "title": "Train Station", "subtitle": "4 km away"},
    ];
    return amenities.map((amenity) => _buildAmenityCard(
          amenity["icon"] as IconData,
          amenity["title"] as String,
          amenity["subtitle"] as String,
          isLargeScreen,
        )).toList();
  }

  // Amenity card
  Widget _buildAmenityCard(IconData icon, String title, String subtitle, bool isLargeScreen) {
    double cardWidth = isLargeScreen ? 170.0 : 150.0;
    return SizedBox(
      width: cardWidth,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  // Contact Agents Section
  Widget _buildContactAgentsSection(BuildContext context, bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Agents",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildAgentCard(
                      name: "Eric Ntingai",
                      title: "Senior Real Estate Agent",
                      rating: "4.9",
                      reviews: "120",
                      avatarAsset: 'assets/avatars/agent1.jpg',
                      onCallPressed: () => _handleContactAction('Call', '+1234567890', 'Eric Ntingai'),
                      onWhatsAppPressed: () => _handleContactAction('WhatsApp', '+1234567890', 'Eric Ntingai'),
                      onEmailPressed: () => _handleContactAction('Email', 'eric.ntingai@example.com', 'Eric Ntingai'),
                      onMessagePressed: () => _handleContactAction('SMS', '+1234567890', 'Eric Ntingai'),
                    ),
                    _buildAgentCard(
                      name: "Kioko Muinde",
                      title: "Senior Real Estate Agent",
                      rating: "4.8",
                      reviews: "98",
                      avatarAsset: 'assets/avatars/agent2.jpg',
                      onCallPressed: () => _handleContactAction('Call', '+1987654321', 'Kioko Muinde'),
                      onWhatsAppPressed: () => _handleContactAction('WhatsApp', '+1987654321', 'Kioko Muinde'),
                      onEmailPressed: () => _handleContactAction('Email', 'kioko.muinde@example.com', 'Kioko Muinde'),
                      onMessagePressed: () => _handleContactAction('SMS', '+1987654321', 'Kioko Muinde'),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildAgentCard(
                      name: "Eric Ntingai",
                      title: "Senior Real Estate Agent",
                      rating: "4.9",
                      reviews: "120",
                      avatarAsset: 'assets/avatars/agent1.jpg',
                      onCallPressed: () => _handleContactAction('Call', '+254702778897', 'Eric Ntingai'),
                      onWhatsAppPressed: () => _handleContactAction('WhatsApp', '+254702778897', 'Eric Ntingai'),
                      onEmailPressed: () => _handleContactAction('Email', 'soraproperties001@gmail.com', 'Eric Ntingai'),
                      onMessagePressed: () => _handleContactAction('SMS', '+254702778897', 'Eric Ntingai'),
                    ),
                    const SizedBox(height: 16),
                    _buildAgentCard(
                      name: "Kioko Muinde",
                      title: "Senior Real Estate Agent",
                      rating: "4.8",
                      reviews: "98",
                      avatarAsset: 'assets/avatars/agent2.jpg',
                      onCallPressed: () => _handleContactAction('Call', '+254712529637', 'Kioko Muinde'),
                      onWhatsAppPressed: () => _handleContactAction('WhatsApp', '+254712529637', 'Kioko Muinde'),
                      onEmailPressed: () => _handleContactAction('Email', 'kiokomuinde022@gmail.com', 'Kioko Muinde'),
                      onMessagePressed: () => _handleContactAction('SMS', '+254712529637', 'Kioko Muinde'),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Agent card
  Widget _buildAgentCard({
    required String name,
    required String title,
    required String rating,
    required String reviews,
    String? avatarAsset,
    required VoidCallback onCallPressed,
    required VoidCallback onWhatsAppPressed,
    required VoidCallback onEmailPressed,
    required VoidCallback onMessagePressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: avatarAsset != null ? AssetImage(avatarAsset) : null,
                  child: avatarAsset == null
                      ? Icon(Icons.person, size: 36, color: Theme.of(context).primaryColor)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            "$rating ($reviews reviews)",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildContactIconButton(icon: Icons.phone, color: Colors.green, onPressed: onCallPressed, tooltip: 'Call'),
                _buildContactIconButton(icon: FontAwesomeIcons.whatsapp, color: const Color(0xFF25D366), onPressed: onWhatsAppPressed, tooltip: 'WhatsApp'),
                _buildContactIconButton(icon: Icons.email, color: Colors.red, onPressed: onEmailPressed, tooltip: 'Email'),
                _buildContactIconButton(icon: Icons.message, color: Theme.of(context).primaryColor, onPressed: onMessagePressed, tooltip: 'Message'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Contact icon button
  Widget _buildContactIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  // Info chip
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
          ),
        ],
      ),
    );
  }

  // Similar Properties Section
  Widget _buildSimilarPropertiesSection() {
    final List<Map<String, dynamic>> similarProperties = [
      {
        'id': 'sim_1',
        'title': 'Spacious Family Home',
        'price': '\$480,000',
        'location': 'Springfield, IL',
        'images': ['https://picsum.photos/seed/1/200/300'],
        'bedrooms': 4,
        'bathrooms': 2,
        'area': '2200',
      },
      {
        'id': 'sim_2',
        'title': 'Cozy Apartment Downtown',
        'price': '\$250,000',
        'location': 'Metropolis, NY',
        'images': ['https://picsum.photos/seed/2/200/300'],
        'bedrooms': 2,
        'bathrooms': 1,
        'area': '1000',
      },
    ];

    bool canScrollLeft =
        _similarPropertiesScrollController.hasClients && _similarPropertiesScrollController.position.pixels > 0;
    bool canScrollRight = _similarPropertiesScrollController.hasClients &&
        _similarPropertiesScrollController.position.pixels <
            _similarPropertiesScrollController.position.maxScrollExtent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Similar Properties",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                ListView.builder(
                  controller: _similarPropertiesScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: similarProperties.length,
                  itemBuilder: (context, index) {
                    final property = similarProperties[index];
                    return _buildSimilarPropertyCard(property);
                  },
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: FloatingActionButton(
                      heroTag: 'similarLeftBtn',
                      mini: true,
                      backgroundColor: Colors.white.withOpacity(0.8),
                      onPressed: canScrollLeft
                          ? () {
                              _similarPropertiesScrollController.animateTo(
                                _similarPropertiesScrollController.position.pixels - 200,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          : null,
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: canScrollLeft ? Theme.of(context).primaryColor : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: FloatingActionButton(
                      heroTag: 'similarRightBtn',
                      mini: true,
                      backgroundColor: Colors.white.withOpacity(0.8),
                      onPressed: canScrollRight
                          ? () {
                              _similarPropertiesScrollController.animateTo(
                                _similarPropertiesScrollController.position.pixels + 200,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          : null,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: canScrollRight ? Theme.of(context).primaryColor : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Similar property card
  Widget _buildSimilarPropertyCard(Map<String, dynamic> property) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Viewing similar property: ${property['title']}')),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildImage(property['images']?.first),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property['price'] ?? 'Price N/A',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property['title'] ?? 'Property',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property['location'] ?? 'Location N/A',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

// Custom scroll behavior
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

extension GradientBox on Gradient {
  BoxDecoration toBoxDecoration({BorderRadius? radius}) {
    return BoxDecoration(gradient: this, borderRadius: radius);
  }
}