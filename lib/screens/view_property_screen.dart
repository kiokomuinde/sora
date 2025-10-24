// lib/screens/view_property_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter
import 'dart:async'; // Required for Timer
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sora_app/services/firestore_service.dart';
import 'package:share_plus/share_plus.dart'; 

class ViewPropertyScreen extends StatefulWidget {
  // Made propertyData nullable for deep-linking. It will be passed internally.
  final Map<String, dynamic>? propertyData; 
  // NEW: propertyId is passed when deep-linking from the URL parameter.
  final String? propertyId;
  final AuthService authService;

  const ViewPropertyScreen({
    Key? key,
    this.propertyData, // No longer required as it might be fetched via propertyId
    this.propertyId, // New parameter for deep linking
    required this.authService,
  }) : super(key: key);

  @override
  State<ViewPropertyScreen> createState() => _ViewPropertyScreenState();
}

class _ViewPropertyScreenState extends State<ViewPropertyScreen> {
  late CommonWidgets commonWidgets;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  // NEW: Scroll Controller for Similar Properties carousel
  final ScrollController _similarPropertiesScrollController = ScrollController();
  late final FirestoreService _firestoreService;

  // NEW: State to hold property data, either passed in or fetched.
  Map<String, dynamic>? _fetchedPropertyData;
  bool _isLoading = true; // NEW: Loading state for data fetch

  bool _isFavorite = false; 
  String? _userId;

