// lib/screens/view_property_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Updated mock data to include more details for filtering similar properties
final List<Map<String, dynamic>> _mockPropertiesData = [
  {
    'id': '1',
    'title': 'Luxury Apartment in Kilimani',
    'coverImageUrl': 'https://firebasestorage.googleapis.com/v0/b/sora-1c448.appspot.com/o/images%2Fproperty1.jpg?alt=media&token=c1a3b1a3-b1a3-b1a3-b1a3-b1a3b1a3b1a3',
    'location': {'town': 'Kilimani'},
    'propertyType': 'Apartment',
    'residentialDetails': {'bedrooms': 3, 'bathrooms': 3},
    'price': 25000000,
    'listingType': 'Buy',
    'description': 'A stunning 3-bedroom apartment located in a prime area of Kilimani.',
    'amenities': ['Swimming Pool', 'Gym', '24/7 Security'],
    'features': ['Balcony', 'En-suite bedrooms'],
  },
  {
    'id': '2',
    'title': 'Modern Townhouse in Lavington',
    'coverImageUrl': 'https://firebasestorage.googleapis.com/v0/b/sora-1c448.appspot.com/o/images%2Fproperty2.jpg?alt=media&token=c1a3b1a3-b1a3-b1a3-b1a3-b1a3b1a3b1a3',
    'location': {'town': 'Lavington'},
    'propertyType': 'Townhouse',
    'residentialDetails': {'bedrooms': 4, 'bathrooms': 4},
    'price': 180000,
    'listingType': 'Rent',
    'description': 'A spacious 4-bedroom townhouse in a gated community in Lavington.',
    'amenities': ['Gated Community', 'Playground', 'Parking'],
    'features': ['Garden', 'Modern kitchen'],
  },
  {
    'id': '3',
    'title': 'Spacious Family Villa in Karen',
    'coverImageUrl': 'https://firebasestorage.googleapis.com/v0/b/sora-1c448.appspot.com/o/images%2Fproperty3.jpg?alt=media&token=c1a3b1a3-b1a3-b1a3-b1a3-b1a3b1a3b1a3',
    'location': {'town': 'Karen'},
    'propertyType': 'Villa',
    'residentialDetails': {'bedrooms': 5, 'bathrooms': 5},
    'price': 45000000,
    'listingType': 'Buy',
    'description': 'An elegant 5-bedroom villa with a private garden in Karen.',
    'amenities': ['Private Garden', 'Swimming Pool', '24/7 Security'],
    'features': ['Study room', 'Spacious living area'],
  },
  {
    'id': '4',
    'title': 'Cozy Bungalow in Westlands',
    'coverImageUrl': 'https://firebasestorage.googleapis.com/v0/b/sora-1c448.appspot.com/o/images%2Fproperty4.jpg?alt=media&token=c1a3b1a3-b1a3-b1a3-b1a3-b1a3b1a3b1a3',
    'location': {'town': 'Westlands'},
    'propertyType': 'Bungalow',
    'residentialDetails': {'bedrooms': 2, 'bathrooms': 2},
    'price': 95000,
    'listingType': 'Rent',
    'description': 'A charming 2-bedroom bungalow ideal for a small family in Westlands.',
    'amenities': ['Parking', 'Quiet neighborhood'],
    'features': ['Fireplace', 'Lawn'],
  },
  {
    'id': '5',
    'title': 'Studio Apartment in Westlands',
    'coverImageUrl': 'https://firebasestorage.googleapis.com/v0/b/sora-1c448.appspot.com/o/images%2Fproperty5.jpg?alt=media&token=c1a3b1a3-b1a3-b1a3-b1a3-b1a3b1a3b1a3',
    'location': {'town': 'Westlands'},
    'propertyType': 'Apartment',
    'residentialDetails': {'bedrooms': 0, 'bathrooms': 1},
    'price': 60000,
    'listingType': 'Rent',
    'description': 'A modern studio apartment perfect for a young professional in Westlands.',
    'amenities': ['Elevator', 'Gym', '24/7 Security'],
    'features': ['Open plan kitchen'],
  },
  {
    'id': '6',
    'title': 'Family Townhouse in Lavington',
    'coverImageUrl': 'https://firebasestorage.googleapis.com/v0/b/sora-1c448.appspot.com/o/images%2Fproperty6.jpg?alt=media&token=c1a3b1a3-b1a3-b1a3-b1a3-b1a3b1a3b1a3',
    'location': {'town': 'Lavington'},
    'propertyType': 'Townhouse',
    'residentialDetails': {'bedrooms': 3, 'bathrooms': 3},
    'price': 150000,
    'listingType': 'Rent',
    'description': 'A lovely 3-bedroom townhouse with a small yard, located in Lavington.',
    'amenities': ['Gated Community', 'Playground', 'Parking'],
    'features': ['Small yard', 'Modern fittings'],
  },
];

