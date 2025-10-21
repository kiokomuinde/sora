// lib/screens/admin_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/services/firestore_service.dart';
import 'package:intl/intl.dart';

// =========================================================================
// WIDGET: PropertyDetailsPopup (Preserved for context)
// =========================================================================

class PropertyDetailsPopup extends StatefulWidget {
  final Map<String, dynamic> listing;

  const PropertyDetailsPopup({Key? key, required this.listing}) : super(key: key);

  @override
  State<PropertyDetailsPopup> createState() => _PropertyDetailsPopupState();
}

class _PropertyDetailsPopupState extends State<PropertyDetailsPopup> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Function to move to the next image
  void _nextPage(int totalImages) {
    if (_currentPage < totalImages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // Function to move to the previous image
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
  
  // Helper to process and combine all image lists
  List<String> _getImages() {
    final String coverImageUrl = widget.listing['coverImageUrl'] ?? '';
    final List<String> additionalImageUrls = (widget.listing['imageUrls'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .where((url) => url.isNotEmpty)
        .toList() ?? [];

    List<String> images = [];
    final Set<String> uniqueUrls = {};

    if (coverImageUrl.isNotEmpty && !uniqueUrls.contains(coverImageUrl)) {
      images.add(coverImageUrl);
      uniqueUrls.add(coverImageUrl);
    }

    for (var url in additionalImageUrls) {
      if (url.isNotEmpty && !uniqueUrls.contains(url)) {
        images.add(url);
        uniqueUrls.add(url);
      }
    }

    if (images.isEmpty) {
      images.add('');
    }
    
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final images = _getImages();
    final int totalImages = images.length;

    final price = _formatPrice(widget.listing['price']);
    final location = '${widget.listing['location']?['town'] ?? 'N/A'}, ${widget.listing['location']?['county'] ?? 'N/A'}';
    final description = widget.listing['description'] ?? 'No detailed description available.';
    final title = widget.listing['title'] ?? 'Property Details';
    final status = (widget.listing['status'] ?? 'N/A').toString().toUpperCase();
    final type = widget.listing['type'] ?? 'N/A';
    final bedrooms = widget.listing['bedrooms'] ?? 'N/A';
    final bathrooms = widget.listing['bathrooms'] ?? 'N/A';
    final size = widget.listing['size'] ?? 'N/A';
    final sizeUnit = widget.listing['sizeUnit'] ?? 'sqft';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        elevation: 10,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Gradient Header
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A66C2), Color(0xFF6A1B9A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // Image Carousel (50% width)
                    Expanded(
                      flex: 5,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: totalImages,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return images[index].isEmpty
                                  ? Container(
                                      color: Colors.grey[200],
                                      child: const Center(child: Icon(Icons.no_photography, size: 80, color: Colors.grey)))
                                  : Image.network(
                                      images[index],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.red))),
                                    );
                            },
                          ),

                          if (totalImages > 1 && _currentPage > 0)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back_ios, size: 30, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    onPressed: _previousPage,
                                  ),
                                ),
                              ),
                            ),
                          
                          if (totalImages > 1 && _currentPage < totalImages - 1)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios, size: 30, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    onPressed: () => _nextPage(totalImages),
                                  ),
                                ),
                              ),
                            ),

                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...images.asMap().entries.map((entry) {
                                  return GestureDetector(
                                    onTap: () => _pageController.animateToPage(entry.key, duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
                                    child: Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(_currentPage == entry.key ? 1.0 : 0.4),
                                        border: Border.all(color: Colors.white, width: 1),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                
                                if (totalImages > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '(${_currentPage + 1}/$totalImages)',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(blurRadius: 3.0, color: Colors.black)
                                        ]
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Details Panel (50% width)
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Key Information', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF0A66C2))),
                            const Divider(height: 10),
                            _buildDetailRow(context, 'Price:', price, color: const Color(0xFF0A66C2)),
                            _buildDetailRow(context, 'Location:', location),
                            _buildDetailRow(context, 'Current Status:', status, color: _getStatusColor(status)),
                            _buildDetailRow(context, 'Property Type:', type),
                            const Divider(height: 30),
                            Text('Features', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF6A1B9A))),
                            const Divider(height: 10),
                            _buildFeatureRow(context, Icons.bed, bedrooms, 'Bedrooms'),
                            _buildFeatureRow(context, Icons.bathtub, bathrooms, 'Bathrooms'),
                            _buildFeatureRow(context, Icons.architecture, size, 'Size ($sizeUnit)'),
                            const Divider(height: 30),
                            Text(
                              'Full Description:',
                              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Text(description, style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for formatting currency
  String _formatPrice(dynamic price) {
    if (price == null) return 'Price N/A';
    if (price is num) {
      return NumberFormat.currency(locale: 'en_US', symbol: 'KSH ', decimalDigits: 0).format(price);
    }
    if (price is Map) {
      final dynamic priceValue = price['amount'] ?? price['value'];
      if (priceValue is num) {
        return NumberFormat.currency(locale: 'en_US', symbol: 'KSH ', decimalDigits: 0).format(priceValue);
      }
    }
    return 'KSH ${price.toString()}';
  }
  
  // Helper method for status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'ready': return Colors.blue;
      case 'inactive': return Colors.grey;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  // Helper method for detail rows
  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: color ?? Colors.black87, fontWeight: color != null ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for feature rows
  Widget _buildFeatureRow(BuildContext context, IconData icon, dynamic value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 8),
          Text(
            '${value.toString()} ${label.split(' ')[0]}',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// TOP-LEVEL HELPER CLASS: DataDetail (FIXED ERROR: Moved to top level)
// =========================================================================

// Custom Data Detail class for card display
class DataDetail {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color? color;
  final String? tooltip;
  
  const DataDetail({required this.label, required this.value, this.icon, this.iconColor, this.color, this.tooltip});
}


// =========================================================================
// ADMIN SCREEN MAIN IMPLEMENTATION
// =========================================================================

class AdminScreen extends StatefulWidget {
  final AuthService authService; 

  const AdminScreen({Key? key, required this.authService}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isAdmin = true; 
  int _selectedIndex = 0; 
  
  static const LinearGradient _primaryGradient = LinearGradient(
    colors: [Color(0xFF0A66C2), Color(0xFF6A1B9A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color _primaryColor = Color(0xFF0A66C2);


  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Side Navigation Rail
            NavigationRail(
              backgroundColor: Colors.grey[50],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Users'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.business_outlined),
                  selectedIcon: Icon(Icons.business),
                  label: Text('Properties'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.article_outlined),
                  selectedIcon: Icon(Icons.article),
                  label: Text('Content'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.mail_outline),
                  selectedIcon: Icon(Icons.mail),
                  label: Text('Comms'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildBodyContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Content Builder Methods ---

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardView();
      case 1:
        return _buildUserManagementView();
      case 2:
        return _buildPropertyManagementView(); 
      case 3:
        return _buildBlogManagementView();
      case 4:
        return _buildCommsView();
      default:
        return const Center(child: Text('Select a section from the navigation rail.'));
    }
  }

  // --- 0. Dashboard Overview View ---
  Widget _buildDashboardView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientHeader('Admin Dashboard Overview'),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2.5,
            children: [
              _buildStatsCard('Total Users', 'userProfiles', Icons.people_alt, Colors.blue),
              _buildStatsCard('Total Properties', 'properties', Icons.house_siding, Colors.green),
              _buildStatsCard('Total Blogs', 'blogs', Icons.article, Colors.orange),
              _buildStatsCard('Contact Messages', 'contactMessages', Icons.message, Colors.purple),
              _buildStatsCard('Subscribers', 'newsletterSubscribers', Icons.email, Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(String title, String collectionName, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.data?.docs.length ?? 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: color),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- 1. User Management View (Card View) ---
  Widget _buildUserManagementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientHeader('User Management'),
        const SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.streamUsers(), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _primaryColor));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No user profiles found.'));
              }
              
              final users = snapshot.data!.docs;
              
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final doc = users[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final userId = doc.id;
                  final isAdmin = data['isAdmin'] == true;
                  final timestamp = data['timestamp'] as Timestamp?;
                  final date = timestamp != null
                      ? DateFormat('MMM dd, yyyy').format(timestamp.toDate())
                      : 'N/A';
                  
                  return _buildDataCard(
                    context: context,
                    title: data['fullName'] ?? 'User N/A',
                    subtitle: data['email'] ?? 'Email N/A',
                    leadingIcon: Icons.person_pin,
                    details: [
                      DataDetail(label: 'Role', value: isAdmin ? 'Admin' : 'User', color: isAdmin ? Colors.deepPurple : Colors.blueGrey),
                      DataDetail(label: 'Registered', value: date, icon: Icons.calendar_today, iconColor: Colors.grey),
                    ],
                    actions: [
                      _buildDeleteButton(() => _confirmDelete('user', userId, data['email'] ?? 'User')),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  // --- 2. Property Management View (Card View) ---
  Widget _buildPropertyManagementView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200 ? 3 : (screenWidth > 800 ? 2 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientHeader('Property Management'),
        const SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.streamAllProperties(), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _primaryColor));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No properties found.'));
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.9, 
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final propertyId = doc.id;
                  return _buildPropertyCard(data, propertyId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Property Card Widget (Kept as specialized widget) ---
  Widget _buildPropertyCard(Map<String, dynamic> listing, String propertyId) {
    String _formatPrice(dynamic price) {
      if (price == null) return 'Price N/A';
      if (price is num) {
        return NumberFormat.currency(locale: 'en_US', symbol: 'KSH ', decimalDigits: 0).format(price);
      }
      if (price is Map) {
          final dynamic priceValue = price['amount'] ?? price['value'];
          if (priceValue is num) {
            return NumberFormat.currency(locale: 'en_US', symbol: 'KSH ', decimalDigits: 0).format(priceValue);
          }
      }
      return 'KSH ${price.toString()}'; 
    }

    final status = (listing['status'] as String? ?? 'pending').toLowerCase();
    String imageUrl = listing['coverImageUrl'] ?? '';
    final price = _formatPrice(listing['price']);
    final locationTown = listing['location']?['town'] ?? 'N/A';
    final locationCounty = listing['location']?['county'] ?? 'N/A';

    Color statusColor;
    String displayStatus;

    if (status == 'active') {
      statusColor = Colors.green;
      displayStatus = 'Active';
    } else if (status == 'ready') {
      statusColor = Colors.blue;
      displayStatus = 'Ready (User Activation)';
    } else if (status == 'inactive') {
      statusColor = Colors.grey;
      displayStatus = 'Inactive';
    } else if (status == 'rejected') {
      statusColor = Colors.red;
      displayStatus = 'Rejected';
    } else { // pending
      statusColor = Colors.orange;
      displayStatus = 'Pending Review';
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Positioned.fill(
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.business, size: 50, color: Colors.grey)),
                        ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayStatus,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details Section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing['title'] ?? 'No Title',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$locationTown, $locationCounty',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        price,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryColor),
                      ),
                    ],
                  ),
                  // Action Buttons Section
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _buildActionButton(
                            icon: Icons.zoom_in,
                            label: 'Details',
                            color: Colors.deepPurple,
                            onPressed: () => _showPropertyDetailsPopup(listing),
                          ),
                        ),

                        if (status == 'pending' || status == 'rejected' || status == 'inactive')
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: _buildActionButton(
                              icon: Icons.thumb_up_alt_outlined,
                              label: 'Approve',
                              color: Colors.blue,
                              onPressed: () => _handlePropertyAction(propertyId, 'ready', listing['title']),
                            ),
                          ),

                        if (status != 'active')
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: _buildActionButton(
                              icon: Icons.bolt,
                              label: 'Activate',
                              color: Colors.green,
                              onPressed: () => _handlePropertyAction(propertyId, 'active', listing['title']),
                            ),
                          ),

                        if (status == 'active' || status == 'ready')
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: _buildActionButton(
                              icon: Icons.pause_circle_outline,
                              label: 'Deactivate',
                              color: Colors.orange,
                              onPressed: () => _handlePropertyAction(propertyId, 'inactive', listing['title']),
                            ),
                          ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _buildDeleteButton(() => _confirmDelete('property', propertyId, listing['title'] ?? 'Property')),
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

  // New method to display the detailed popup
  void _showPropertyDetailsPopup(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PropertyDetailsPopup(listing: listing);
      },
    );
  }

  // New reusable button widget for status updates
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 24),
          tooltip: label,
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // New handler for property status updates
  void _handlePropertyAction(String propertyId, String newStatus, String? title) async {
    final success = await _firestoreService.updatePropertyStatus(propertyId, newStatus);
    final statusText = newStatus[0].toUpperCase() + newStatus.substring(1).toLowerCase();
    final listingTitle = title ?? propertyId.substring(0, 8);

    if (success) {
      _showSnackbar('Listing "$listingTitle" status updated to $statusText successfully.', Colors.green);
    } else {
      _showSnackbar('Failed to update listing status for "$listingTitle".', Colors.red);
    }
  }


  // --- 3. Blog Content Management View (Card View) ---
  Widget _buildBlogManagementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientHeader('Blog Content Management'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Updated Create New Blog Button with Gradient
            Container(
              decoration: BoxDecoration(
                gradient: _primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/create_blog');
                },
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: const Text('Create New Blog', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.streamAllBlogs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _primaryColor));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No blog posts found.'));
              }

              final blogs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: blogs.length,
                itemBuilder: (context, index) {
                  final doc = blogs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final blogId = doc.id;
                  final timestamp = data['timestamp'] as Timestamp?;
                  final date = timestamp != null
                      ? DateFormat('MMM dd, yyyy').format(timestamp.toDate())
                      : 'N/A';
                  final authorId = data['authorId'] ?? 'N/A';
                  
                  return _buildDataCard(
                    context: context,
                    title: data['title'] ?? 'Untitled Blog Post',
                    subtitle: 'Category: ${data['category'] ?? 'General'}',
                    leadingIcon: Icons.article,
                    details: [
                      DataDetail(label: 'Author ID', value: authorId.length > 10 ? '${authorId.substring(0, 10)}...' : authorId, tooltip: authorId),
                      DataDetail(label: 'Posted On', value: date, icon: Icons.calendar_month, iconColor: Colors.grey),
                    ],
                    actions: [
                      _buildDeleteButton(() => _confirmDelete('blog', blogId, data['title'] ?? 'Blog')),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 4. Communications View (Tabbed Card Views) ---
  Widget _buildCommsView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGradientHeader('Communications Management'),
          const SizedBox(height: 10),
          // Styled TabBar
          const TabBar(
            labelColor: _primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: _primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3.0,
            tabs: [
              Tab(text: 'Contact Messages', icon: Icon(Icons.message)),
              Tab(text: 'Newsletter Subscribers', icon: Icon(Icons.email)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: [
                _buildContactMessagesList(),
                _buildSubscribersList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Contact Messages Sub-View (Card View)
  Widget _buildContactMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getContactMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _primaryColor));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No contact messages.'));
        }

        final messages = snapshot.data!.docs;
        
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final doc = messages[index];
            final data = doc.data() as Map<String, dynamic>;
            final message = data['message'] ?? '';
            final docId = doc.id;
            final timestamp = data['timestamp'] as Timestamp?;
            final date = timestamp != null
                ? DateFormat('MMM dd, yyyy').format(timestamp.toDate())
                : 'N/A';
            
            return _buildDataCard(
              context: context,
              title: data['name'] ?? 'Anonymous Sender',
              subtitle: data['email'] ?? 'Email N/A',
              leadingIcon: Icons.mark_email_read,
              details: [
                DataDetail(
                  label: 'Snippet', 
                  value: message.length > 50 ? '${message.substring(0, 50)}...' : message, 
                  tooltip: message,
                  color: Colors.blueGrey,
                ),
                DataDetail(label: 'Date', value: date, icon: Icons.calendar_today, iconColor: Colors.grey),
              ],
              actions: [
                _buildActionButton(
                  icon: Icons.visibility,
                  label: 'View',
                  color: _primaryColor,
                  onPressed: () => _showFullMessage(data['name'] ?? 'Contact Message', message),
                ),
                _buildDeleteButton(() => _confirmDelete('contactMessage', docId, data['name'] ?? 'Message')),
              ],
            );
          },
        );
      },
    );
  }

  // Newsletter Subscribers Sub-View (Card View)
  Widget _buildSubscribersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getNewsletterSubscribers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _primaryColor));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No subscribers found.'));
        }

        final subscribers = snapshot.data!.docs;
        
        return ListView.builder(
          itemCount: subscribers.length,
          itemBuilder: (context, index) {
            final doc = subscribers[index];
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id; 
            final email = data['email'] ?? 'N/A';
            final timestamp = data['timestamp'] as Timestamp?;
            final date = timestamp != null
                ? DateFormat('MMM dd, yyyy').format(timestamp.toDate())
                : 'N/A';

            return _buildDataCard(
              context: context,
              title: email,
              subtitle: 'Newsletter Subscription',
              leadingIcon: Icons.email,
              details: [
                DataDetail(label: 'Subscribed On', value: date, icon: Icons.calendar_today, iconColor: Colors.grey),
              ],
              actions: [
                _buildDeleteButton(() => _confirmDelete('subscriber', docId, email)),
              ],
            );
          },
        );
      },
    );
  }

  // Helper to show the full contact message
  void _showFullMessage(String sender, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Message from $sender', style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // --- Utility Widgets and Methods ---
  
  // Reusable Card Widget with Gradient Border (FIXED TYPE HINT for DataDetail)
  Widget _buildDataCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData leadingIcon,
    required List<DataDetail> details, // Corrected Type
    required List<Widget> actions,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: _primaryGradient,
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(2.0), // Creates the gradient border
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(leadingIcon, size: 40, color: _primaryColor),
                  title: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  subtitle: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
                  ),
                ),
                const Divider(height: 10, color: Colors.grey),
                Wrap(
                  spacing: 20.0,
                  runSpacing: 10.0,
                  children: details.map((detail) {
                    Widget detailWidget = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (detail.icon != null) ...[
                          Icon(detail.icon, size: 16, color: detail.iconColor ?? _primaryColor),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          '${detail.label}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                        ),
                        Text(
                          detail.value,
                          style: TextStyle(fontSize: 13, color: detail.color ?? _primaryColor),
                        ),
                      ],
                    );

                    if (detail.tooltip != null) {
                      detailWidget = Tooltip(
                        message: detail.tooltip!,
                        child: detailWidget,
                      );
                    }
                    return detailWidget;
                  }).toList(),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Gradient Header
  Widget _buildGradientHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: _primaryGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildDeleteButton(VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: _buildActionButton(
        icon: Icons.delete_forever,
        label: 'Delete',
        color: Colors.red,
        onPressed: onPressed,
      ),
    );
  }
  
  void _confirmDelete(String type, String id, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete $type', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to permanently delete "$name"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(context).pop();
                bool success = false;
                
                Future<bool> simpleDelete(String collection) async {
                  try {
                    await FirebaseFirestore.instance.collection(collection).doc(id).delete();
                    return true;
                  } catch (e) {
                    print('Error deleting $collection document: $e');
                    return false;
                  }
                }

                if (type == 'user') {
                  success = await _firestoreService.deleteUserData(id);
                } else if (type == 'property') {
                  success = await _firestoreService.deleteProperty(id);
                } else if (type == 'blog') {
                  success = await _firestoreService.deleteBlog(id);
                } else if (type == 'contactMessage') {
                  success = await simpleDelete('contactMessages');
                } else if (type == 'subscriber') {
                  success = await simpleDelete('newsletterSubscribers');
                }

                if (success) {
                  // ignore: use_build_context_synchronously
                  _showSnackbar('$type "$name" deleted successfully.', Colors.green);
                } else {
                  // ignore: use_build_context_synchronously
                  _showSnackbar('Failed to delete $type. Check logs and service methods.', Colors.red);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}