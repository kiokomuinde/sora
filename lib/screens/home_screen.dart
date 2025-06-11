// /lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sora_app/screens/property_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _featuredScrollController;
  late ScrollController _trendingScrollController;
  late ScrollController _recommendedScrollController;

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> allProperties = const [
    {
      "title": "5-Bedroom Mansion - Ongata Rongai",
      "price": "KSH 20,000,000",
      "location": "Olekasasi, Ongata Rongai",
      "images": [
        "assets/images/image1.jpeg",
        "assets/images/image1_1.webp",
        "assets/images/image1_2.webp",
        "assets/images/image1_3.webp",
        "assets/images/image1_4.webp",
        "assets/images/image1_5.webp"
      ],
      "bedrooms": 3,
      "bathrooms": 2,
      "area": "2000",
      "type": "Mansion",
      "listingType": "Buy",
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
      "listingType": "Rent",
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
      "listingType": "Buy",
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
      "listingType": "Buy",
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
      "listingType": "Rent",
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
      "listingType": "Lease",
      "description":
          "Spacious office space available for rent in Westlands, Nairobi. Ideal for businesses looking for central location.",
      "isFavorite": true,
    },
  ];


  @override
  void initState() {
    super.initState();
    _featuredScrollController = ScrollController();
    _trendingScrollController = ScrollController();
    _recommendedScrollController = ScrollController();
  }

  @override
  void dispose() {
    _featuredScrollController.dispose();
    _trendingScrollController.dispose();
    _recommendedScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/sora_logo.png',
              height: 70,
            ),
            const SizedBox(width: 0),
            const Text(
              "SORA",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: const [],
        backgroundColor: const Color(0xFF1E90FF),
        elevation: 0,
        toolbarHeight: 70,
        centerTitle: false,
        titleSpacing: 0.0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 40.0),
        children: [
          _buildGreetingAndSearchBar(context),
          const SizedBox(height: 30),
          _buildSectionHeader("Quick Actions"),
          const SizedBox(height: 15),
          _buildQuickActionsGrid(context),
          const SizedBox(height: 30),
          _buildSectionHeader("Featured Properties"),
          const SizedBox(height: 15),
          _buildCarouselWithNavigation(context, allProperties, _featuredScrollController),
          const SizedBox(height: 30),
          _buildSectionHeader("Trending This Week"),
          const SizedBox(height: 15),
          _buildCarouselWithNavigation(context, allProperties, _trendingScrollController),
          const SizedBox(height: 30),
          _buildSectionHeader("Recommended for You"),
          const SizedBox(height: 15),
          _buildCarouselWithNavigation(context, allProperties, _recommendedScrollController),
        ],
      ),
    );
  }

  Widget _buildGreetingAndSearchBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hi, User!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Find your dream home today.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search properties, locations...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                onSubmitted: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching for: ${value}')),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E90FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching for: ${_searchController.text}')),
                  );
                },
                padding: const EdgeInsets.all(18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickActionCard(context, "Buy", Icons.shopping_bag_outlined, const Color(0xFF1E90FF), '/property_listings'),
        _buildQuickActionCard(context, "Rent", Icons.house_outlined, Colors.orange, '/property_listings'),
        _buildQuickActionCard(context, "Lease", Icons.vpn_key_outlined, Colors.purple, '/lease_info'),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (route == '/property_listings') {
            Navigator.pushNamed(context, route, arguments: {'filter': title});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title action tapped!')),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselWithNavigation(BuildContext context, List<Map<String, dynamic>> properties, ScrollController controller) {
    const double _scrollAmount = 265.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 280,
          child: ListView.builder(
            controller: controller,
            scrollDirection: Axis.horizontal,
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return _buildPropertyCard(context, property);
            },
          ),
        ),
        if (kIsWeb)
          Positioned(
            left: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
                onPressed: () {
                  if (controller.hasClients) {
                    double currentOffset = controller.offset;
                    double newOffset = currentOffset - _scrollAmount;
                    if (newOffset < 0) newOffset = 0;

                    controller.animateTo(
                      newOffset,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),
          ),
        if (kIsWeb)
          Positioned(
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
                onPressed: () {
                  if (controller.hasClients) {
                    double currentOffset = controller.offset;
                    double maxScrollExtent = controller.position.maxScrollExtent;
                    double newOffset = currentOffset + _scrollAmount;
                    if (newOffset > maxScrollExtent) newOffset = maxScrollExtent;

                    controller.animateTo(
                      newOffset,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, Map<String, dynamic> property) {
    return StatefulBuilder(
      builder: (context, setState) {
        double scale = 1.0;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetailScreen(property: property),
              ),
            );
          },
          onHover: (hovered) {
            if (kIsWeb) {
              setState(() {
                scale = hovered ? 1.15 : 1.0;
              });
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
            margin: const EdgeInsets.only(right: 15, bottom: 10),
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AnimatedScale(
                        scale: scale,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Image.asset(
                          property['images'][0],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            property['price'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Icon(
                          property['isFavorite'] ?? false ? Icons.favorite : Icons.favorite_border,
                          color: property['isFavorite'] ?? false ? Colors.redAccent : Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4), // Spacing for the new text
                        Text(
                          '${property['type']} - ${property['listingType']}', // Displaying both type and listingType
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                property['location'],
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}