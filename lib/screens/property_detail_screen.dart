// /lib/screens/property_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const PropertyDetailScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late GoogleMapController mapController;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.property['isFavorite'] ?? false;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  // Sample coordinates (Kampala, Uganda)
  static final CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(0.3476, 32.5825),
    zoom: 14.4746,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Helper: Determine if image is network or asset
  Widget _buildImage(String imagePath) {
    bool isNetwork = imagePath.startsWith('http');
    return isNetwork
        ? Image.network(
            imagePath,
            fit: BoxFit.cover,
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.cover,
          );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(property['title']),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
        backgroundColor: Color(0xFF1E90FF),
      ),
      body: ListView(
        children: [
          // Image Carousel
          Container(
            height: 250,
            child: PageView.builder(
              itemCount: property['images'].length,
              itemBuilder: (context, index) {
                String imagePath = property['images'][index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(imagePath),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16),

          // Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              property['price'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),

          // Location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  property['location'],
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Property Info Badges
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoChip("🛏️ ${property['bedrooms']} Beds"),
                _buildInfoChip("🛁 ${property['bathrooms']} Baths"),
                _buildInfoChip("🏠 ${property['area']} sqft"),
                _buildInfoChip("${property['type']}"),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  property['description'],
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Map Preview Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Map Container
          Container(
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: _kInitialPosition,
                zoomControlsEnabled: true,
                myLocationButtonEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                markers: {
                  Marker(
                    markerId: MarkerId("property_location"),
                    position: _kInitialPosition.target,
                    infoWindow: InfoWindow(title: property['title']),
                    icon: BitmapDescriptor.defaultMarker,
                  )
                },
              ),
            ),
          ),

          // Debug Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Map loaded — if blank, check API key or emulator setup.",
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),

          SizedBox(height: 20),

          // Contact Agent Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                print("Contact agent tapped");
              },
              icon: Icon(Icons.phone),
              label: Text("Contact Agent"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E90FF),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.blue.withOpacity(0.1),
      labelStyle: TextStyle(color: Colors.blue),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}