class ViewPropertyScreen extends StatefulWidget {
  final Map<String, dynamic> propertyData;
  final AuthService authService;

  const ViewPropertyScreen({
    Key? key,
    required this.propertyData,
    required this.authService,
  }) : super(key: key);

  @override
  State<ViewPropertyScreen> createState() => _ViewPropertyScreenState();
}

class _ViewPropertyScreenState extends State<ViewPropertyScreen> {
  late CommonWidgets commonWidgets;
  final PageController _pageController = PageController();
  // New: A variable to track the current page for button visibility
  int _currentPage = 0;

  // A helper method to format the price
  String _formatPrice(dynamic price) {
    if (price == null) return 'Price not listed';

    if (price is String) {
      final doublePrice = double.tryParse(price);
      if (doublePrice != null) {
        final formatter = NumberFormat('#,###', 'en_US');
        return 'KSH ${formatter.format(doublePrice)}';
      }
      return 'KSH $price';
    }

    if (price is num) {
      final formatter = NumberFormat('#,###', 'en_US');
      return 'KSH ${formatter.format(price)}';
    }
    return 'KSH ${price.toString()}';
  }

  // Updated mock function to fetch similar properties based on criteria
  Future<List<Map<String, dynamic>>> _fetchSimilarProperties(Map<String, dynamic> currentProperty) async {
    await Future.delayed(const Duration(seconds: 1));

    final currentPropertyId = currentProperty['id'];
    final currentPropertyLocation = currentProperty['location']?['town'];
    final currentPropertyType = currentProperty['propertyType'];
    
    // Tier 1: Strict match - same location and property type
    List<Map<String, dynamic>> similarProperties = _mockPropertiesData.where((property) {
      // Exclude the current property from the similar list
      if (property['id'] == currentPropertyId) {
        return false;
      }
      return property['location']?['town'] == currentPropertyLocation &&
             property['propertyType'] == currentPropertyType;
    }).toList();

    // Tier 2: Less strict - same location and similar rooms/guests
    if (similarProperties.isEmpty) {
      similarProperties = _mockPropertiesData.where((property) {
        if (property['id'] == currentPropertyId) {
          return false;
        }

        bool hasSimilarDetails = false;
        if (currentPropertyType == 'Residential' && property['propertyType'] == 'Residential') {
          final currentBedrooms = currentProperty['residentialDetails']?['bedrooms'];
          final currentBathrooms = currentProperty['residentialDetails']?['bathrooms'];
          final propertyBedrooms = property['residentialDetails']?['bedrooms'];
          final propertyBathrooms = property['residentialDetails']?['bathrooms'];
          
          if (currentBedrooms != null && currentBathrooms != null && propertyBedrooms != null && propertyBathrooms != null) {
            hasSimilarDetails = (propertyBedrooms - currentBedrooms).abs() <= 1 &&
                               (propertyBathrooms - currentBathrooms).abs() <= 1;
          }
        } else if (currentPropertyType == 'Vocational' && property['propertyType'] == 'Vocational') {
          final currentGuests = int.tryParse(currentProperty['airbnbDetails']?['guests'] ?? '0');
          final propertyGuests = int.tryParse(property['airbnbDetails']?['guests'] ?? '0');
          if (currentGuests != null && propertyGuests != null) {
            hasSimilarDetails = (propertyGuests - currentGuests).abs() <= 2; // Allow for a wider guest count range
          }
        }
        
        return property['location']?['town'] == currentPropertyLocation && hasSimilarDetails;
      }).toList();
    }

    // Tier 3: Broaden search - same property type, any location
    if (similarProperties.isEmpty) {
      similarProperties = _mockPropertiesData.where((property) {
        if (property['id'] == currentPropertyId) {
          return false;
        }
        return property['propertyType'] == currentPropertyType;
      }).toList();
    }
    
    // Tier 4: Last resort - just show other properties
    if (similarProperties.isEmpty) {
      similarProperties = _mockPropertiesData.where((property) {
        return property['id'] != currentPropertyId;
      }).take(3).toList(); // Show up to 3 other properties
    }
    
    return similarProperties;
  }

