// lib/widgets/property_card.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/services/firestore_service.dart';
import 'package:intl/intl.dart';

// A new StatefulWidget for the individual property cards
class PropertyCard extends StatefulWidget {
  final Map<String, dynamic> property;
  final bool isLargeScreen;
  final bool isMediumScreen;
  final AuthService authService;
  final VoidCallback onAuthRequired;

  const PropertyCard({
    super.key,
    required this.property,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.authService,
    required this.onAuthRequired,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool _isFavorite = false;
  late FirestoreService _firestoreService;

  // Helper map for common amenity names to Material Icons
  static const Map<String, IconData> _amenityIcons = {
    'Wi-Fi': Icons.wifi,
    'Kitchen': Icons.kitchen,
    'Parking': Icons.local_parking,
    'Pool': Icons.pool,
    'AC': Icons.ac_unit,
    'Gym': Icons.fitness_center,
    'Washer': Icons.local_laundry_service,
    'Hanger': Icons.dry_cleaning,
    'Self check-in': Icons.lock_open,
    'TV': Icons.tv,
    'Patio or balcony': Icons.deck,
    'Hot tub': Icons.hot_tub,
    'Heating': Icons.whatshot,
    'Breakfast': Icons.free_breakfast,
    'Pets allowed': Icons.pets,
  };

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

  // A new method to format the price with commas
  String _formatPrice(dynamic price) {
    try {
      // Handle the possibility of a string with commas or a number
      final numberPrice = double.tryParse(price.toString().replaceAll(',', ''));
      if (numberPrice == null) {
        return 'N/A';
      }

      final currencyFormatter = NumberFormat.currency(
        locale: 'en_US',
        symbol: 'KSh ',
        decimalDigits: 0,
      );
      return currencyFormatter.format(numberPrice);
    } catch (e) {
      print('Error formatting price: $e');
      return 'N/A';
    }
  }

  // Helper widget to display up to 5 amenity icons for Staycation listings
  Widget _buildStaycationAmenities(Map<String, dynamic> airbnbDetails) {
    // Safely cast amenities to a list of strings
    final List<String> amenities = (airbnbDetails['amenities'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    // Filter for known icons and take the top 5
    final List<Widget> amenityWidgets = amenities
        .where(_amenityIcons.containsKey)
        .take(5) // Dynamic: Take the first 5 amenities
        .map((amenity) {
      return Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Tooltip(
          message: amenity,
          child: Icon(
            _amenityIcons[amenity]!, // Use ! because we checked containsKey
            size: 20,
            color: const Color(0xFF0A66C2), // Prominent blue color
          ),
        ),
      );
    }).toList();

    if (amenityWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: amenityWidgets,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- START: Conditional Data Parsing (FIXED) ---
    final String listingType = widget.property['listingType'] ?? 'Unknown';
    // Safely access nested maps
    final Map<String, dynamic> residentialDetails = widget.property['residentialDetails'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> airbnbDetails = widget.property['airbnbDetails'] as Map<String, dynamic>? ?? {};

    // Variables for Card Display
    final int displayBeds;
    final int displayBaths;
    final String displayArea;
    int guestsCapacity = 0;

    // Safely retrieve area. We assume 'area' is the field for size.
    final String rootArea = widget.property['area']?.toString() ?? '0';

    if (listingType == 'Staycation') {
      // Staycation: Show Guests and Baths
      guestsCapacity = int.tryParse((airbnbDetails['guests'] ?? '0').toString().replaceAll(',', '')) ?? 0;
      displayBeds = 0;
      displayArea = '0';
      // Baths is a physical property detail, so use residentialDetails
      displayBaths = int.tryParse((residentialDetails['bathrooms'] ?? '0').toString().replaceAll(',', '')) ?? 0;
    } else {
      // Residential (Buy, Rent, Lease): Show Beds, Baths, and Area
      displayBeds = int.tryParse((residentialDetails['bedrooms'] ?? '0').toString().replaceAll(',', '')) ?? 0;
      displayBaths = int.tryParse((residentialDetails['bathrooms'] ?? '0').toString().replaceAll(',', '')) ?? 0;
      displayArea = rootArea;
    }
    // --- END: Conditional Data Parsing (FIXED) ---

    final String imageUrl = widget.property['coverImageUrl']?.toString() ?? 'https://via.placeholder.com/150';

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    imageUrl,
                    height: 160, // Increased image height to occupy upper half
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
                        height: 160, // Increased image height
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 68,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [Colors.deepPurple, Colors.blue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          _formatPrice(widget.property['price']),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Color must be white to see the gradient effect
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.property['title']?.toString() ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue, // Updated to blue
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (widget.property['location'] != null && widget.property['location']['town'] != null)
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 19, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.property['location']['town'].toString(),
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      // --- START: Conditional Property Features (Guests/Beds, Baths, Area) ---
                      const SizedBox(height: 8),
                      if (listingType == 'Staycation') ...[
                        // Display Guests and Baths for Staycation
                        Row(
                          children: [
                            if (guestsCapacity > 0) ...[
                              Icon(Icons.people_alt, size: 19, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '$guestsCapacity Guests',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                            ],
                            if (displayBaths > 0) ...[
                              Icon(Icons.bathtub, size: 19, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '$displayBaths Baths',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ],
                        ),
                        // Display Amenity Icons (NEW)
                        _buildStaycationAmenities(airbnbDetails),

                      ] else ...[
                        // Residential (Buy, Rent, Lease): Display Beds, Baths, and Area
                        Row(
                          children: [
                            if (displayBeds > 0) ...[
                              Icon(Icons.bed, size: 19, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '$displayBeds Beds',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                            ],
                            if (displayBaths > 0) ...[
                              Icon(Icons.bathtub, size: 19, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '$displayBaths Baths',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                            ],
                            if (displayArea != '0') ...[
                              Icon(Icons.square_foot, size: 19, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '$displayArea sqft',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ],
                        ),
                      ],
                      // --- END: Conditional Property Features ---
                    ].whereType<Widget>().toList(),
                  ),
                ),
              ],
            ),
            // Listing type button - Moved to top left
            Positioned(
              top: 5,
              left: 5,
              child: ElevatedButton(
                onPressed: () {
                  // This button is for display, so onPressed is empty
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A66C2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  listingTypeDisplay,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            // Favorite button - New position on top right
            Positioned(
              top: 3,
              right: 3,
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                  size: 26,
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