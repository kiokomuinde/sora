// lib/widgets/property_card.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/services/firestore_service.dart';

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
                    height: widget.isLargeScreen ? 100 : (widget.isMediumScreen ? 80 : 60), // Increased image height
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
                        height: widget.isLargeScreen ? 100 : (widget.isMediumScreen ? 80 : 60), // Increased image height
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          size: widget.isLargeScreen ? 50 : 30, // Increased icon size
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0), // Increased padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KSh ${widget.property['price']?.toString() ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16, // Increased font size
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A66C2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.property['title']?.toString() ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 14, // Increased font size
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (widget.property['location'] != null && widget.property['location']['town'] != null)
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]), // Increased icon size
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.property['location']['town'].toString(),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]), // Increased font size
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
                              Icon(Icons.bed, size: 14, color: Colors.grey[600]), // Increased icon size
                              const SizedBox(height: 4),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.property['residentialDetails']['bedrooms']} Beds',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]), // Increased font size
                              ),
                            ],
                          ),
                        if (widget.property['residentialDetails']['bathrooms'] != null)
                          Row(
                            children: [
                              Icon(Icons.bathtub, size: 14, color: Colors.grey[600]), // Increased icon size
                              const SizedBox(height: 4),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.property['residentialDetails']['bathrooms']} Baths',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]), // Increased font size
                              ),
                            ],
                          ),
                      ],
                      if (widget.property['area'] != null && widget.property['area'] != "0")
                        Row(
                          children: [
                            Icon(Icons.square_foot, size: 14, color: Colors.grey[600]), // Increased icon size
                            const SizedBox(height: 4),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.property['area']} sqft',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]), // Increased font size
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
                  style: const TextStyle(fontSize: 10), // Increased font size
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
                  size: 20, // Increased icon size
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