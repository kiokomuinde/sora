// /lib/screens/property_listing_screen.dart

import 'package:flutter/material.dart';
import 'package:seo/seo.dart'; // <-- Added SEO package
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sora_app/widgets/property_card.dart';
import 'package:sora_app/services/firestore_service.dart';

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

  bool _isMobileSearchExpanded = false;
  bool _isMobileSortExpanded = false;

  // UPDATED: Standardized asset paths for GitHub Pages compatibility
  final List<Map<String, dynamic>> _managedProperties = const [
    {
      'id': 'static_01',
      'title': 'Executive 2-Bedroom Apartment',
      'location': {'locality': 'Kilimani, Nairobi'},
      'price': '120000',
      'coverImageUrl': 'assets/assets/images/rental1.webp',
      'listingType': 'For Rent', 
      'residentialDetails': {'bedrooms': '2', 'bathrooms': '2'},
      'size': '1400',
      'isFavorite': false,
    },
    {
      'id': 'static_02',
      'title': 'Spacious 3-Bedroom Flat',
      'location': {'locality': 'Mirema, Nairobi'},
      'price': '65000',
      'coverImageUrl': 'assets/assets/images/rental2.webp',
      'listingType': 'For Rent',
      'residentialDetails': {'bedrooms': '3', 'bathrooms': '2'},
      'size': '1600',
      'isFavorite': false,
    },
    {
      'id': 'static_03',
      'title': 'Modern Studio Apartment',
      'location': {'locality': 'Ongata Rongai, Kajiado'},
      'price': '25000',
      'coverImageUrl': 'assets/assets/images/rental3.webp',
      'listingType': 'For Rent',
      'residentialDetails': {'bedrooms': '1', 'bathrooms': '1'},
      'size': '550',
      'isFavorite': false,
    },
    {
      'id': 'static_04',
      'title': 'Brand New 4-Bedroom Duplex',
      'location': {'locality': 'Membley, Kiambu'},
      'price': '80000',
      'coverImageUrl': 'assets/assets/images/rental4.webp',
      'listingType': 'For Rent',
      'residentialDetails': {'bedrooms': '4', 'bathrooms': '3'},
      'size': '2100',
      'isFavorite': false,
    },
    {
      'id': 'static_05',
      'title': 'Compact 1-Bedroom Flat',
      'location': {'locality': 'Thika, Kiambu'},
      'price': '30000',
      'coverImageUrl': 'assets/assets/images/rental5.webp',
      'listingType': 'For Rent',
      'residentialDetails': {'bedrooms': '1', 'bathrooms': '1'},
      'size': '700',
      'isFavorite': false,
    },
    {
      'id': 'static_06',
      'title': 'Prime 2-Bedroom Apartment',
      'location': {'locality': 'Kitengela, Kajiado'},
      'price': '45000',
      'coverImageUrl': 'assets/assets/images/rental6.webp',
      'listingType': 'For Rent',
      'residentialDetails': {'bedrooms': '2', 'bathrooms': '2'},
      'size': '1100',
      'isFavorite': false,
    },
    {
      'id': 'static_07',
      'title': 'Luxury 3-Bedroom Penthouse',
      'location': {'locality': 'Kileleshwa, Nairobi'},
      'price': '180000',
      'coverImageUrl': 'assets/assets/images/rental7.webp',
      'listingType': 'For Rent',
      'residentialDetails': {'bedrooms': '3', 'bathrooms': '4'},
      'size': '2500',
      'isFavorite': false,
    },
    {
      'id': 'static_08',
      'title': 'Affordable 2-Bedroom Flat',
      'location': {'locality': 'Syokimau, Machakos'},
      'price': '38000',
      'coverImageUrl': 'assets/assets/images/rental8.webp',
      'listingType': 'For Rent',
      'residentialDetails': {'bedrooms': '2', 'bathrooms': '1'},
      'size': '950',
      'isFavorite': false,
    },
  ];

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
        case 'bnb':
          queryValue = 'Staycation';
          break;
      }

      if (queryValue != null) {
        query = query.where('listingType', isEqualTo: queryValue);
      }

      final querySnapshot = await query.get();
      List<Map<String, dynamic>> results = querySnapshot.docs.map((doc) => {
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }).toList();

      if (_currentListingTypeFilter.toLowerCase() == 'rent' && results.isEmpty) {
        return List<Map<String, dynamic>>.from(_managedProperties);
      }

      return results;
    } catch (e) {
      debugPrint('Error fetching properties: $e');
      if (_currentListingTypeFilter.toLowerCase() == 'rent') {
        return List<Map<String, dynamic>>.from(_managedProperties);
      }
      return [];
    }
  }

  List<Map<String, dynamic>> _applyFiltersAndSort(List<Map<String, dynamic>> properties) {
    List<Map<String, dynamic>> filteredList = List<Map<String, dynamic>>.from(properties);

    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      filteredList = filteredList.where((p) {
        final title = (p['title'] ?? '').toString().toLowerCase();
        final locationMap = p['location'] as Map<String, dynamic>?;
        final town = (locationMap?['town'] ?? '').toString().toLowerCase();
        final locality = (locationMap?['locality'] ?? '').toString().toLowerCase();
        
        return title.contains(queryLower) ||
            town.contains(queryLower) ||
            locality.contains(queryLower);
      }).toList();
    }

    filteredList.sort((a, b) {
      final double priceA = double.tryParse(a['price']?.toString() ?? '0') ?? 0;
      final double priceB = double.tryParse(b['price']?.toString() ?? '0') ?? 0;
      
      final resA = a['residentialDetails'] as Map<String, dynamic>?;
      final resB = b['residentialDetails'] as Map<String, dynamic>?;

      final bedsA = int.tryParse(resA?['bedrooms']?.toString() ?? '0') ?? 0;
      final bedsB = int.tryParse(resB?['bedrooms']?.toString() ?? '0') ?? 0;
      
      if (_currentSortOption == 'price_low_to_high') {
        return priceA.compareTo(priceB);
      } else if (_currentSortOption == 'price_high_to_low') {
        return priceB.compareTo(priceA);
      } else if (_currentSortOption == 'bedrooms_asc') {
        return bedsA.compareTo(bedsB);
      } else if (_currentSortOption == 'bedrooms_desc') {
        return bedsB.compareTo(bedsA);
      }
      return 0;
    });

    return filteredList;
  }

  void _showOccupiedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.sentiment_dissatisfied, color: Colors.orange[700]),
              const SizedBox(width: 10),
              const Text('Currently Fully Occupied', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'We are sorry, this property from our managed portfolio is currently **fully occupied** and unavailable for viewing or rent. Please explore our other available listings, or contact us for similar properties!',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A66C2))),
            ),
          ],
        );
      },
    );
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

    // SEO Dynamic Meta Tags Generation
    final String baseTitle = _currentListingTypeFilter.isNotEmpty 
        ? _currentListingTypeFilter 
        : 'Discover';
    final String pageTitle = '$baseTitle Properties | Sora Properties';
    final String pageDesc = 'Explore our exclusive collection of $baseTitle properties tailored to your needs. Find premium listings managed by Sora Properties.';
    
    // Wrapped entire Scaffold in Seo.head
    return Seo.head(
      tags: [
        MetaTag(name: 'title', content: pageTitle),
        MetaTag(name: 'description', content: pageDesc),
        MetaTag(name: 'og:title', content: pageTitle),
        MetaTag(name: 'og:description', content: pageDesc),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: commonWidgets.buildAppBar(
          currentListingTypeFilter: _currentListingTypeFilter,
        ),
        endDrawer: commonWidgets.buildDrawer(),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(isLargeScreen),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyFilterDelegate(
                minHeight: isLargeScreen ? 76.0 : 60.0,
                maxHeight: isLargeScreen ? 76.0 : 60.0,
                child: _buildFilterAndSortSection(isLargeScreen),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchProperties(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No properties found.'),
                    ));
                  }
                  final filtered = _applyFiltersAndSort(snapshot.data!);
                  if (filtered.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No properties match your search.'),
                    ));
                  }
                  return _buildPropertiesGrid(filtered, isLargeScreen, isMediumScreen, screenWidth);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: commonWidgets.buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLargeScreen) {
    // Note: Assuming toCapitalized() is a string extension you have elsewhere in your code
    // If not, it might throw an error. You can replace with a basic String if needed.
    final String titleText = _currentListingTypeFilter.isNotEmpty
        ? '${_currentListingTypeFilter} Properties' 
        : 'Discover Your Dream Property';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 40 : 20,
        vertical: isLargeScreen ? 30 : 15, 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Wrapped the main Header in an H1 tag for SEO
          Seo.text(
            text: titleText,
            style: TextTagStyle.h1,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF0A66C2), Color(0xFF5B21B6)], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                titleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLargeScreen ? 42 : 32, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.white, 
                  letterSpacing: 1.2,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _PassingCloudText(
            text: 'Explore our exclusive collection of properties tailored to your needs.',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSortSection(bool isLargeScreen) {
    if (isLargeScreen) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 450, child: _buildSearchField(isLargeScreen)),
            const SizedBox(width: 20),
            SizedBox(width: 250, child: _buildSortDropdown(isLargeScreen)),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _buildMobileActionArea(),
        ),
      );
    }
  }

  Widget _buildMobileActionArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_isMobileSearchExpanded)
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildSearchField(false)),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isMobileSearchExpanded = false;
                      _searchController.clear(); 
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.close, color: Color(0xFF0A66C2)),
                  ),
                ),
              ],
            ),
          )
        else
          _buildSmallActionButton(
            icon: Icons.search,
            label: 'Search',
            onTap: () {
              setState(() {
                _isMobileSearchExpanded = true;
                _isMobileSortExpanded = false; 
              });
            },
          ),
        if (_isMobileSearchExpanded || _isMobileSortExpanded) const SizedBox(width: 15),
        if (_isMobileSortExpanded)
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8), 
                Expanded(child: _buildSortDropdown(false)),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isMobileSortExpanded = false;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.close, color: Color(0xFF0A66C2)),
                  ),
                ),
              ],
            ),
          )
        else
          _buildSmallActionButton(
            icon: Icons.sort,
            label: 'Sort',
            onTap: () {
              setState(() {
                _isMobileSortExpanded = true;
                _isMobileSearchExpanded = false; 
              });
            },
          ),
      ],
    );
  }

  Widget _buildSmallActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isLargeScreen) {
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
            color: const Color(0xFF0A66C2).withOpacity(0.2),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
        decoration: InputDecoration(
          hintText: 'Search location...',
          hintStyle: TextStyle(color: Colors.black45, fontSize: isLargeScreen ? 16 : 13),
          prefixIcon: Icon(Icons.search, color: const Color(0xFF0A66C2), size: isLargeScreen ? 24 : 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: isLargeScreen ? 18 : 12, horizontal: isLargeScreen ? 20 : 10),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildSortDropdown(bool isLargeScreen) {
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
            color: const Color(0xFF0A66C2).withOpacity(0.2),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2), 
      child: Container(
        height: isLargeScreen ? 56 : 42, 
        padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 20 : 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Center(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true, 
              value: _currentSortOption,
              icon: Icon(Icons.keyboard_arrow_down, color: const Color(0xFF0A66C2), size: isLargeScreen ? 24 : 20),
              elevation: 0, 
              style: TextStyle(color: Colors.black87, fontSize: isLargeScreen ? 16 : 13, fontWeight: FontWeight.w500),
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
                  case 'price_low_to_high': displayText = 'Price: Low to High'; break;
                  case 'price_high_to_low': displayText = 'Price: High to Low'; break;
                  case 'bedrooms_asc': displayText = 'Beds: Asc'; break;
                  case 'bedrooms_desc': displayText = 'Beds: Desc'; break;
                  default: displayText = '';
                }
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(displayText, overflow: TextOverflow.ellipsis),
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
    double childAspectRatio;

    if (isLargeScreen) {
      crossAxisCount = 5;
      childAspectRatio = 0.85;
    } else if (isMediumScreen) {
      crossAxisCount = 3;
      childAspectRatio = 0.85;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 0.95;
    }

    return Padding(
      padding: EdgeInsets.only(left: isLargeScreen ? 40 : 20, right: isLargeScreen ? 40 : 20, top: 10, bottom: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          
          final bool isForRent = (property['listingType'] ?? '').toString().toLowerCase() == 'for rent';
          final String propertyTitle = property['title']?.toString() ?? 'View Property Details';

          // SEO Critical: Wrapped the interactive property card in an Seo.link 
          // This allows Google to discover and crawl individual property URLs
          return Seo.link(
            href: 'https://soraproperties.co.ke/view_property/${property['id']}',
            anchor: propertyTitle,
            child: GestureDetector(
              onTap: isForRent ? _showOccupiedDialog : null, 
              child: AbsorbPointer(
                absorbing: isForRent, 
                child: PropertyCard(
                  property: property,
                  isLargeScreen: isLargeScreen,
                  isMediumScreen: isMediumScreen,
                  authService: widget.authService,
                  onAuthRequired: _showAuthDialog,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _StickyFilterDelegate({required this.child, required this.minHeight, required this.maxHeight});

  @override double get minExtent => minHeight;
  @override double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        boxShadow: shrinkOffset > 0 || overlapsContent
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
            : [],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxExtent || minHeight != oldDelegate.minExtent || child != oldDelegate.child;
  }
}

class _PassingCloudText extends StatefulWidget {
  final String text;
  const _PassingCloudText({Key? key, required this.text}) : super(key: key);
  @override
  __PassingCloudTextState createState() => __PassingCloudTextState();
}

class __PassingCloudTextState extends State<_PassingCloudText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this)..repeat(); 
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Wrapped the description text in an SEO paragraph tag
        return Seo.text(
          text: widget.text,
          style: TextTagStyle.p,
          child: ShaderMask(
            blendMode: BlendMode.srcIn, 
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [Colors.grey[600]!, Colors.blue[400]!, Colors.grey[600]!],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment(-3.0 + (_controller.value * 6.0), 0.0),
                end: Alignment(-1.0 + (_controller.value * 6.0), 0.0),
              ).createShader(bounds);
            },
            child: Text(widget.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
          ),
        );
      },
    );
  }
}