  // Custom Gradient Definition for Price Text (Blue-to-Purple)
  final Gradient _priceGradient = const LinearGradient(
    colors: [Color(0xFF0A66C2), Color(0xFF673AB7)], // Blue to Purple
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // NEW: Light Blue color for location icon and other UI elements
  static const Color _lightBlueColor = Color(0xFF4FC3F7); 
  
  // =========================================================================
  // LISTING TYPE HELPER
  // =========================================================================

  /// Maps the database listing type to a user-friendly display tag.
  String _getListingTag(String? listingType) {
    if (listingType == null || listingType.isEmpty) return 'N/A';
    if (listingType == 'Staycation') return 'Airbnb';
    if (listingType == 'For Sale') return 'Buy';
    // For 'For Rent' or 'For Lease', strip the 'For ' prefix.
    if (listingType.startsWith('For ')) {
      return listingType.substring(4); 
    }
    return listingType;
  }
  
  // =========================================================================
  // UTILITY METHODS
  // =========================================================================

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

  // Custom SnackBar Widget with required isFavoriteAction 
  void _showCustomSnackBar(String message, {required bool isFavoriteAction}) {
    // Define colors and duration
    const Color lightBlue = Color(0xFFE3F2FD); 
    const Color deepPurple = Color(0xFF673AB7); 
    const Duration shortDuration = Duration(seconds: 2); 

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _BlinkingSnackBarContent(
          message: message,
          initialColor: lightBlue, 
          blinkColor: deepPurple, 
          initialTextColor: Colors.blue[900]!,
          blinkTextColor: Colors.white,
          isFavoriteAction: isFavoriteAction, 
        ),
        duration: shortDuration,
        backgroundColor: Colors.transparent, 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.zero, 
        elevation: 0, 
      ),
    );
  }

  // Method to fetch property data if only the ID is available
  Future<void> _fetchPropertyData() async {
    // 1. Check if data was passed internally (from another screen), if so, use it.
    if (widget.propertyData != null && widget.propertyData!.isNotEmpty) {
      _fetchedPropertyData = widget.propertyData;
      _isLoading = false;
      return;
    }
    
    // 2. If only the ID is available (deep link)
    if (widget.propertyId != null && widget.propertyId!.isNotEmpty) {
      setState(() { _isLoading = true; });
      final data = await _firestoreService.getPropertyById(widget.propertyId!);
      if (mounted) {
        setState(() {
          _fetchedPropertyData = data;
          _isLoading = false;
        });
      }
    } else {
      // 3. No data or ID provided, show error/empty state
      if (mounted) {
        setState(() {
          _isLoading = false;
          _fetchedPropertyData = null; 
        });
      }
    }
  }

  // Method to check initial favorite status from Firestore
  void _checkInitialFavoriteStatus() async {
    final user = widget.authService.getCurrentUser();
    // Use the ID from the fetched data
    final propertyId = _fetchedPropertyData?['id']; 

    if (user == null || propertyId == null) {
      return;
    }

    _userId = user.uid;
    
    final isFav = await _firestoreService.isFavorite(_userId!, propertyId);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  // Logic to toggle favorite status and interact with Firestore
  void _toggleFavorite() async {
    final user = widget.authService.getCurrentUser();
    if (user == null) {
      commonWidgets.showLoginSignupDialog();
      return;
    }
    
    // Use the ID from the fetched data
    final propertyId = _fetchedPropertyData?['id'];
    if (propertyId == null) {
      return; 
    }

    _userId = user.uid;
    final newFavoriteStatus = !_isFavorite;
    
    try {
      if (newFavoriteStatus) {
        await _firestoreService.addFavorite(_userId!, propertyId);
      } else {
        await _firestoreService.removeFavorite(_userId!, propertyId);
      }

      setState(() {
        _isFavorite = newFavoriteStatus;
      });

      String message = newFavoriteStatus
          ? 'Property added to Favorites!' 
          : 'Property removed from Favorites.';
          
      _showCustomSnackBar(message, isFavoriteAction: newFavoriteStatus); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite status: $e')),
      );
    }
  }

  // Function to fetch similar properties from Firestore
  Future<List<Map<String, dynamic>>> _fetchSimilarProperties() async {
    // Use the data from the state
    final currentProperty = _fetchedPropertyData;
    if (currentProperty == null) return [];
    
    // Ensure explicit casting and check for null/empty string for safety
    final String? currentListingType = currentProperty['listingType'] as String?;
    final String? currentPropertyId = currentProperty['id'] as String?;

    if (currentListingType == null || currentListingType.isEmpty) {
      return [];
    }
    
    if (currentPropertyId == null || currentPropertyId.isEmpty) {
      return []; 
    }

    final allProperties = await _firestoreService.getPropertiesByListingType(currentListingType);
    
    // Clinical Filter: Exclude the currently viewed property AND explicitly verify the listingType.
    final similarProperties = allProperties.where((property) {
      final fetchedPropertyId = property['id'] as String?;
      final fetchedListingType = property['listingType'] as String?; // Explicitly check listing type
      
      // Filter: Exclude the current property (by matching ID) AND ensure listingType is identical
      return fetchedPropertyId != null 
             && fetchedPropertyId != currentPropertyId
             && fetchedListingType == currentListingType;
    }).toList();
    
    return similarProperties;
  }
  
  // Logic to scroll the Similar Properties List
  void _scrollSimilarProperties(bool isForward) {
    // Card width (300) + Container margin (20) = 320.0
    const double cardStep = 320.0; 
    final double currentOffset = _similarPropertiesScrollController.offset;
    double newOffset;

    if (isForward) {
      newOffset = currentOffset + cardStep;
    } else {
      newOffset = currentOffset - cardStep;
    }

    // Clamp the offset to prevent overscrolling errors
    newOffset = newOffset.clamp(
      _similarPropertiesScrollController.position.minScrollExtent, 
      _similarPropertiesScrollController.position.maxScrollExtent,
    );

    _similarPropertiesScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // Method to show contact information to a logged-in user
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
  
  // Method to handle the login check and show dialog
  void _handleContactTap() {
    // Check if data is available
    final contactInfo = _fetchedPropertyData?['contactInfo'] ?? {};
    if (contactInfo.isEmpty) return;
    
    if (widget.authService.getCurrentUser() != null) {
      _showContactDialog(contactInfo);
    } else {
      commonWidgets.showLoginSignupDialog();
    }
  }

  // Method for sharing property
  void _shareProperty() {
    // Use the ID from the fetched data
    final propertyId = _fetchedPropertyData?['id']; 
    final propertyTitle = _fetchedPropertyData?['title'] ?? 'A Property from Sora Properties';
    
    const String baseDomain = 'https://soraproperties.co.ke';

    final String shareUrl = propertyId != null && propertyId.isNotEmpty
        ? '$baseDomain/#/view_property/$propertyId' 
        : '$baseDomain/#/'; 

    final String shareMessage = '$propertyTitle\n\nView this property here: $shareUrl';

    Share.share(
      shareMessage, 
      subject: propertyTitle,
    ); 

    // Use the positive action style for sharing
    _showCustomSnackBar('Link copied and ready to share!', isFavoriteAction: true);
  }

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    _firestoreService = FirestoreService();
    
    // Handle initial data load logic
    _fetchPropertyData().then((_) {
      if (_fetchedPropertyData != null) {
        _checkInitialFavoriteStatus();
      }
    });
    
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
    _similarPropertiesScrollController.dispose(); // DISPOSE similar properties controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final property = _fetchedPropertyData;
    if (property == null) {
      return Scaffold(
        appBar: commonWidgets.buildAppBar(),
        endDrawer: commonWidgets.buildDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Property Not Found or Invalid Link.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (widget.propertyId != null) 
                Text('ID: ${widget.propertyId}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    final propertyType = property['propertyType'];
    final Map<String, dynamic> details = propertyType == 'Residential'
        ? property['residentialDetails'] ?? {}
        : propertyType == 'Vocational'
            ? property['airbnbDetails'] ?? {}
            : {};

    final List<String> imageUrls = [
      if (property['coverImageUrl'] != null) property['coverImageUrl'],
      ...(property['additionalImageUrls']?.cast<String>() ?? []),
    ];

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
      // Note: Location detail is handled via _buildDetailRow in _buildPropertyHighlights
      {'icon': Icons.location_on, 'label': 'Location', 'value': property['location']?['town'] ?? 'N/A'},
    ];


    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                vertical: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLargeScreen)
                    _buildDesktopLayout(property, imageUrls, details)
                  else
                    _buildMobileLayout(property, imageUrls, details),
                  
                  const SizedBox(height: 40),

                  _buildSectionCard(
                    title: 'Description',
                    child: Text(
                      property['description'] ?? 'No description provided.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildSectionCard(
                    title: 'Property Details',
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: propertyDetails.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300.0,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        mainAxisExtent: 150.0,
                      ),
                      itemBuilder: (context, index) {
                        final detail = propertyDetails[index];
                        return _buildDetailCard(detail['icon'], detail['label'], detail['value']);
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

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

                  _buildSectionCard(
                    title: 'Contact Information',
                    child: GestureDetector(
                      onTap: _handleContactTap,
                      child: widget.authService.getCurrentUser() != null
                          ? _buildContactInfo(property['contactInfo'] ?? {})
                          : _buildBlurredContactInfo(property['contactInfo'] ?? {}),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildSectionCard(
                    title: 'Similar Properties',
                    child: _buildSimilarPropertiesList(),
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

  Widget _buildDesktopLayout(Map<String, dynamic> property, List<String> imageUrls, Map<String, dynamic> details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildImageCarousel(imageUrls),
        ),
        const SizedBox(width: 40),
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

    // Dynamic icon and color for the favorite button
    final Icon favoriteIcon = _isFavorite
        ? const Icon(Icons.favorite, size: 30, color: Colors.red) 
        : const Icon(Icons.favorite_border, size: 30, color: Colors.redAccent); 

    // Dynamic style for the favorite button
    final ButtonStyle favoriteButtonStyle = _isFavorite
        ? IconButton.styleFrom(
            backgroundColor: Colors.transparent, 
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(8),
            elevation: 0, 
          )
        : IconButton.styleFrom(
            // CORRECTED: Opacity set to 0.4
            backgroundColor: Colors.white.withOpacity(0.4), 
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(8),
            elevation: 5, 
          );

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
          // Navigation Buttons
          Positioned(
            left: 10,
            child: Visibility(
              visible: _currentPage > 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 30),
                color: const Color(0xFF0A66C2),
                style: IconButton.styleFrom(
                  // CORRECTED: Opacity set to 0.4
                  backgroundColor: Colors.white.withOpacity(0.4),
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
          Positioned(
            right: 10,
            child: Visibility(
              visible: _currentPage < imageUrls.length - 1,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 30),
                color: const Color(0xFF0A66C2),
                style: IconButton.styleFrom(
                  // CORRECTED: Opacity set to 0.4
                  backgroundColor: Colors.white.withOpacity(0.4),
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
          // Favorite and Share Buttons
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                // Favorite Button
                IconButton(
                  icon: favoriteIcon,
                  onPressed: _toggleFavorite, // Linked to the new logic
                  style: favoriteButtonStyle, 
                ),
                const SizedBox(width: 8),
                // Share Button
                IconButton(
                  icon: const Icon(Icons.share, size: 30, color: Color(0xFF0A66C2)),
                  onPressed: _shareProperty,
                  style: IconButton.styleFrom(
                    // CORRECTED: Opacity set to 0.4
                    backgroundColor: Colors.white.withOpacity(0.4),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceText(String price, {required double fontSize}) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return _priceGradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      child: Text(
        price,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Color is masked by the shader
        ),
      ),
    );
  }

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
        // Replaced Colors.green with gradient
        _buildPriceText(
          _formatPrice(property['price']),
          fontSize: MediaQuery.of(context).size.width >= 1000 ? 30 : 24,
        ),
        const SizedBox(height: 20),
        // UPDATED: Location with Icons.location_on and light blue color
        _buildDetailRow(
          Icons.location_on, 
          'Location', 
          property['location']?['town'] ?? 'N/A',
          iconColor: _lightBlueColor, // Apply light blue color
        ),
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
              if (widget.authService.getCurrentUser() != null) {
                _showContactDialog(contactInfo);
              } else {
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

  // UPDATED: Added optional iconColor parameter
  Widget _buildDetailRow(IconData icon, String label, String value, {Color? iconColor}) {
    return Row(
      children: [
        // Use the passed iconColor, or default to deep blue
        Icon(icon, color: iconColor ?? const Color(0xFF0A66C2), size: 20), 
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
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
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
  
  // UPDATED: Widget to build the listing type tag with UNCONDITIONAL gradient background
  Widget _buildListingTag(String? listingType) {
    final tagText = _getListingTag(listingType);
    
    // Apply the blue/purple gradient to ALL listing types (including Airbnb)
    final Decoration decoration = BoxDecoration(
      gradient: _priceGradient, // Uses the blue-to-purple gradient
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
    );
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: decoration,
      child: Text(
        tagText.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // UPDATED: Added Row for location icon and text
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
            // Note: This will push a new screen, potentially stacking them. 
            // Consider using pushReplacement or Navigator.of(context).pushNamedAndRemoveUntil 
            // if property deep links are used to prevent deep nesting.
            Navigator.of(context).pushNamed('/view_property', arguments: property);
          },
          child: Stack( // <--- START STACK HERE
            children: [
              Column(
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
                        // START: New Row for Location Icon and Text
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16, // Appropriate size for a card
                              color: _lightBlueColor, // The requested light blue color
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                property['location']?['town'] ?? 'N/A',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // END: New Row for Location Icon and Text
                        const SizedBox(height: 8),
                        // Replaced Colors.green with gradient
                        _buildPriceText(
                          _formatPrice(property['price']),
                          fontSize: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // NEW: Listing Type Tag positioned on the top left
              Positioned(
                top: 10,
                left: 10,
                child: _buildListingTag(property['listingType'] as String?),
              ),
            ],
          ), // <--- END STACK HERE
        ),
      ),
    );
  }

  // UPDATED: Added ScrollController and arrows inside a Stack
  Widget _buildSimilarPropertiesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchSimilarProperties(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No similar properties found.'));
        }

        final similarProperties = snapshot.data!;
        
        // Return a Stack to overlay arrows on the horizontally scrollable list
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 300,
              child: ListView.builder(
                controller: _similarPropertiesScrollController, // Attach controller
                scrollDirection: Axis.horizontal,
                itemCount: similarProperties.length,
                itemBuilder: (context, index) {
                  final similarProperty = similarProperties[index];
                  return _buildSimilarPropertyCard(similarProperty);
                },
              ),
            ),
            
            // Left Arrow
            Positioned(
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 30),
                color: const Color(0xFF0A66C2),
                style: IconButton.styleFrom(
                  // CORRECTED: Opacity set to 0.4
                  backgroundColor: Colors.white.withOpacity(0.4),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  elevation: 5,
                ),
                onPressed: () => _scrollSimilarProperties(false),
              ),
            ),
            
            // Right Arrow
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 30),
                color: const Color(0xFF0A66C2),
                style: IconButton.styleFrom(
                  // CORRECTED: Opacity set to 0.4
                  backgroundColor: Colors.white.withOpacity(0.4),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  elevation: 5,
                ),
                onPressed: () => _scrollSimilarProperties(true),
              ),
            ),
          ],
        );
      },
    );
  }

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

  Widget _buildBlurredContactInfo(Map<String, dynamic> contactInfo) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactDetail(Icons.person, 'Contact Person', '******************'),
            _buildContactDetail(Icons.phone, 'Phone', '************'),
            _buildContactDetail(Icons.email, 'Email', '******************'),
          ],
        ),
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

