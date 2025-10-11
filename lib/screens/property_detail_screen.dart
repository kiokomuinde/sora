// /lib/screens/property_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For PointerDeviceKind
import 'package:url_launcher/url_launcher.dart'; // For launching calls, emails, etc.
// import 'package:share_plus/share_plus.dart'; // Temporarily removed for diagnostic
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For social icons like WhatsApp

class PropertyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  const PropertyDetailScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late bool _isFavorite;
  int _currentPage = 0; 
  late PageController _pageController;
  bool _showSwipeInstruction = true;
  late ScrollController _similarPropertiesScrollController;

  // Image captions, features, etc. remain the same

  // Map of feature keys to icons
  final Map<String, IconData> _featureIcons = {
    'Year Built': Icons.calendar_today_outlined,
    'Parking': Icons.local_parking_outlined,
    'AC': Icons.ac_unit_outlined,
    'Pool': Icons.pool_outlined,
    'Security': Icons.security_outlined,
    'Fireplace': Icons.fireplace_outlined,
  };

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.property['isFavorite'] ?? false;
    _pageController = PageController();
    _similarPropertiesScrollController = ScrollController();

    // Hide the swipe instruction after a short delay
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSwipeInstruction = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _similarPropertiesScrollController.dispose();
    super.dispose();
  }

  // --- Core Logic Methods ---

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites!' : 'Removed from favorites.'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /*
  void _shareProperty() async {
    // TEMPORARILY REMOVED for diagnostic simplification
    final propertyId = widget.property['id'] ?? 'unknown';
    final title = widget.property['title'] ?? 'This Amazing Property';
    final shareLink = 'https://example.com/properties/detail?id=$propertyId';

    await Share.share(
      'Check out $title: $shareLink',
      subject: 'Property Listing: $title',
    );
  }
  */

  void _handleContactAction(String actionType, String value) async {
    String url;
    String errorMessage = 'Could not perform $actionType action.';

    switch (actionType) {
      case 'Call':
        url = 'tel:$value';
        break;
      case 'WhatsApp':
        // Note: Use https://wa.me/ for a direct link
        url = 'https://wa.me/$value';
        break;
      case 'Email':
        url = 'mailto:$value';
        break;
      case 'SMS':
        url = 'sms:$value';
        break;
      default:
        return;
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMessage Please check the agent contact details.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  
  // --- UI Builder Methods ---

  // EXTREME CENTRAL CONTACT BUTTON (Now positioned at the top of the body for guaranteed visibility)
  Widget _buildExtremeCentralContactButton(BuildContext context) {
    final agentPhone = '1234567890'; 
    final propertyPrice = widget.property['price'] ?? '\$1,200,000';

    return ElevatedButton.icon(
      onPressed: () => _handleContactAction('Call', agentPhone),
      icon: const Icon(Icons.phone, size: 20),
      label: Text(
        'Contact Agent - $propertyPrice', 
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue, 
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 10,
      ),
    );
  }

  // >>> REMOVED: _buildImageCarousel is temporarily removed for diagnostic <<<

  Widget _buildInfoChip({required String label, required String value, required IconData icon}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.lightBlue, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyOverview(Map<String, dynamic> property) {
    return Padding(
      // Added top padding to push content down past the floating button
      padding: const EdgeInsets.fromLTRB(24.0, 70.0, 24.0, 16.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property['title'] ?? 'Luxury Residential Villa',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  property['location'] ?? 'Beverly Hills, CA, USA',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Price kept here for scrolling context visibility
          Text(
            property['price'] ?? '\$1,200,000',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.lightBlue,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoChip(
                  label: 'Beds',
                  value: property['beds']?.toString() ?? '4',
                  icon: Icons.king_bed_outlined),
              _buildInfoChip(
                  label: 'Baths',
                  value: property['baths']?.toString() ?? '3',
                  icon: Icons.bathtub_outlined),
              _buildInfoChip(
                  label: 'Area',
                  value: '${property['area'] ?? 2500} ft²',
                  icon: Icons.square_foot_outlined),
              _buildInfoChip(
                  label: 'Type',
                  value: property['type'] ?? 'House',
                  icon: Icons.house_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Map<String, dynamic> property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            property['description'] ??
                'This stunning villa boasts panoramic city views and a private, gated entrance. With high-end finishes throughout, including marble floors and custom cabinetry, this property is the definition of luxury. The open-concept design seamlessly connects the indoor and outdoor living spaces, perfect for both relaxing and grand-scale entertaining. Located in a prime area with easy access to fine dining and shopping.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String feature, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.lightBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyFeaturesSection(Map<String, dynamic> property, bool isLargeScreen) {
    final features = property['features'] ??
        {
          'Year Built': '2018',
          'Parking': '3 Spaces',
          'AC': 'Central',
          'Pool': 'Private',
          'Security': 'Gated',
          'Fireplace': '2',
        };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Features',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLargeScreen ? 3 : 2,
              childAspectRatio: 3.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final featureKey = features.keys.elementAt(index);
              final featureValue = features.values.elementAt(index);
              final icon = _featureIcons[featureKey] ?? Icons.info_outline;
              return _buildFeatureCard(featureKey, featureValue.toString(), icon);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityCard(String amenity, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.lightBlue[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.lightBlue, size: 18),
          const SizedBox(width: 8),
          Text(
            amenity,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.lightBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection(Map<String, dynamic> property) {
    final amenities = (property['amenities'] as List<dynamic>?)?.cast<String>() ??
        ['School Nearby', 'Supermarket', 'Gym Access', 'Public Transport', 'Park Area', 'Hospital'];

    final amenityIcons = {
      'School Nearby': Icons.school_outlined,
      'Supermarket': Icons.shopping_cart_outlined,
      'Gym Access': Icons.fitness_center_outlined,
      'Public Transport': Icons.train_outlined,
      'Park Area': Icons.park_outlined,
      'Hospital': Icons.local_hospital_outlined,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearby Amenities',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            children: amenities
                .map((amenity) => _buildAmenityCard(amenity, amenityIcons[amenity] ?? Icons.place_outlined))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent, bool isLargeScreen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(agent['image'] ?? 'https://placehold.co/60x60/808080/FFFFFF?text=A'),
                  onBackgroundImageError: (exception, stackTrace) =>
                      const Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent['name'] ?? 'John Doe',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        agent['title'] ?? 'Listing Agent',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          Text('${agent['rating'] ?? 4.8}', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(width: 4),
                          Text('(${agent['reviews'] ?? 120} reviews)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Call
                _buildContactButton(
                  icon: Icons.phone,
                  label: 'Call',
                  color: Colors.lightBlue,
                  onTap: () => _handleContactAction('Call', agent['phone'] ?? '1234567890'),
                ),
                // WhatsApp
                _buildContactButton(
                  icon: FontAwesomeIcons.whatsapp,
                  label: 'WhatsApp',
                  color: Colors.green,
                  onTap: () => _handleContactAction('WhatsApp', agent['phone'] ?? '1234567890'),
                ),
                // Email
                _buildContactButton(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  color: Colors.redAccent,
                  onTap: () => _handleContactAction('Email', agent['email'] ?? 'agent@example.com'),
                ),
                // Message (SMS)
                _buildContactButton(
                  icon: Icons.message_outlined,
                  label: 'SMS',
                  color: Colors.deepPurple,
                  onTap: () => _handleContactAction('SMS', agent['phone'] ?? '1234567890'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(
      {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAgentsSection(bool isLargeScreen) {
    // Hardcoded multiple agents for demonstration
    final List<Map<String, dynamic>> agents = [
      {
        'name': 'Sarah Connor',
        'title': 'Senior Broker',
        'rating': 4.9,
        'reviews': 210,
        'phone': '1234567890',
        'email': 'sarah@example.com',
        'image': 'https://placehold.co/60x60/3CB371/FFFFFF?text=SC',
      },
      {
        'name': 'Michael Scott',
        'title': 'Property Specialist',
        'rating': 4.7,
        'reviews': 85,
        'phone': '0987654321',
        'email': 'michael@example.com',
        'image': 'https://placehold.co/60x60/87CEEB/FFFFFF?text=MS',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meet the Agents',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // Large Screen: Use GridView for 2-column layout
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3.5,
                  ),
                  itemCount: agents.length,
                  itemBuilder: (context, index) => _buildAgentCard(agents[index], isLargeScreen),
                );
              } else {
                // Small Screen: Use vertical Column
                return Column(
                  children: agents
                      .map((agent) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildAgentCard(agent, isLargeScreen),
                          ))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarPropertyCard(Map<String, dynamic> property) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              property['image'] ?? 'https://placehold.co/250x150/EEEEEE/333333?text=Property',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.apartment, size: 40, color: Colors.grey)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property['title'] ?? 'Modern Apartment',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property['location'] ?? 'Location N/A',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  property['price'] ?? '\$500,000',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarPropertiesSection() {
    // Hardcoded similar properties
    final List<Map<String, dynamic>> similarProperties = [
      {
        'title': 'Luxury Penthouse',
        'location': 'Downtown, NY',
        'price': '\$3,500,000',
        'image': 'https://placehold.co/250x150/6495ED/FFFFFF?text=PH',
      },
      {
        'title': 'Cozy Townhouse',
        'location': 'Suburban Area',
        'price': '\$850,000',
        'image': 'https://placehold.co/250x150/FFD700/333333?text=TH',
      },
      {
        'title': 'Waterfront Condo',
        'location': 'Miami Beach, FL',
        'price': '\$1,100,000',
        'image': 'https://placehold.co/250x150/FFA07A/FFFFFF?text=WC',
      },
      {
        'title': 'Family Home',
        'location': 'Quiet Neighborhood',
        'price': '\$720,000',
        'image': 'https://placehold.co/250x150/20B2AA/FFFFFF?text=FH',
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Similar Properties',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Scroll Left Button
              _buildScrollButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () {
                  _similarPropertiesScrollController.animateTo(
                    _similarPropertiesScrollController.offset - 200,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              ),
              Expanded(
                child: SizedBox(
                  height: 220, // Height to accommodate the card
                  child: ScrollConfiguration(
                    behavior: MyCustomScrollBehavior(),
                    child: ListView.builder(
                      controller: _similarPropertiesScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: similarProperties.length,
                      itemBuilder: (context, index) {
                        return _buildSimilarPropertyCard(similarProperties[index]);
                      },
                    ),
                  ),
                ),
              ),
              // Scroll Right Button
              _buildScrollButton(
                icon: Icons.arrow_forward_ios,
                onTap: () {
                  _similarPropertiesScrollController.animateTo(
                    _similarPropertiesScrollController.offset + 200,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.lightBlue.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.lightBlue, size: 16),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Scaffold(
      // AppBar is kept simple without actions, as the top is clipped.
      appBar: AppBar(
        title: const Text('Property Details', style: TextStyle(color: Colors.black87)), 
        backgroundColor: Colors.white,
        elevation: 1, 
      ),
      
      // Main Content is now a Stack to allow for fixed positioning of the button.
      body: Stack(
        children: [
          // 1. Scrollable Content Layer (The entire page)
          SingleChildScrollView(
            child: Padding(
              // The bottom padding ensures content doesn't get cut off.
              padding: const EdgeInsets.only(bottom: 100), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // >>> REMOVED: Image Carousel <<<
                  
                  // Main Property Overview (Title, Location, Price, Key Stats)
                  // NOTE: This function now contains a large top padding (70.0) 
                  // to avoid overlap with the fixed Contact button.
                  _buildPropertyOverview(property),
                  
                  // Description
                  _buildDescriptionSection(property),

                  // Key Features Grid
                  _buildPropertyFeaturesSection(property, false), // isLargeScreen set to false for simplicity
                  
                  // Nearby Amenities
                  _buildAmenitiesSection(property),

                  // Agent Contact Cards
                  _buildContactAgentsSection(false), // isLargeScreen set to false for simplicity

                  // Similar Properties Carousel
                  _buildSimilarPropertiesSection(),
                ],
              ),
            ),
          ),

          // 2. >>> Fixed Button Overlay Layer (FORCED TOP VISIBILITY) <<<
          Positioned(
            left: 0,
            right: 0,
            top: 10, // Positioned right under the AppBar
            child: Center(
              child: _buildExtremeCentralContactButton(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom scroll behavior to enable mouse/trackpad drag on the PageView/ListView
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