  // New method to show contact information to a logged-in user
  void _showContactDialog(Map<String, dynamic> contactInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Contact Agent',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact Person: ${contactInfo['contactPerson'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Phone: ${contactInfo['phone'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Email: ${contactInfo['email'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    // New: Add a listener to the page controller to track the current page
    _pageController.addListener(() {
      int next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    final property = widget.propertyData;
    final propertyType = property['propertyType'];
    final Map<String, dynamic> details = propertyType == 'Residential'
        ? property['residentialDetails'] ?? {}
        : propertyType == 'Vocational'
            ? property['airbnbDetails'] ?? {}
            : {};

    final contactInfo = property['contactInfo'] ?? {};

    // Combine cover image with additional images for the carousel
    final List<String> imageUrls = [
      if (property['coverImageUrl'] != null) property['coverImageUrl'],
      ...(property['additionalImageUrls']?.cast<String>() ?? []),
    ];

    // Define the list of property details dynamically based on property type
    final List<Map<String, dynamic>> propertyDetails = [
      {'icon': Icons.home_work, 'label': 'Property Type', 'value': property['propertyType'] ?? 'N/A'},
      {'icon': Icons.format_size, 'label': 'Size', 'value': '${property['size'] ?? 'N/A'} ${property['sizeUnit'] ?? ''}'},
      if (propertyType == 'Residential') ...[
        {'icon': Icons.king_bed, 'label': 'Bedrooms', 'value': details['bedrooms']?.toString() ?? 'N/A'},
        {'icon': Icons.bathtub, 'label': 'Bathrooms', 'value': details['bathrooms']?.toString() ?? 'N/A'},
      ],
      if (propertyType == 'Vocational') ...[
        {'icon': Icons.people, 'label': 'Guests', 'value': details['guests']?.toString() ?? 'N/A'},
      ],
      {'icon': Icons.date_range, 'label': 'Year Built', 'value': property['yearBuilt'] ?? 'N/A'},
      {'icon': Icons.location_on, 'label': 'Location', 'value': property['location']?['town'] ?? 'N/A'},
    ];


    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Responsive content container to control width on large screens
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                vertical: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Image Carousel and Highlights
                  if (isLargeScreen)
                    _buildDesktopLayout(property, imageUrls, details)
                  else
                    _buildMobileLayout(property, imageUrls, details),
                  
                  const SizedBox(height: 40),

                  // Section 2: Description
                  _buildSectionCard(
                    title: 'Description',
                    child: Text(
                      property['description'] ?? 'No description provided.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Section 3: Property Details
                  _buildSectionCard(
                    title: 'Property Details',
                    // Changed from GridView.count to GridView.builder for better responsiveness
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: propertyDetails.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300.0, // Adjusts number of columns based on screen width
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        // Adjusted childAspectRatio to give the cards more vertical room and prevent overflow.
                        childAspectRatio: 2.2,
                      ),
                      itemBuilder: (context, index) {
                        final detail = propertyDetails[index];
                        return _buildDetailCard(detail['icon'], detail['label'], detail['value']);
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Section 4: Amenities and Features
                  if (property['amenities'] != null && property['amenities'].isNotEmpty) ...[
                    _buildSectionCard(
                      title: 'Amenities Nearby',
                      child: _buildTags(property['amenities']),
                    ),
                    const SizedBox(height: 40),
                  ],
                  if (property['features'] != null && property['features'].isNotEmpty) ...[
                    _buildSectionCard(
                      title: 'Features',
                      child: _buildTags(property['features']),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // Section 5: Contact Information
                  _buildSectionCard(
                    title: 'Contact Information',
                    // Check if the user is logged in to show full or blurred info
                    child: widget.authService.getCurrentUser() != null
                        ? _buildContactInfo(contactInfo)
                        : _buildBlurredContactInfo(contactInfo),
                  ),
                  const SizedBox(height: 40),

                  // Section 6: Similar Properties
                  _buildSectionCard(
                    title: 'Similar Properties',
                    child: _buildSimilarPropertiesList(),
                  ),
                ],
              ),
            ),
            // --- Footer ---
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> property, List<String> imageUrls, Map<String, dynamic> details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image carousel on the left
        Expanded(
          flex: 2,
          child: _buildImageCarousel(imageUrls),
        ),
        const SizedBox(width: 40),
        // Details on the right
        Expanded(
          flex: 1,
          child: _buildPropertyHighlights(property, details),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> property, List<String> imageUrls, Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageCarousel(imageUrls),
        const SizedBox(height: 30),
        _buildPropertyHighlights(property, details),
      ],
    );
  }

  // Widget to build a section with a card
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  // Widget to build the image carousel with navigation buttons
  Widget _buildImageCarousel(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('No images available.')),
      );
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width >= 1000 ? 500 : 300,
            child: PageView.builder(
              controller: _pageController,
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey)),
                );
              },
            ),
          ),
          // New: Previous button
          Positioned(
            left: 10,
            child: Visibility(
              visible: _currentPage > 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 30),
                color: const Color(0xFF0A66C2),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.7),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
          // New: Next button
          Positioned(
            right: 10,
            child: Visibility(
              visible: _currentPage < imageUrls.length - 1,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 30),
                color: const Color(0xFF0A66C2),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.7),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build the property highlights section
  Widget _buildPropertyHighlights(Map<String, dynamic> property, Map<String, dynamic> details) {
    final contactInfo = property['contactInfo'] ?? {};
    final propertyType = property['propertyType'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property['title'] ?? 'No Title',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width >= 1000 ? 40 : 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0A66C2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatPrice(property['price']),
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width >= 1000 ? 30 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 20),
        _buildDetailRow(Icons.pin_drop, 'Location', property['location']?['town'] ?? 'N/A'),
        const SizedBox(height: 10),
        _buildDetailRow(Icons.apartment, 'Type', property['propertyType'] ?? 'N/A'),
        if (propertyType == 'Residential') ...[
          const SizedBox(height: 10),
          _buildDetailRow(Icons.bed, 'Bedrooms', details['bedrooms']?.toString() ?? 'N/A'),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.bathtub, 'Bathrooms', details['bathrooms']?.toString() ?? 'N/A'),
        ] else if (propertyType == 'Vocational') ...[
          const SizedBox(height: 10),
          _buildDetailRow(Icons.people, 'Guests', details['guests']?.toString() ?? 'N/A'),
        ],
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              // Check if the user is logged in
              if (widget.authService.getCurrentUser() != null) {
                // If logged in, show contact information
                _showContactDialog(contactInfo);
              } else {
                // If not logged in, prompt to log in/sign up
                commonWidgets.showLoginSignupDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF0A66C2),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 5,
            ),
            icon: const Icon(Icons.call),
            label: const Text('Contact Agent', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0A66C2), size: 20),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Widget to build a professional-looking detail card
  Widget _buildDetailCard(IconData icon, String label, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF0A66C2)),
            const SizedBox(height: 8),
            Expanded( // Use Expanded to prevent text overflow
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Expanded( // Use Expanded to prevent text overflow
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build a similar property card
  Widget _buildSimilarPropertyCard(Map<String, dynamic> property) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 20),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Navigate to the property details screen when card is tapped
            Navigator.of(context).pushNamed('/view_property', arguments: property);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: property['coverImageUrl'] != null
                    ? Image.network(
                        property['coverImageUrl'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.image_not_supported)),
                      )
                    : const Center(child: Icon(Icons.house_siding)),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0A66C2),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property['location']?['town'] ?? 'N/A',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatPrice(property['price']),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
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

  // Widget to build a list of similar properties
  Widget _buildSimilarPropertiesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchSimilarProperties(widget.propertyData),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No similar properties found.'));
        }

        final similarProperties = snapshot.data!;
        return SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similarProperties.length,
            itemBuilder: (context, index) {
              final similarProperty = similarProperties[index];
              return _buildSimilarPropertyCard(similarProperty);
            },
          ),
        );
      },
    );
  }

  // Widget to build a section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0A66C2),
      ),
    );
  }

  // Widget to build tags (amenities/features)
  Widget _buildTags(List<dynamic> tags) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags.map((tag) => Chip(
        label: Text(tag.toString()),
        backgroundColor: Colors.blue.withOpacity(0.1),
        labelStyle: const TextStyle(color: Color(0xFF0A66C2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
      )).toList(),
    );
  }

  // Widget to build contact information
  Widget _buildContactInfo(Map<String, dynamic> contactInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactDetail(Icons.person, 'Contact Person', contactInfo['contactPerson'] ?? 'N/A'),
        _buildContactDetail(Icons.phone, 'Phone', contactInfo['phone'] ?? 'N/A'),
        _buildContactDetail(Icons.email, 'Email', contactInfo['email'] ?? 'N/A'),
      ],
    );
  }

  // New widget to build a blurred/obscured contact info section
  Widget _buildBlurredContactInfo(Map<String, dynamic> contactInfo) {
    return Stack(
      children: [
        // The blurred version of the contact info
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactDetail(Icons.person, 'Contact Person', '******************'),
            _buildContactDetail(Icons.phone, 'Phone', '************'),
            _buildContactDetail(Icons.email, 'Email', '******************'),
          ],
        ),
        // The blurring and overlay
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, color: Colors.white, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          'Log in to view agent contact details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
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
      ],
    );
  }

  Widget _buildContactDetail(IconData icon, String label, String value) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}