// Custom SnackBar Content for Conditional Blinking
class _BlinkingSnackBarContent extends StatefulWidget {
  final String message;
  final Color initialColor;
  final Color blinkColor;
  final Color initialTextColor;
  final Color blinkTextColor;
  final bool isFavoriteAction; 

  const _BlinkingSnackBarContent({
    required this.message,
    required this.initialColor,
    required this.blinkColor,
    required this.initialTextColor,
    required this.blinkTextColor,
    required this.isFavoriteAction, 
  });

  @override
  _BlinkingSnackBarContentState createState() => _BlinkingSnackBarContentState();
}

class _BlinkingSnackBarContentState extends State<_BlinkingSnackBarContent> with SingleTickerProviderStateMixin {
  late Color _currentColor;
  late Color _currentTextColor;
  late BoxBorder _currentBorder;
  Timer? _blinkTimer;

  // Function to change the colors and border state for the blinking animation
  void _toggleColorState({required bool isBlinking}) {
    setState(() {
      if (isBlinking) {
        _currentColor = widget.blinkColor;
        _currentTextColor = widget.blinkTextColor;
        _currentBorder = Border.all(color: Colors.transparent, width: 0); // Remove border
      } else {
        _currentColor = widget.initialColor;
        _currentTextColor = widget.initialTextColor;
        _currentBorder = Border.all(color: Colors.blue, width: 1); // Restore border
      }
    });
  }

  @override
  void initState() {
    super.initState();
    
    if (widget.isFavoriteAction) {
      // Logic for ADDING (existing blinking logic)
      _currentColor = widget.initialColor;
      _currentTextColor = widget.initialTextColor;
      _currentBorder = Border.all(color: Colors.blue, width: 1); 

      // Start the blinking sequence:
      _blinkTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) _toggleColorState(isBlinking: true);
      });

      _blinkTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted) _toggleColorState(isBlinking: false);
      });
      
      _blinkTimer = Timer(const Duration(milliseconds: 1250), () {
        if (mounted) _toggleColorState(isBlinking: true);
      });
      
    } else {
      // Logic for REMOVING (No blinking, red text/icon, light blue background)
      _currentColor = widget.initialColor; // Keep light blue background
      _currentTextColor = Colors.red[700]!; // Set red text color for disselect
      _currentBorder = Border.all(color: Colors.red[700]!, width: 1); // Red border for contrast
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Slower animation for a professional look
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _currentColor,
        borderRadius: BorderRadius.circular(10),
        border: _currentBorder, // Dynamic border
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: _currentTextColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(
                color: _currentTextColor, // Dynamic text color
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}