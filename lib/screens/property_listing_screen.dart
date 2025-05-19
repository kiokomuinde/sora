// /lib/screens/property_listing_screen.dart

import 'package:flutter/material.dart';
import 'property_detail_screen.dart'; // Make sure this file exists

class PropertyListingScreen extends StatefulWidget {
  const PropertyListingScreen({Key? key}) : super(key: key);

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  // Dummy property data
  final List<Map<String, dynamic>> _properties = [
    {
      "title": "5-Bedroom Mansion - Ongata Rongai",
      "price": "KSH 20,000,000",
      "location": "Olekasasi, Ongata Rongai",
      "images": [
        "assets/images/mansion1.webp",
        "assets/images/inside_mansion1_1.webp",
        "assets/images/inside_mansion1_2.webp",
        "assets/images/inside_mansion1_3.webp"
      ],
      "bedrooms": 3,
      "bathrooms": 2,
      "area": "2000",
      "type": "Mansion",
      "description":
          "A beautiful 3-bedroom mansion located in Olekasasi town. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },
    {
      "title": "Studio Apartment - Ruiru",
      "price": "KSH 10,000/month",
      "location": "Ruiru, Thika Road",
      "images": [
        "assets/images/apartment1.webp",
        "assets/images/apartment1_1.webp",
        "assets/images/apartment1_2.webp",
        "assets/images/apartment1_3.webp"
      ],
      "bedrooms": 1,
      "bathrooms": 1,
      "area": "600",
      "type": "Apartment",
      "description":
          "Modern studio apartment located in Ruiru of Thika road. Close to shops, schools, and transport hubs.",
      "isFavorite": true,
    },
    {
      "title": "Luxury Villa - Karen",
      "price": "KSH 80,000,000",
      "location": "Karen, Nairobi",
      "images": [
        "assets/images/villa1.webp",
        "assets/images/villa1_1.webp",
        "assets/images/villa1_2.webp",
        "assets/images/villa1_3.webp",
      ],
      "bedrooms": 4,
      "bathrooms": 5,
      "area": "5000",
      "type": "Villa",
      "description":
          "Luxurious villa with top-notch finishes. Includes private pool, garage, and security system.",
      "isFavorite": false,
    },
    {
      "title": "Luxury Mansion - Runda",
      "price": "KSH 110,000,000",
      "location": "Runda, Nairobi",
      "images": [
        "assets/images/mansion2.webp",
        "assets/images/inside_mansion2_1.webp",
        "assets/images/inside_mansion2_2.webp",
        "assets/images/inside_mansion2_3.webp"
      ],
      "bedrooms": 4,
      "bathrooms": 5,
      "area": "1 acre",
      "type": "Mansion",
      "description":
          "Luxurious mansion with top-notch finishes. Includes private pool, garage, and security system.",
      "isFavorite": false,
    },
    {
      "title": "Office Space - Westlands",
      "price": "KSH 200,000/month",
      "location": "Westlands, Nairobi",
      "images": [
        "assets/images/office1.webp",
        "assets/images/office1_1.webp",
        "assets/images/office1_2.webp",
        "assets/images/office1_3.webp"
      ],
      "bedrooms": 0,
      "bathrooms": 2,
      "area": "2500",
      "type": "Commercial",
      "description":
          "Spacious office space available for rent in Westlands, Nairobi. Ideal for businesses looking for central location.",
      "isFavorite": true,
    },
    {
      "title": "Office Space - Nairobi CBD",
      "price": "KSH 250,000/month",
      "location": "CBD, Nairobi",
      "images": [
        "assets/images/office1.webp",
        "assets/images/office1_1.webp",
        "assets/images/office1_2.webp",
        "assets/images/office1_3.webp"
      ],
      "bedrooms": 0,
      "bathrooms": 2,
      "area": "4500",
      "type": "Commercial",
      "description":
          "Spacious office space available for rent in Westlands, Nairobi. Ideal for businesses looking for central location.",
      "isFavorite": true,
    },
  ];

  bool _showFilters = false;
  double _currentSliderValue = 50;

  void _toggleFavorite(int index) {
    setState(() {
      _properties[index]['isFavorite'] = !_properties[index]['isFavorite'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Properties"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
        backgroundColor: Color(0xFF1E90FF),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search by location...",
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          SizedBox(height: 16),

          // Filters section
          if (_showFilters)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Filter by",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text("Price Range"),
                    Slider(
                      value: _currentSliderValue,
                      min: 0,
                      max: 100,
                      divisions: 5,
                      label: "${_currentSliderValue.toInt()}M UGX",
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: null,
                          child: Text("Reset"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Apply"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1E90FF),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

          SizedBox(height: 16),

          // Property cards
          for (int i = 0; i < _properties.length; i++)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyDetailScreen(property: _properties[i]),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // Load image dynamically
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: (() {
                            String imagePath = _properties[i]['images'][0];
                            bool isNetwork = imagePath.startsWith('http');

                            if (isNetwork) {
                              return Image.network(
                                imagePath,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            } else {
                              return Image.asset(
                                imagePath,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            }
                          })(),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: GestureDetector(
                              onTap: () => _toggleFavorite(i),
                              child: Icon(
                                _properties[i]['isFavorite']
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: _properties[i]['isFavorite'] ? Colors.red : Colors.grey,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Text(
                        _properties[i]['title'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(
                        _properties[i]['price'],
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            _properties[i]['location'],
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}