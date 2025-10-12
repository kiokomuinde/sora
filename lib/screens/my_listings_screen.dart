// lib/screens/my_listings_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sora_app/services/mpesa_service.dart';

class MyListingsScreen extends StatefulWidget {
  final AuthService authService;

  // FIX: Changed 'required this: authService' to 'required this.authService'
  const MyListingsScreen({Key? key, required this.authService}) : super(key: key);

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late CommonWidgets commonWidgets;
  final FirestoreService _firestoreService = FirestoreService();
  final MpesaService _mpesaService = MpesaService();
  String _selectedStatusFilter = 'All';

  // A set to hold the IDs of the selected listings
  Set<String> _selectedListingIds = {};

  // Data structure for the pricing plans
  final List<Map<String, dynamic>> _pricingPlans = [
    {
      'name': 'Standard Listing',
      'price': 'Ksh 2,500',
      'duration': '30 Days',
      'features': [
        'Visible on search results',
        'Basic property details',
        'Direct inquiries'
      ],
      'color': Colors.blue,
      'amount': 2500,
    },
    {
      'name': 'Featured Listing',
      'price': 'Ksh 5,000',
      'duration': '30 Days',
      'features': [
        'Higher visibility',
        'Featured on homepage',
        'Enhanced property details'
      ],
      'color': Colors.orange,
      'amount': 5000,
    },
    {
      'name': 'Premium Listing',
      'price': 'Ksh 10,000',
      'duration': '30 Days',
      'features': [
        'Top-tier visibility',
        'Social media promotion',
        'Priority support',
        'Professional photography'
      ],
      'color': Colors.purple,
      'amount': 10000,
    },
  ];

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
  }

  // Method to toggle selection of a property
  void _toggleSelection(String listingId) {
    setState(() {
      if (_selectedListingIds.contains(listingId)) {
        _selectedListingIds.remove(listingId);
      } else {
        _selectedListingIds.add(listingId);
      }
    });
  }

  // Method to clear selection when changing tabs
  void _clearSelection() {
    setState(() {
      _selectedListingIds.clear();
    });
  }

  // UPDATED: This method now handles dynamic price data types, including maps.
  String _formatPrice(dynamic price) {
    if (price == null) {
      return 'Price not listed';
    }

    if (price is String) {
      try {
        final formatter = NumberFormat('#,###', 'en_US');
        final doublePrice = double.tryParse(price);
        if (doublePrice != null) {
          return 'KSH ${formatter.format(doublePrice)}';
        }
      } catch (e) {
        // Fall through to return the raw string
      }
      return 'KSH $price';
    }

    if (price is num) {
      final formatter = NumberFormat('#,###', 'en_US');
      return 'KSH ${formatter.format(price)}';
    }

    // Handle the case where price is a map (LinkedMap)
    if (price is Map) {
      // Assuming the value is stored under a key like 'amount' or 'value'
      final dynamic priceValue = price['amount'] ?? price['value'];
      if (priceValue is num) {
        final formatter = NumberFormat('#,###', 'en_US');
        return 'KSH ${formatter.format(priceValue)}';
      }
    }

    // Fallback for any other type
    return 'KSH ${price.toString()}';
  }

  // NEW: Method to activate selected listings by updating their status in Firestore
  void _activateSelectedListings() async {
    if (_selectedListingIds.isEmpty) {
      return;
    }

    // NOTE: In a production app, the actual payment gateway (M-Pesa) logic would go here
    // before updating the status to 'Active'. For now, we simulate the activation.

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing activation..."),
            ],
          ),
        );
      },
    );

    int successfulActivations = 0;
    // For this simulation, we'll set the status to 'Active'
    for (String listingId in _selectedListingIds) {
      bool success = await _firestoreService.updatePropertyStatus(listingId, 'Active');
      if (success) {
        successfulActivations++;
      }
    }

    Navigator.of(context).pop();

    if (successfulActivations > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successfulActivations properties activated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _clearSelection();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to activate properties. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.getCurrentUser();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    if (user == null) {
      return Scaffold(
        appBar: commonWidgets.buildAppBar(),
        endDrawer: commonWidgets.buildDrawer(),
        body: commonWidgets.buildSignInPromptScreen('/my_listings'),
      );
    }

    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // START OF UPDATED ADVERT-LIKE HEADER SECTION (Blue, Gold, Purple Theme)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 80 : (isMediumScreen ? 60 : 40),
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              // Gradient: Blue, Purple, Gold
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0A66C2), // Deep Blue
                    Color(0xFF8A2BE2), // Blue Violet (Purple)
                    Color(0xFFFFD700), // Gold
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIST YOUR PROPERTY FOR FREE! 🤩', // Title updated: "LIST YOUR PROPERTY..."
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(150, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Homes, Land, Commercial—All Property Types, Zero Listing Cost. Publish Your Ad Instantly!', // Catchy tagline
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // CTA Button updated with a custom Dark Shiny Gold gradient
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      // Custom dark shiny gold gradient
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFB8860B), // Darker Gold (Goldenrod)
                          Color(0xFFFFDF00), // Lighter Gold (Bright Gold)
                          Color(0xFFDAA520), // Mid Gold (Golden Rod)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    // FIX: Wrap in DefaultTextStyle to force black text/icon color,
                    // and set button color to transparent to see the gradient.
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.black),
                      child: commonWidgets.buildCallToActionButton(
                        text: 'List Your Property NOW (It\'s FREE!)',
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_property');
                        },
                        icon: Icons.star,
                        // Set the button's background color to transparent
                        color: Colors.transparent, 
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // My Current Listings title
                   Text(
                    'My Current Listings',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 24 : (isMediumScreen ? 20 : 18),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            // END OF UPDATED ADVERT-LIKE HEADER SECTION
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                vertical: isLargeScreen ? 30 : 20,
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getPropertiesForUser(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: commonWidgets.buildEmptyState(
                        'No Listings Found',
                        'Add your first property to get started.',
                        () => Navigator.pushNamed(context, '/add_property'),
                        'Add Property',
                      ),
                    );
                  }

                  final allListings = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {'data': data, 'id': doc.id};
                  }).toList();

                  // START - UPDATED FILTERING LOGIC
                  final filteredListings = allListings.where((listing) {
                    final listingData = listing['data'] as Map<String, dynamic>;
                    final status = listingData['status'] as String? ?? 'Pending';
                    // Safely get isApproved, defaulting to false if null/missing
                    final isApproved = listingData['isApproved'] as bool? ?? false;

                    if (_selectedStatusFilter == 'All') {
                      return true;
                    } else if (_selectedStatusFilter == 'Active') {
                      return status == 'Active';
                    } else if (_selectedStatusFilter == 'Inactive') {
                      // Show inactive only if it was approved at some point
                      return status == 'Inactive' && isApproved;
                    } else if (_selectedStatusFilter == 'Ready for Activation') {
                      // Approved by admin, waiting for user payment (status is still Pending)
                      return status == 'Pending' && isApproved;
                    } else if (_selectedStatusFilter == 'Pending Review') {
                      // Created by user, waiting for admin approval
                      return status == 'Pending' && !isApproved;
                    }
                    return false;
                  }).toList();
                  // END - UPDATED FILTERING LOGIC

                  final listingsCount = filteredListings.length;

                  // START - UPDATED ACTIVATION BUTTON VISIBILITY LOGIC
                  // The button should ONLY appear if a listing is selected AND it is APPROVED but NOT YET Active
                  final shouldShowActivateButton = allListings.any((listing) {
                    final listingId = listing['id'];
                    final listingData = listing['data'] as Map<String, dynamic>;
                    final status = listingData['status'] as String? ?? 'Pending';
                    final isApproved = listingData['isApproved'] as bool? ?? false;

                    return _selectedListingIds.contains(listingId) &&
                        isApproved && // MUST be approved
                        status != 'Active'; // MUST NOT be active
                  });
                  // END - UPDATED ACTIVATION BUTTON VISIBILITY LOGIC

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusFilterTabs(),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        child: Text(
                          'Your Properties ($listingsCount)',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 24 : (isMediumScreen ? 20 : 18),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredListings.length,
                        itemBuilder: (context, index) {
                          final listing = filteredListings[index]['data'] as Map<String, dynamic>;
                          final listingId = filteredListings[index]['id'] as String;
                          final isSelected = _selectedListingIds.contains(listingId);
                          return _buildListingCard(listing, listingId, isSelected);
                        },
                      ),
                      if (shouldShowActivateButton)
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Center(
                            child: ElevatedButton.icon(
                              onPressed: () => _showPricingDialog(
                                _selectedListingIds,
                              ),
                              icon: const Icon(Icons.payment, color: Colors.white),
                              label: const Text(
                                'Activate property',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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

  // START - UPDATED STATUS FILTER TABS
  Widget _buildStatusFilterTabs() {
    final statusOptions = [
      'All',
      'Active',
      'Inactive',
      'Ready for Activation',
      'Pending Review'
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: statusOptions.map((status) {
            final isSelected = _selectedStatusFilter == status;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatusFilter = status;
                    // Clear selections when changing tabs
                    _clearSelection();
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: isSelected ? Colors.white : const Color(0xFF0A66C2),
                  backgroundColor: isSelected ? const Color(0xFF0A66C2) : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFF0A66C2)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(status),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  // END - UPDATED STATUS FILTER TABS

  // A new method to show the pricing plan dialog
  void _showPricingDialog(Set<String> listingIds) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF0A66C2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: const Text(
              'Choose Your Plan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unlock the full potential of your listings. Select a plan to activate the properties you have chosen: ${listingIds.length} properties.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (isLargeScreen)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _pricingPlans.map((plan) => Expanded(child: _buildPricingCard(plan))).toList(),
                    )
                  else
                    Column(
                      children: _pricingPlans.map((plan) => _buildPricingCard(plan)).toList(),
                    ),
                  const SizedBox(height: 24),
                  TextButton(
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Method to build a single pricing card
  Widget _buildPricingCard(Map<String, dynamic> plan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                plan['color'] as Color,
                (plan['color'] as Color).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  plan['name'] as String,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  plan['duration'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  plan['price'] as String,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (plan['features'] as List<String>).map((feature) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the pricing dialog
                    _activateSelectedListings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    'Select Plan',
                    style: TextStyle(
                      color: plan['color'] as Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Added a parameter to indicate selection status
  Widget _buildListingCard(Map<String, dynamic> listing, String listingId, bool isSelected) {
    // START - UPDATED STATUS LOGIC FOR CARD DISPLAY
    final status = listing['status'] as String? ?? 'Pending';
    final isApproved = listing['isApproved'] as bool? ?? false;

    Color statusColor;
    String displayStatus;

    if (status == 'Active') {
      statusColor = Colors.green[600]!;
      displayStatus = 'Active';
    } else if (status == 'Inactive') {
      statusColor = Colors.red[600]!;
      displayStatus = 'Inactive';
    } else if (status == 'Pending' && isApproved) {
      statusColor = Colors.blue[600]!;
      displayStatus = 'Ready to Activate'; // Approved, waiting for payment
    } else { // status == 'Pending' && !isApproved
      statusColor = Colors.orange[600]!;
      displayStatus = 'Pending Review'; // Waiting for admin
    }
    // END - UPDATED STATUS LOGIC FOR CARD DISPLAY

    String imageUrl = listing['coverImageUrl'] ?? '';

    // Safely access nested data
    final residentialDetails = listing['residentialDetails'] as Map<String, dynamic>?;

    final isActive = listing['status'] == 'Active';
    // Only allow selection if the status is NOT Active
    final canBeSelected = !isActive;

    return GestureDetector(
      onTap: () {
        if (canBeSelected) {
          _toggleSelection(listingId);
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected ? const BorderSide(color: Colors.blue, width: 3.0) : BorderSide.none,
        ),
        elevation: isSelected ? 12 : 8,
        shadowColor: isSelected ? Colors.blue.withOpacity(0.5) : Colors.black.withOpacity(0.1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
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
                              child: const Center(
                                child: Icon(Icons.house_siding, size: 50, color: Colors.grey),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue[800]?.withOpacity(0.8) ?? Colors.blue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (listing['listingType'] ?? 'N/A').toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              displayStatus, // Use the new differentiated status
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Checkmark for selected items
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.check_circle, color: Colors.blue[600], size: 24),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Row(
                        children: [
                          // NEW: "View Property" button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.green, size: 20),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/view_property',
                                  arguments: listing,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF0A66C2), size: 20),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/add_property',
                                  arguments: {
                                    'listing': listing,
                                    'listingId': listingId,
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                              onPressed: () => _showDeleteConfirmation(listing, listingId),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Checkbox for selection, only visible if canBeSelected (not Active)
                    if (canBeSelected)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              _toggleSelection(listingId);
                            },
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Colors.blue;
                                }
                                return Colors.transparent;
                              },
                            ),
                            checkColor: Colors.white,
                            shape: const CircleBorder(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                              color: Color(0xFF0A66C2),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${listing['location']?['town'] ?? 'N/A'}, ${listing['location']?['county'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (listing['propertyType'] != 'Land') ...[
                                _buildDetailRow(
                                  Icons.king_bed,
                                  residentialDetails?['bedrooms']?.toString() ?? 'N/A',
                                ),
                                const SizedBox(width: 16),
                                _buildDetailRow(
                                  Icons.bathtub,
                                  residentialDetails?['bathrooms']?.toString() ?? 'N/A',
                                ),
                                const SizedBox(width: 16),
                              ],
                              _buildDetailRow(Icons.home_work, listing['propertyType'] ?? 'N/A'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatPrice(listing['price']),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontFamily: 'Inter',
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
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0A66C2)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> listing, String listingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Delete Listing', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete "${listing['title']}"? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(context).pop();
                bool success = await _firestoreService.deleteProperty(listingId);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${listing['title']} has been deleted successfully.'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to delete listing. Please try again.'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}