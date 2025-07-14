// lib/screens/search_results_screen.dart
import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets
import 'package:sora_app/data/property_data.dart'; // Import the centralized property data
import 'package:sora_app/screens/property_detail_screen.dart'; // For navigating to property details

class SearchResultsScreen extends StatefulWidget {
  final AuthService authService;
  // Search query can be passed as an argument to this screen
  final String? searchQuery;

  const SearchResultsScreen({super.key, required this.authService, this.searchQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late CommonWidgets commonWidgets;
  late List<Map<String, dynamic>> _searchResults;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    _searchController.text = widget.searchQuery ?? '';
    _performSearch();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _performSearch();
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchResults = PropertyData.allProperties.where((property) {
        return property['title'].toLowerCase().contains(query) ||
               property['location'].toLowerCase().contains(query) ||
               property['description'].toLowerCase().contains(query) ||
               property['type'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleFavorite(String title) {
    setState(() {
      // Dummy favorite logic, replace with actual backend integration
      final index = PropertyData.allProperties.indexWhere((p) => p['title'] == title);
      if (index != -1) {
        PropertyData.allProperties[index]['isFavorite'] = !(PropertyData.allProperties[index]['isFavorite'] ?? false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${PropertyData.allProperties[index]['isFavorite'] ? 'Added' : 'Removed'} "$title" from favorites.')),
        );
      }
    });
  }

  bool _isFavorite(String title) {
    final property = PropertyData.allProperties.firstWhere(
      (p) => p['title'] == title,
      orElse: () => {}, // Return empty map if not found
    );
    return property['isFavorite'] ?? false;
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    int crossAxisCount = 1;
    if (isLargeScreen) {
      crossAxisCount = 3;
    } else if (isMediumScreen) {
      crossAxisCount = 2;
    }

    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isLargeScreen ? 60 : (isMediumScreen ? 40 : 30),
              horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor.withOpacity(0.8), Theme.of(context).colorScheme.secondary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Results',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 48 : (isMediumScreen ? 36 : 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Properties matching your search: "${widget.searchQuery ?? ''}"',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Refine your search...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      'No properties found for your search query.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                      vertical: 20,
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 25,
                        mainAxisSpacing: 25,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final property = _searchResults[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyDetailScreen(
                                  property: property,
                                  authService: widget.authService,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                        child: Image.asset(
                                          property['images'][0],
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: IconButton(
                                          icon: Icon(
                                            _isFavorite(property['title']) ? Icons.favorite : Icons.favorite_border,
                                            color: _isFavorite(property['title']) ? Colors.red : Colors.white,
                                            size: 30,
                                          ),
                                          onPressed: () => _toggleFavorite(property['title']),
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
                                          property['title'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0A66C2),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          property['price'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E90FF),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.bed, size: 18, color: Colors.grey[600]),
                                            const SizedBox(width: 5),
                                            Text(
                                              '${property['bedrooms']} Beds',
                                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                            ),
                                            const SizedBox(width: 15),
                                            Icon(Icons.bathtub, size: 18, color: Colors.grey[600]),
                                            const SizedBox(width: 5),
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
          ),
          commonWidgets.buildFooter(),
        ],
      ),
    );
  }
}