// /lib/screens/property_listing_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyListingScreen extends StatefulWidget {
  final AuthService authService;
  final String listingType;

  const PropertyListingScreen({Key? key, required this.authService, this.listingType = ''}) : super(key: key);

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  late CommonWidgets commonWidgets;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _currentSortOption = 'price_low_to_high';
  String _currentListingTypeFilter = '';

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    _currentListingTypeFilter = widget.listingType;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant PropertyListingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listingType != oldWidget.listingType) {
      setState(() {
        _currentListingTypeFilter = widget.listingType;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchProperties() async {
    try {
      Query query = FirebaseFirestore.instance.collection('properties');

      // Correctly map listing type to the string stored in Firestore
      String? queryValue;
      switch (_currentListingTypeFilter.toLowerCase()) {
        case 'buy':
          queryValue = 'For Sale';
          break;
        case 'rent':
          queryValue = 'For Rent';
          break;
        case 'lease':
          queryValue = 'For Lease';
          break;
      }

      if (queryValue != null) {
        query = query.where('listingType', isEqualTo: queryValue);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => {
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }).toList();
    } catch (e) {
      print('Error fetching properties: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _applyFiltersAndSort(List<Map<String, dynamic>> properties) {
    List<Map<String, dynamic>> filteredList = properties;

    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      filteredList = filteredList.where((p) {
        final title = p['title'] as String? ?? '';
        final town = (p['location'] as Map<String, dynamic>?)?['town'] as String? ?? '';
        return title.toLowerCase().contains(queryLower) ||
            town.toLowerCase().contains(queryLower);
      }).toList();
    }

    // Apply sorting
    filteredList.sort((a, b) {
      final double? priceA = double.tryParse(a['price']?.toString() ?? '0') ?? 0;
      final double? priceB = double.tryParse(b['price']?.toString() ?? '0') ?? 0;
      
      // Safely parse bedrooms from string to int
      final bedroomsA = int.tryParse((a['residentialDetails'] as Map<String, dynamic>?)?['bedrooms']?.toString() ?? '0') ?? 0;
      final bedroomsB = int.tryParse((b['residentialDetails'] as Map<String, dynamic>?)?['bedrooms']?.toString() ?? '0') ?? 0;
      
      if (_currentSortOption == 'price_low_to_high') {
        return priceA!.compareTo(priceB!);
      } else if (_currentSortOption == 'price_high_to_low') {
        return priceB!.compareTo(priceA!);
      } else if (_currentSortOption == 'bedrooms_asc') {
        return bedroomsA.compareTo(bedroomsB);
      } else if (_currentSortOption == 'bedrooms_desc') {
        return bedroomsB.compareTo(bedroomsA);
      }
      return 0;
    });

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      appBar: commonWidgets.buildAppBar(
        currentListingTypeFilter: _currentListingTypeFilter,
      ),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildFilterAndSortSection(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchProperties(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return commonWidgets.buildEmptyState(
                    'No Properties Found',
                    'There are no properties matching your search criteria.',
                    () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                    'Reset Filters',
                  );
                } else {
                  final properties = _applyFiltersAndSort(snapshot.data!);
                  if (properties.isEmpty) {
                    return commonWidgets.buildEmptyState(
                      'No Matching Properties',
                      'No properties match your current search and filter settings.',
                      () {
                        setState(() {
                          _searchController.clear();
                          _currentSortOption = 'price_low_to_high';
                        });
                      },
                      'Clear Filters',
                    );
                  }
                  return _buildPropertiesGrid(properties, isLargeScreen, isMediumScreen);
                }
              },
            ),
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentListingTypeFilter.isNotEmpty ? '${_currentListingTypeFilter.toCapitalized()} Properties' : 'Property Listings',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore the perfect properties for your needs.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSortSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by location, title...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: _currentSortOption,
            icon: const Icon(Icons.sort),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _currentSortOption = newValue;
                });
              }
            },
            items: <String>[
              'price_low_to_high',
              'price_high_to_low',
              'bedrooms_asc',
              'bedrooms_desc'
            ].map<DropdownMenuItem<String>>((String value) {
              String displayText;
              switch (value) {
                case 'price_low_to_high':
                  displayText = 'Price: Low to High';
                  break;
                case 'price_high_to_low':
                  displayText = 'Price: High to Low';
                  break;
                case 'bedrooms_asc':
                  displayText = 'Bedrooms: Ascending';
                  break;
                case 'bedrooms_desc':
                  displayText = 'Bedrooms: Descending';
                  break;
                default:
                  displayText = '';
              }
              return DropdownMenuItem<String>(
                value: value,
                child: Text(displayText),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesGrid(List<Map<String, dynamic>> properties, bool isLargeScreen, bool isMediumScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 100 : 20, vertical: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: isLargeScreen ? 0.75 : (isMediumScreen ? 0.7 : 0.8),
        ),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return _buildPropertyCard(property);
        },
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    // Safely parse residentialDetails
    final residentialDetails = property['residentialDetails'] as Map<String, dynamic>? ?? {};

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/view_property',
          arguments: property,
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                property['coverImageUrl'] ?? 'https://via.placeholder.com/400x300',
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KSh ${property['price']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property['title'],
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
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          (property['location'] as Map<String, dynamic>)['town'],
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFeatureIcon(Icons.bed, '${residentialDetails['bedrooms'] ?? 0} Beds'),
                      _buildFeatureIcon(Icons.bathtub, '${residentialDetails['bathrooms'] ?? 0} Baths'),
                      _buildFeatureIcon(Icons.square_foot, '${property['area'] ?? 0} sqft'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}