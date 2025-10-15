// /lib/screens/property_listing_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sora_app/widgets/property_card.dart';
import 'package:sora_app/services/firestore_service.dart';

// Assuming StringCasingExtension is defined in common_widgets.dart or another imported file.

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
        case 'airbnb':
          queryValue = 'Staycation';
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

    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      filteredList = filteredList.where((p) {
        final title = p['title'] as String? ?? '';
        final town = (p['location'] as Map<String, dynamic>?)?['town'] as String? ?? '';
        return title.toLowerCase().contains(queryLower) ||
            town.toLowerCase().contains(queryLower);
      }).toList();
    }

    filteredList.sort((a, b) {
      final double? priceA = double.tryParse(a['price']?.toString() ?? '0') ?? 0;
      final double? priceB = double.tryParse(b['price']?.toString() ?? '0') ?? 0;
      
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

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log In to Save Favorites'),
          content: const Text('You must be logged in to save properties to your favorites.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/signin');
              },
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: commonWidgets.buildAppBar(
        currentListingTypeFilter: _currentListingTypeFilter,
      ),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(), 
            _buildFilterAndSortSection(isLargeScreen),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchProperties(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No properties found.'));
                }
                final filteredAndSortedProperties = _applyFiltersAndSort(snapshot.data!);
                if (filteredAndSortedProperties.isEmpty) {
                  return const Center(child: Text('No properties match your search.'));
                }
                return _buildPropertiesGrid(filteredAndSortedProperties, isLargeScreen, isMediumScreen, screenWidth);
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
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2).withOpacity(0.8), 
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0A66C2).withOpacity(0.8), 
            const Color(0xFF5B21B6).withOpacity(0.8), 
          ],
          stops: const [0.8, 1.0], 
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.listingType.isNotEmpty
                ? '${widget.listingType.toCapitalized()} Properties'
                : 'All Properties',
            style: const TextStyle(
              fontSize: 48, 
              fontWeight: FontWeight.w800, 
              color: Colors.white, 
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Explore our exclusive collection of properties tailored to your needs. Your dream home awaits.',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.95), 
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSortSection(bool isLargeScreen) {
    Widget content = isLargeScreen
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // INCREASED WIDTH FOR LARGE SCREEN (from 350 to 450)
              SizedBox(
                width: 450, 
                child: _buildSearchField(),
              ),
              _buildSortDropdown(),
            ],
          )
        : Wrap(
            spacing: 15,
            runSpacing: 15,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              // INCREASED WIDTH FOR SMALL/MEDIUM SCREEN (from 280 to 320)
              SizedBox(
                width: 320, 
                child: _buildSearchField(),
              ),
              _buildSortDropdown(),
            ],
          );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 40 : 20,
        vertical: 25,
      ),
      child: content,
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)], 
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A66C2).withOpacity(0.3),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by title or town...',
          hintStyle: const TextStyle(color: Colors.black45, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0A66C2), size: 24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none, 
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)], 
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A66C2).withOpacity(0.3),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2), 
      child: Container(
        height: 56, 
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentSortOption,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0A66C2)),
              elevation: 0, 
              style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
              dropdownColor: Colors.white,
              onChanged: (String? newValue) {
                setState(() {
                  _currentSortOption = newValue!;
                });
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
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesGrid(List<Map<String, dynamic>> properties, bool isLargeScreen, bool isMediumScreen, double screenWidth) {
    int crossAxisCount;
    if (isLargeScreen) {
      crossAxisCount = 5;
    } else if (isMediumScreen) {
      crossAxisCount = 3;
    } else if (screenWidth > 400) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 40 : 20, vertical: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.75,
        ),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          // Use the new PropertyCard widget
          return PropertyCard(
            property: property,
            isLargeScreen: isLargeScreen,
            isMediumScreen: isMediumScreen,
            authService: widget.authService,
            onAuthRequired: _showAuthDialog,
          );
        },
      ),
    );
  }
}