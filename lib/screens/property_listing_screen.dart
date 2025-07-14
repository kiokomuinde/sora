// /lib/screens/property_listing_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/screens/property_detail_screen.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/data/property_data.dart';

class PropertyListingScreen extends StatefulWidget {
  final AuthService authService;
  final String listingType;

  const PropertyListingScreen({Key? key, required this.authService, this.listingType = ''}) : super(key: key);

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  late CommonWidgets commonWidgets;
  late List<Map<String, dynamic>> _filteredAndSortedProperties;
  String _currentSortOption = 'price_low_to_high';
  String _currentListingTypeFilter = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _favoritedPropertyTitles = {}; // Set to store titles of favorited properties

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    _currentListingTypeFilter = widget.listingType;
    _searchController.addListener(_onSearchChanged);
    print('PropertyListingScreen: initState - Received listingType: "${widget.listingType}"');
    _applyFiltersAndSort();
    print('PropertyListingScreen: initState - Final properties count after filter: ${_filteredAndSortedProperties.length}');
  }

  @override
  void didUpdateWidget(covariant PropertyListingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listingType != oldWidget.listingType) {
      _currentListingTypeFilter = widget.listingType;
      print('PropertyListingScreen: didUpdateWidget - listingType changed to: "${widget.listingType}"');
      _applyFiltersAndSort();
      print('PropertyListingScreen: didUpdateWidget - Final properties count after filter: ${_filteredAndSortedProperties.length}');
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
      _applyFiltersAndSort();
    });
  }

  void _onListingTypeFilterChanged(String newFilter) {
    setState(() {
      _currentListingTypeFilter = newFilter;
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    print('PropertyListingScreen: _applyFiltersAndSort - Starting...');
    List<Map<String, dynamic>> tempProperties = List.from(PropertyData.allProperties);

    print('PropertyListingScreen: _applyFiltersAndSort - Total properties in PropertyData.allProperties: ${tempProperties.length}');
    if (tempProperties.isNotEmpty) {
      print('PropertyListingScreen: _applyFiltersAndSort - Sample RAW listingTypes in PropertyData: ${tempProperties.take(5).map((p) => p['listingType']).toList()}');
    }

    if (_searchQuery.isNotEmpty) {
      final String searchQueryLower = _searchQuery.toLowerCase().trim();
      tempProperties = tempProperties.where((property) {
        return property['title'].toLowerCase().contains(searchQueryLower) ||
               property['location'].toLowerCase().contains(searchQueryLower);
      }).toList();
      print('PropertyListingScreen: _applyFiltersAndSort - Properties after search filter: ${tempProperties.length}');
    }

    List<Map<String, dynamic>> filteredProperties = [];

    if (_currentListingTypeFilter.isNotEmpty) {
      print('PropertyListingScreen: _applyFiltersAndSort - Applying filter for listingType: "${_currentListingTypeFilter}"');
      final String filterValueLower = _currentListingTypeFilter.toLowerCase().trim();
      filteredProperties = tempProperties
          .where((property) {
            final String propertyListingType = property['listingType'] as String;
            final String propertyListingTypeLowerTrimmed = propertyListingType.toLowerCase().trim();
            final bool matches = propertyListingTypeLowerTrimmed == filterValueLower;
            return matches;
          })
          .toList();
      print('PropertyListingScreen: _applyFiltersAndSort - Properties after listing type filter: ${filteredProperties.length}');
    } else {
      print('PropertyListingScreen: _applyFiltersAndSort - No listingType filter applied. Using properties after search: ${tempProperties.length}');
      filteredProperties = List.from(tempProperties);
    }

    switch (_currentSortOption) {
      case 'price_low_to_high':
        filteredProperties.sort((a, b) => _parsePrice(a['price']).compareTo(_parsePrice(b['price'])));
        break;
      case 'price_high_to_low':
        filteredProperties.sort((a, b) => _parsePrice(b['price']).compareTo(_parsePrice(a['price'])));
        break;
      case 'bedrooms_low_to_high':
        filteredProperties.sort((a, b) => (a['bedrooms'] as int).compareTo(b['bedrooms'] as int));
        break;
      case 'bedrooms_high_to_low':
        filteredProperties.sort((a, b) => (b['bedrooms'] as int).compareTo(a['bedrooms'] as int));
        break;
      case 'area_low_to_high':
        filteredProperties.sort((a, b) {
          double areaA = _parseArea(a['area']);
          double areaB = _parseArea(b['area']);
          return areaA.compareTo(areaB);
        });
        break;
      case 'area_high_to_low':
        filteredProperties.sort((a, b) {
          double areaA = _parseArea(a['area']);
          double areaB = _parseArea(b['area']);
          return areaB.compareTo(areaA);
        });
        break;
      case 'newest':
        break;
      case 'oldest':
        break;
    }

    if (filteredProperties.isEmpty && PropertyData.allProperties.isNotEmpty) {
      print('PropertyListingScreen: DEBUG - Final filtered list is EMPTY. Falling back to ALL properties (${PropertyData.allProperties.length}).');
      _filteredAndSortedProperties = List.from(PropertyData.allProperties);
    } else {
      _filteredAndSortedProperties = filteredProperties;
    }

    print('PropertyListingScreen: _applyFiltersAndSort - Final _filteredAndSortedProperties count before setState: ${_filteredAndSortedProperties.length}');
    setState(() {});
    print('PropertyListingScreen: _applyFiltersAndSort - Final _filteredAndSortedProperties count AFTER setState: ${_filteredAndSortedProperties.length}');
  }

  double _parsePrice(String priceString) {
    String cleanPrice = priceString.replaceAll(RegExp(r'[KSH,$/year/month]'), '').trim();
    if (cleanPrice.isEmpty) return 0.0;
    try {
      return double.parse(cleanPrice);
    } catch (e) {
      print("Error parsing price: $priceString - $e");
      return 0.0;
    }
  }

  double _parseArea(String areaString) {
    String cleanArea = areaString.toLowerCase().replaceAll('sq ft', '').replaceAll('sq meters', '').replaceAll('acre', '').trim();
    if (cleanArea.isEmpty) return 0.0;
    try {
      double value = double.parse(cleanArea);
      if (areaString.toLowerCase().contains('acre')) {
        return value * 43560;
      }
      return 0.0; // Return 0.0 if unable to parse after cleaning
    } catch (e) {
      print("Error parsing area: $areaString - $e");
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      appBar: commonWidgets.buildAppBar(
        showSearchBar: true,
        searchController: _searchController,
        onSearchChanged: (query) {},
        currentListingTypeFilter: _currentListingTypeFilter,
        onListingTypeFilterChanged: _onListingTypeFilterChanged,
      ),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                vertical: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.listingType.isEmpty)
                    DropdownButton<String>(
                      value: _currentListingTypeFilter.isEmpty ? null : _currentListingTypeFilter,
                      hint: const Text('Filter by Type'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _currentListingTypeFilter = newValue ?? '';
                          _applyFiltersAndSort();
                        });
                      },
                      items: <String>['', 'Buy', 'Rent', 'Lease', 'Mansion', 'Apartment', 'Villa', 'Commercial', 'Bungalow', 'Townhouse', 'Land']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value.isEmpty ? null : value,
                          child: Text(value.isEmpty ? 'All Types' : value),
                        );
                      }).toList(),
                    ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _currentSortOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _currentSortOption = newValue!;
                        _applyFiltersAndSort();
                      });
                    },
                    items: <String>[
                      'price_low_to_high',
                      'price_high_to_low',
                      'bedrooms_low_to_high',
                      'bedrooms_high_to_low',
                      'area_low_to_high',
                      'area_high_to_low',
                      'newest',
                      'oldest',
                    ].map<DropdownMenuItem<String>>((String value) {
                      String text = value.replaceAll('_', ' ').toCapitalized();
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('Sort by $text'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: _filteredAndSortedProperties.isEmpty
                  ? Center(
                child: Text(
                  'No properties found matching your criteria.',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: isLargeScreen ? 0.75 : (isMediumScreen ? 0.7 : 0.8),
                ),
                itemCount: _filteredAndSortedProperties.length,
                itemBuilder: (context, index) {
                  final property = _filteredAndSortedProperties[index];
                  final String propertyTitle = property['title']; // Get a unique identifier for favoriting
                  final bool isFavorited = _favoritedPropertyTitles.contains(propertyTitle);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailScreen(property: property),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    property['images'][0],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Listing Type - Top Left, Blue Background
                                Positioned(
                                  top: 8,
                                  left: 8, // Changed from right to left
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A66C2).withOpacity(0.7), // Blue background
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(
                                      property['listingType'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Favorite Button - Top Right
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4), // Semi-transparent background for the icon button
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isFavorited ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorited ? Colors.red : Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (isFavorited) {
                                            _favoritedPropertyTitles.remove(propertyTitle);
                                          } else {
                                            _favoritedPropertyTitles.add(propertyTitle);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property['price'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0A66C2),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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
                                      Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${property['bedrooms']} Beds',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.bathtub, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${property['bathrooms']} Baths',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          property['location'],
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
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
                  );
                },
              ),
            ),
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }
}
