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
    print('PropertyListingScreen: initState - Initial properties count: ${_filteredAndSortedProperties.length}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve search query from arguments if available
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? newSearchQuery = args?['searchQuery'] as String?;
    final String? newListingType = args?['listingType'] as String?;

    bool needsUpdate = false;
    if (newSearchQuery != null && newSearchQuery != _searchQuery) {
      _searchQuery = newSearchQuery;
      _searchController.text = _searchQuery; // Update controller text
      needsUpdate = true;
    }
    if (newListingType != null && newListingType != _currentListingTypeFilter) {
      _currentListingTypeFilter = newListingType;
      needsUpdate = true;
    }

    if (needsUpdate) {
      _applyFiltersAndSort();
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

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> properties = List<Map<String, dynamic>>.from(PropertyData.allProperties);

    // Apply listing type filter
    if (_currentListingTypeFilter.isNotEmpty) {
      properties = properties.where((p) => p['listingType'] == _currentListingTypeFilter).toList();
    }

    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      properties = properties.where((p) {
        return (p['title'] as String).toLowerCase().contains(queryLower) ||
            (p['location'] as String).toLowerCase().contains(queryLower) ||
            (p['description'] as String).toLowerCase().contains(queryLower) ||
            (p['type'] as String).toLowerCase().contains(queryLower);
      }).toList();
    }

    // Apply sorting
    properties.sort((a, b) {
      // Extract numeric price for comparison
      double? priceA = _parsePrice(a['price']);
      double? priceB = _parsePrice(b['price']);

      if (priceA == null || priceB == null) {
        // Handle cases where price parsing fails, e.g., by keeping original order or putting them last
        return 0;
      }

      switch (_currentSortOption) {
        case 'price_low_to_high':
          return priceA.compareTo(priceB);
        case 'price_high_to_low':
          return priceB.compareTo(priceA);
        case 'bedrooms_asc':
          return (a['bedrooms'] as int).compareTo(b['bedrooms'] as int);
        case 'bedrooms_desc':
          return (b['bedrooms'] as int).compareTo(a['bedrooms'] as int);
        case 'area_asc':
          return (double.tryParse(a['area'] ?? '0') ?? 0).compareTo(double.tryParse(b['area'] ?? '0') ?? 0);
        case 'area_desc':
          return (double.tryParse(b['area'] ?? '0') ?? 0).compareTo(double.tryParse(a['area'] ?? '0') ?? 0);
        default:
          return 0;
      }
    });

    setState(() {
      _filteredAndSortedProperties = properties;
    });
  }

  // Helper to parse price strings (e.g., "KSH 20,000,000" or "KSH 20,000/month")
  double? _parsePrice(String priceString) {
    try {
      // Remove currency symbols, commas, and "/month"
      String cleanedPrice = priceString
          .replaceAll('KSH', '')
          .replaceAll(',', '')
          .replaceAll('/month', '')
          .trim();
      return double.parse(cleanedPrice);
    } catch (e) {
      print('Error parsing price: $priceString - $e');
      return null;
    }
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
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 80 : (isMediumScreen ? 60 : 40),
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E90FF).withOpacity(0.8), Color(0xFF0A66C2).withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentListingTypeFilter.isNotEmpty
                        ? '${_currentListingTypeFilter.toTitleCase()} Properties'
                        : 'All Properties',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Showing results for "$_searchQuery"'
                        : 'Browse our extensive collection of properties.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Filters and Sort Section
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 30 : 20,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: Column(
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: isLargeScreen ? 800 : double.infinity),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search properties...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF0A66C2)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged();
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (query) {
                        _onSearchChanged();
                      },
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Listing Type Filter (if not already set by route)
                      if (widget.listingType.isEmpty)
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _currentListingTypeFilter.isEmpty ? null : _currentListingTypeFilter,
                            hint: const Text('Filter by Type'),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            ),
                            items: const [
                              DropdownMenuItem(value: '', child: Text('All Types')),
                              DropdownMenuItem(value: 'Buy', child: Text('For Sale')),
                              DropdownMenuItem(value: 'Rent', child: Text('For Rent')),
                              DropdownMenuItem(value: 'Lease', child: Text('For Lease')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _currentListingTypeFilter = value ?? '';
                                _applyFiltersAndSort();
                              });
                            },
                          ),
                        ),
                      SizedBox(width: widget.listingType.isEmpty ? (isLargeScreen ? 20 : 10) : 0),
                      // Sort By Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _currentSortOption,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'price_low_to_high', child: Text('Price: Low to High')),
                            DropdownMenuItem(value: 'price_high_to_low', child: Text('Price: High to Low')),
                            DropdownMenuItem(value: 'bedrooms_asc', child: Text('Bedrooms: Low to High')),
                            DropdownMenuItem(value: 'bedrooms_desc', child: Text('Bedrooms: High to Low')),
                            DropdownMenuItem(value: 'area_asc', child: Text('Area: Small to Large')),
                            DropdownMenuItem(value: 'area_desc', child: Text('Area: Large to Small')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _currentSortOption = value!;
                              _applyFiltersAndSort();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Property Grid
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                vertical: isLargeScreen ? 30 : 20,
              ),
              child: _filteredAndSortedProperties.isEmpty
                  ? Column(
                      children: [
                        SizedBox(height: isLargeScreen ? 50 : 30),
                        Icon(Icons.sentiment_dissatisfied, size: isLargeScreen ? 100 : 70, color: Colors.grey[400]),
                        SizedBox(height: 20),
                        Text(
                          'No properties found matching your criteria.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 22 : (isMediumScreen ? 18 : 16),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: isLargeScreen ? 50 : 30),
                      ],
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
                        crossAxisSpacing: isLargeScreen ? 30 : 20,
                        mainAxisSpacing: isLargeScreen ? 30 : 20,
                        childAspectRatio: isLargeScreen ? 0.8 : (isMediumScreen ? 0.75 : 0.9),
                      ),
                      itemCount: _filteredAndSortedProperties.length,
                      itemBuilder: (context, index) {
                        final property = _filteredAndSortedProperties[index];
                        // Ensure the isFavorite status is reflected from the set
                        final bool isCurrentlyFavorite = _favoritedPropertyTitles.contains(property['title']);
                        return _buildPropertyCard(property, isCurrentlyFavorite);
                      },
                    ),
            ),
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property, bool isCurrentlyFavorite) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Image.asset(
                    property['images'][0],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(
                        isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isCurrentlyFavorite ? Colors.red : Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isCurrentlyFavorite) {
                            _favoritedPropertyTitles.remove(property['title']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${property['title']} removed from favorites.'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          } else {
                            _favoritedPropertyTitles.add(property['title']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${property['title']} added to favorites!'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E90FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        property['listingType'] ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
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
                        const SizedBox(width: 12),
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
                        Icon(Icons.square_foot, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${property['area']} sqft',
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
  }
}
