// lib/screens/my_favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets
import 'package:sora_app/data/property_data.dart'; // Assuming you have this data source
import 'package:sora_app/screens/property_detail_screen.dart'; // For navigating to property details

class MyFavoritesScreen extends StatefulWidget {
  final AuthService authService;

  const MyFavoritesScreen({super.key, required this.authService});

  @override
  State<MyFavoritesScreen> createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends State<MyFavoritesScreen> {
  late CommonWidgets commonWidgets;
  List<Map<String, dynamic>> _favoriteProperties = [];

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    _loadFavorites();
  }

  void _loadFavorites() {
    // In a real app, you would fetch user's favorites from Firebase/backend.
    // For now, we'll filter from PropertyData based on a hypothetical 'isFavorite' flag
    // or by checking against a list of favorited titles.
    setState(() {
      _favoriteProperties = PropertyData.allProperties
          .where((property) => property['isFavorite'] == true) // Assuming 'isFavorite' is updated elsewhere
          .toList();
      // Alternatively, if you're tracking favorites by title in memory (like in PropertyListingScreen)
      // you'd need a mechanism to pass or share that state.
      // For demonstration, let's just use the dummy 'isFavorite' in property_data.dart
    });
  }

  void _removeFavorite(String title) {
    setState(() {
      // In a real app, this would update backend/user preferences
      _favoriteProperties.removeWhere((property) => property['title'] == title);
      // Also update the original PropertyData if 'isFavorite' is mutable there
      final index = PropertyData.allProperties.indexWhere((property) => property['title'] == title);
      if (index != -1) {
        PropertyData.allProperties[index]['isFavorite'] = false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed "$title" from favorites.')),
      );
    });
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
                  'My Favorites',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 48 : (isMediumScreen ? 36 : 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your saved properties for easy access.',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _favoriteProperties.isEmpty
                ? Center(
                    child: Text(
                      'You have no favorite properties yet.',
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
                      itemCount: _favoriteProperties.length,
                      itemBuilder: (context, index) {
                        final property = _favoriteProperties[index];
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
                                          icon: const Icon(
                                            Icons.favorite, // Always filled for favorites screen
                                            color: Colors.red,
                                            size: 30,
                                          ),
                                          onPressed: () => _removeFavorite(property['title']),
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