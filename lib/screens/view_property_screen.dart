// lib/screens/view_property_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; 
import 'package:flutter/services.dart'; // 🎯 NEW: Required for Clipboard access
import 'dart:ui'; 
import 'dart:async'; 
import 'dart:math'; 
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sora_app/services/firestore_service.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:url_launcher/url_launcher.dart'; 

class ViewPropertyScreen extends StatefulWidget {
  final Map<String, dynamic>? propertyData; 
  final String? propertyId;
  final AuthService authService;

  const ViewPropertyScreen({
    Key? key,
    this.propertyData, 
    this.propertyId, 
    required this.authService,
  }) : super(key: key);

  @override
  State<ViewPropertyScreen> createState() => _ViewPropertyScreenState();
}

class _ViewPropertyScreenState extends State<ViewPropertyScreen> {
  late CommonWidgets commonWidgets;
  final PageController _pageController = PageController();
  final ScrollController _thumbnailScrollController = ScrollController(); 
  int _currentPage = 0;
  final ScrollController _similarPropertiesScrollController = ScrollController();
  late final FirestoreService _firestoreService;

  Map<String, dynamic>? _fetchedPropertyData;
  bool _isLoading = true; 
  bool _isFavorite = false; 
  String? _userId;
  bool _isHoveringGallery = false; 

  final Gradient _priceGradient = const LinearGradient(
    colors: [Color(0xFF0A66C2), Color(0xFF673AB7)], 
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color _lightBlueColor = Color(0xFF4FC3F7); 

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    _firestoreService = FirestoreService(); 

    _fetchPropertyData().then((_) {
      if (_fetchedPropertyData != null) {
        _checkInitialFavoriteStatus();
      }
    });

    _pageController.addListener(() {
      int next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) {
        setState(() { _currentPage = next; });
        _scrollToActiveThumbnail(next);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailScrollController.dispose();
    _similarPropertiesScrollController.dispose();
    super.dispose();
  }

  // =========================================================================
  // DATA FETCHING & LOGIC 
  // =========================================================================

  String _getListingTag(String? listingType) {
    if (listingType == null || listingType.isEmpty) return 'N/A';
    if (listingType == 'Staycation') return 'Airbnb';
    if (listingType == 'For Sale') return 'Buy';
    if (listingType.startsWith('For ')) return listingType.substring(4); 
    return listingType;
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Price not listed';
    if (price is String) {
      final doublePrice = double.tryParse(price);
      if (doublePrice != null) {
        final formatter = NumberFormat('#,###', 'en_US');
        return 'KSH ${formatter.format(doublePrice)}';
      }
      return 'KSH $price';
    }
    if (price is num) {
      final formatter = NumberFormat('#,###', 'en_US');
      return 'KSH ${formatter.format(price)}';
    }
    return 'KSH ${price.toString()}';
  }

  void _showCustomSnackBar(String message, {required bool isFavoriteAction}) {
    const Color lightBlue = Color(0xFFE3F2FD); 
    const Color deepPurple = Color(0xFF673AB7); 
    const Duration shortDuration = Duration(seconds: 2); 

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _BlinkingSnackBarContent(
          message: message,
          initialColor: lightBlue, 
          blinkColor: deepPurple, 
          initialTextColor: Colors.blue[900]!,
          blinkTextColor: Colors.white,
          isFavoriteAction: isFavoriteAction, 
        ),
        duration: shortDuration,
        backgroundColor: Colors.transparent, 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.zero, 
        elevation: 0, 
      ),
    );
  }

  Future<void> _fetchPropertyData() async {
    if (widget.propertyData != null && widget.propertyData!.isNotEmpty) {
      _fetchedPropertyData = widget.propertyData;
      _isLoading = false;
      return;
    }
    if (widget.propertyId != null && widget.propertyId!.isNotEmpty) {
      setState(() { _isLoading = true; });
      final data = await _firestoreService.getPropertyById(widget.propertyId!);
      if (mounted) {
        setState(() {
          _fetchedPropertyData = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _fetchedPropertyData = null; 
        });
      }
    }
  }

  void _checkInitialFavoriteStatus() async {
    final user = widget.authService.getCurrentUser();
    final propertyId = _fetchedPropertyData?['id']; 

    if (user == null || propertyId == null) return;
    _userId = user.uid;
    
    final isFav = await _firestoreService.isFavorite(_userId!, propertyId);
    if (mounted) setState(() { _isFavorite = isFav; });
  }

  void _toggleFavorite() async {
    final user = widget.authService.getCurrentUser();
    if (user == null) {
      commonWidgets.showLoginSignupDialog();
      return;
    }
    final propertyId = _fetchedPropertyData?['id'];
    if (propertyId == null) return; 

    _userId = user.uid;
    final newFavoriteStatus = !_isFavorite;
    
    try {
      if (newFavoriteStatus) {
        await _firestoreService.addFavorite(_userId!, propertyId);
      } else {
        await _firestoreService.removeFavorite(_userId!, propertyId);
      }
      setState(() { _isFavorite = newFavoriteStatus; });
      String message = newFavoriteStatus ? 'Property added to Favorites!' : 'Property removed from Favorites.';
      _showCustomSnackBar(message, isFavoriteAction: newFavoriteStatus); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update favorite status: $e')));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSimilarProperties() async {
    final currentProperty = _fetchedPropertyData;
    if (currentProperty == null) return [];
    
    final String? currentListingType = currentProperty['listingType'] as String?;
    final String? currentPropertyId = currentProperty['id'] as String?;

    if (currentListingType == null || currentListingType.isEmpty || currentPropertyId == null || currentPropertyId.isEmpty) {
      return [];
    }
    final allProperties = await _firestoreService.getPropertiesByListingType(currentListingType);
    return allProperties.where((property) {
      final fetchedPropertyId = property['id'] as String?;
      final fetchedListingType = property['listingType'] as String?;
      return fetchedPropertyId != null && fetchedPropertyId != currentPropertyId && fetchedListingType == currentListingType;
    }).toList();
  }
  
  void _scrollSimilarProperties(bool isForward) {
    const double cardStep = 320.0; 
    final double currentOffset = _similarPropertiesScrollController.offset;
    double newOffset = isForward ? currentOffset + cardStep : currentOffset - cardStep;

    newOffset = newOffset.clamp(
      _similarPropertiesScrollController.position.minScrollExtent, 
      _similarPropertiesScrollController.position.maxScrollExtent,
    );
    _similarPropertiesScrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // 🎯 UPDATED: Now physically copies the link to the device clipboard before sharing
  Future<void> _shareProperty() async {
    final propertyId = _fetchedPropertyData?['id']; 
    final propertyTitle = _fetchedPropertyData?['title'] ?? 'A Property from Sora Properties';
    const String baseDomain = 'https://soraproperties.co.ke';
    
    final String shareUrl = propertyId != null && propertyId.isNotEmpty ? '$baseDomain/view_property/$propertyId' : baseDomain; 
    final String shareMessage = '$propertyTitle\n\nView this property here: $shareUrl';
    
    // Actually set the URL to the clipboard
    await Clipboard.setData(ClipboardData(text: shareUrl));
    
    // Show the visual confirmation
    _showCustomSnackBar('Link copied and ready to share!', isFavoriteAction: true);

    // Trigger native share dialog
    Share.share(shareMessage, subject: propertyTitle); 
  }

  // =========================================================================
  // SMART CONTACT & LAUNCH METHODS
  // =========================================================================

  Future<void> _launchWhatsApp() async {
    final property = _fetchedPropertyData;
    if (property == null) return;

    final String title = property['title'] ?? 'a property';
    final String propId = property['id'] ?? 'Unknown ID';
    final String location = property['location']?['town'] ?? 'your listings';
    String phone = property['contactInfo']?['phone'] ?? '+254702778897';
    
    phone = phone.replaceAll(RegExp(r'\s+'), '');
    if (phone.startsWith('0')) phone = '254${phone.substring(1)}';
    if (phone.startsWith('+')) phone = phone.substring(1);

    final String message = "Hi Sora Properties, I am interested in the $title in $location (ID: $propId). Is it still available?";
    final Uri url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  Future<void> _launchCall() async {
    final property = _fetchedPropertyData;
    if (property == null) return;

    final String phone = property['contactInfo']?['phone'] ?? '+254702778897';
    final Uri url = Uri.parse("tel:$phone");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch the phone dialer.')));
    }
  }

  Future<void> _launchMaps(Map<String, dynamic> locationData) async {
    final String locality = locationData['locality'] ?? '';
    final String town = locationData['town'] ?? '';
    final String county = locationData['county'] ?? '';
    
    final String searchQuery = [locality, town, county, 'Kenya'].where((e) => e.isNotEmpty).join(', ');
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(searchQuery)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Google Maps.')));
    }
  }

  // =========================================================================
  // WORLD-CLASS PREMIUM CAROUSEL 
  // =========================================================================

  void _scrollToActiveThumbnail(int index) {
    if (!_thumbnailScrollController.hasClients) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final double targetOffset = (index * 70.0) - (screenWidth / 3); 
    _thumbnailScrollController.animateTo(
      targetOffset.clamp(0.0, _thumbnailScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollThumbnailsManually(bool isForward) {
    if (!_thumbnailScrollController.hasClients) return;
    final double currentOffset = _thumbnailScrollController.offset;
    final double offset = isForward ? currentOffset + 200 : currentOffset - 200;
    _thumbnailScrollController.animateTo(
      offset.clamp(0.0, _thumbnailScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildPremiumImageGallery(List<String> imageUrls, String listingTag) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1000;
    final double carouselHeight = isDesktop ? 550 : 380;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveringGallery = true),
      onExit: (_) => setState(() => _isHoveringGallery = false),
      child: Container(
        height: carouselHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
                ),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
                  itemBuilder: (context, index) {
                    final imgUrl = imageUrls.isEmpty ? 'assets/images/placeholder.jpg' : imageUrls[index];
                    final isNetwork = imgUrl.startsWith('http');
                    
                    return GestureDetector(
                      onTap: () => _showFullScreenGallery(imageUrls, index),
                      child: Hero(
                        tag: 'property_image_$index',
                        child: isNetwork 
                          ? Image.network(imgUrl, fit: BoxFit.cover, width: double.infinity) 
                          : Image.asset(imgUrl, fit: BoxFit.cover, width: double.infinity),
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                top: 0, left: 0, right: 0, height: 120,
                child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent]))),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0, height: 150,
                child: IgnorePointer(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.85), Colors.transparent])))),
              ),
              
              Positioned(
                top: 24, left: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.85),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text("Hot Property", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 24, right: 24,
                child: Row(
                  children: [
                    _buildGlassmorphicButton(Icons.share_outlined, Colors.white, _shareProperty),
                    const SizedBox(width: 12),
                    _buildGlassmorphicButton(_isFavorite ? Icons.favorite : Icons.favorite_border, _isFavorite ? Colors.redAccent : Colors.white, _toggleFavorite),
                  ],
                ),
              ),

              Positioned(
                bottom: 100, right: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.black.withOpacity(0.4),
                      child: Row(
                        children: [
                          const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text("${_currentPage + 1} / ${imageUrls.length}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              if (isDesktop) ...[
                AnimatedOpacity(
                  opacity: _isHoveringGallery && _currentPage > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: _buildGlassmorphicButton(Icons.arrow_back_ios_new, Colors.white, () {
                        _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
                      }),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _isHoveringGallery && _currentPage < imageUrls.length - 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: _buildGlassmorphicButton(Icons.arrow_forward_ios, Colors.white, () {
                        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
                      }),
                    ),
                  ),
                ),
              ],

              Positioned(
                bottom: 20, left: 0, right: 0,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isDesktop && imageUrls.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, left: 20.0),
                          child: _buildThumbnailArrow(Icons.chevron_left, () => _scrollThumbnailsManually(false)),
                        ),
                      
                      Flexible(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
                          ),
                          child: ListView.builder(
                            controller: _thumbnailScrollController,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              final imgUrl = imageUrls[index];
                              final isSelected = _currentPage == index;
                              final isNetwork = imgUrl.startsWith('http');
                              
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOutCubic,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: isSelected ? 80 : 55, 
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
                                    boxShadow: [if (isSelected) const BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
                                    image: DecorationImage(image: isNetwork ? NetworkImage(imgUrl) as ImageProvider : AssetImage(imgUrl), fit: BoxFit.cover),
                                  ),
                                  child: isSelected ? null : Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.black.withOpacity(0.4)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      if (isDesktop && imageUrls.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 20.0),
                          child: _buildThumbnailArrow(Icons.chevron_right, () => _scrollThumbnailsManually(true)),
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

  Widget _buildGlassmorphicButton(IconData icon, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), border: Border.all(color: Colors.white.withOpacity(0.2)), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailArrow(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), border: Border.all(color: Colors.white.withOpacity(0.2)), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  void _showFullScreenGallery(List<String> imageUrls, int initialIndex) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
        body: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
          ),
          child: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final img = imageUrls[index];
              return InteractiveViewer(
                panEnabled: true, minScale: 1, maxScale: 4,
                child: Center(child: Hero(tag: 'property_image_$index', child: img.startsWith('http') ? Image.network(img) : Image.asset(img))),
              );
            },
          ),
        ),
      ),
    ));
  }

  // =========================================================================
  // BUILD METHODS
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final property = _fetchedPropertyData;
    if (property == null) {
      return Scaffold(
        appBar: commonWidgets.buildAppBar(),
        endDrawer: commonWidgets.buildDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              const Text('Property Not Found or Invalid Link.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    
    final propertyType = property['propertyType'];
    final Map<String, dynamic> details = propertyType == 'Residential' ? property['residentialDetails'] ?? {} : propertyType == 'Vocational' ? property['airbnbDetails'] ?? {} : {};
    
    final List<String> imageUrls = [
      if (property['coverImageUrl'] != null) property['coverImageUrl'],
      ...(property['additionalImageUrls']?.cast<String>() ?? []),
    ];

    final List<Map<String, dynamic>> propertyDetails = [
      {'icon': Icons.home_work, 'label': 'Property Type', 'value': property['propertyType'] ?? 'N/A'},
      {'icon': Icons.format_size, 'label': 'Size', 'value': '${property['size'] ?? 'N/A'} ${property['sizeUnit'] ?? ''}'},
      if (propertyType == 'Residential') ...[
        {'icon': Icons.king_bed, 'label': 'Bedrooms', 'value': details['bedrooms']?.toString() ?? 'N/A'},
        {'icon': Icons.bathtub, 'label': 'Bathrooms', 'value': details['bathrooms']?.toString() ?? 'N/A'},
      ],
      if (propertyType == 'Vocational') ...[
        {'icon': Icons.people, 'label': 'Guests', 'value': details['guests']?.toString() ?? 'N/A'},
      ],
      {'icon': Icons.date_range, 'label': 'Year Built', 'value': property['yearBuilt'] ?? 'N/A'},
      {'icon': Icons.location_on, 'label': 'Location', 'value': property['location']?['town'] ?? 'N/A'},
    ];

    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: _buildStickyContactBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20), vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLargeScreen) 
                    _buildDesktopLayout(property, imageUrls, propertyDetails)
                  else 
                    _buildMobileLayout(property, imageUrls, propertyDetails),
                    
                  const SizedBox(height: 50),
                  _buildSimilarPropertiesSection(isLargeScreen, isMediumScreen),
                ],
              ),
            ),
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyContactBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _launchCall, icon: const Icon(Icons.phone), label: const Text('Call Agent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0A66C2), side: const BorderSide(color: Color(0xFF0A66C2), width: 2), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _launchWhatsApp, icon: const Icon(Icons.chat), label: const Text('WhatsApp Us', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> property, List<String> imageUrls, List<Map<String, dynamic>> propertyDetails) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(property),
              const SizedBox(height: 20),
              _buildPremiumImageGallery(imageUrls, _getListingTag(property['listingType'])),
              const SizedBox(height: 30),
              _buildPropertyHighlights(propertyDetails),
              const SizedBox(height: 30),
              _buildMainDetails(property),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildPricingCard(property),
              const SizedBox(height: 20),
              if (_getListingTag(property['listingType']) == 'Buy') ...[
                _buildMortgageEstimatorCard(property),
                const SizedBox(height: 20),
              ],
              _buildLocationCard(property), 
              const SizedBox(height: 20),
              _buildAgentTrustCard(property),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> property, List<String> imageUrls, List<Map<String, dynamic>> propertyDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(property),
        const SizedBox(height: 20),
        _buildPremiumImageGallery(imageUrls, _getListingTag(property['listingType'])),
        const SizedBox(height: 20),
        _buildPricingCard(property),
        const SizedBox(height: 20),
        if (_getListingTag(property['listingType']) == 'Buy') ...[
          _buildMortgageEstimatorCard(property),
          const SizedBox(height: 20),
        ],
        _buildPropertyHighlights(propertyDetails),
        const SizedBox(height: 30),
        _buildMainDetails(property),
        const SizedBox(height: 30),
        _buildLocationCard(property), 
        const SizedBox(height: 30),
        _buildAgentTrustCard(property),
      ],
    );
  }

  Widget _buildHeader(Map<String, dynamic> property) {
    final location = property['location'] ?? {};
    final String address = [location['locality'], location['town'], location['county']].where((e) => e != null && e.toString().isNotEmpty).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(property['title'] ?? 'N/A', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2))),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on, color: _lightBlueColor, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(address.isEmpty ? 'Location not specified' : address, style: TextStyle(fontSize: 16, color: Colors.grey[700]))),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingCard(Map<String, dynamic> property) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Price', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          ShaderMask(
            shaderCallback: (bounds) => _priceGradient.createShader(bounds),
            child: Text(_formatPrice(property['price']), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF0A66C2).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(property['status'] ?? 'Available', style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> property) {
    final location = property['location'] ?? {};
    final String address = [location['locality'], location['town'], location['county']].where((e) => e != null && e.toString().isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Explore the Area', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA), 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1), 
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on, color: Colors.redAccent, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  address.isEmpty ? 'Location available on request' : address, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), 
                  textAlign: TextAlign.center
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _launchMaps(location),
              icon: const Icon(Icons.map, size: 18),
              label: const Text('View on Google Maps'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0A66C2),
                side: const BorderSide(color: Color(0xFF0A66C2)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMortgageEstimatorCard(Map<String, dynamic> property) {
    double? propertyPrice;
    if (property['price'] is num) {
      propertyPrice = (property['price'] as num).toDouble();
    } else if (property['price'] is String) {
      propertyPrice = double.tryParse(property['price'].replaceAll(RegExp(r'[^0-9.]'), ''));
    }

    if (propertyPrice == null || propertyPrice == 0) return const SizedBox.shrink();

    double downPayment = propertyPrice * 0.20;
    double principal = propertyPrice - downPayment;
    double monthlyInterestRate = 0.12 / 12;
    int numberOfPayments = 15 * 12;
    
    double monthlyPayment = principal * (monthlyInterestRate * pow(1 + monthlyInterestRate, numberOfPayments)) / 
      (pow(1 + monthlyInterestRate, numberOfPayments) - 1);

    final formatter = NumberFormat('#,###', 'en_US');

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.calculate_outlined, color: Color(0xFF0A66C2)),
              SizedBox(width: 8),
              Text('Estimated Financing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Text('KSH ${formatter.format(monthlyPayment)} / month', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Based on 20% down, 12% interest over 15 years.', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPropertyHighlights(List<Map<String, dynamic>> propertyDetails) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Property Highlights', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 2.5,
            ),
            itemCount: propertyDetails.length,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _lightBlueColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(propertyDetails[index]['icon'], color: _lightBlueColor, size: 24)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(propertyDetails[index]['label'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        Text(propertyDetails[index]['value'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainDetails(Map<String, dynamic> property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _ExpandableDescription(text: property['description'] ?? 'No description provided.'),
        const SizedBox(height: 30),
        
        if (property['amenities'] != null && property['amenities'].isNotEmpty) ...[
          const Text('Amenities', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: (property['amenities'] as List).map((amenity) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[300]!)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF0A66C2), size: 18),
                    const SizedBox(width: 8),
                    Text(amenity.toString()),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAgentTrustCard(Map<String, dynamic> property) {
    final contactName = property['contactInfo']?['contactPerson'] ?? 'Sora Premium Agent';
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Listed By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF0A66C2).withOpacity(0.1),
                child: const Icon(Icons.person, size: 35, color: Color(0xFF0A66C2)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contactName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text('Verified Agent', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 15),
          const Text('Have a question about this property?', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _launchWhatsApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A66C2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Inquire Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarPropertiesSection(bool isLargeScreen, bool isMediumScreen) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchSimilarProperties(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        
        final similarProperties = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Similar Properties', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                if (similarProperties.length > 3)
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => _scrollSimilarProperties(false)),
                      IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 18), onPressed: () => _scrollSimilarProperties(true)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 380,
              child: ListView.builder(
                controller: _similarPropertiesScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: similarProperties.length,
                itemBuilder: (context, index) {
                  final property = similarProperties[index];
                  return Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 20, bottom: 10),
                    child: _buildSimilarPropertyCard(property),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSimilarPropertyCard(Map<String, dynamic> property) {
    final String propertyId = (property['id'] ?? '0').toString();
    final String title = (property['title'] ?? 'No Title').toString();
    final dynamic price = property['price']; 
    final String listingType = _getListingTag(property['listingType']?.toString());
    final String imageUrl = (property['coverImageUrl'] as String?) ?? 'assets/images/placeholder.jpg';
    bool isNetworkImage = imageUrl.startsWith('http');

    String displayLocation = 'Unknown Location';
    final Map<String, dynamic>? locationMap = property['location'] is Map ? property['location'] as Map<String, dynamic> : null;
    if (locationMap != null) {
      displayLocation = [locationMap['locality'], locationMap['town']].where((p) => p != null && p.toString().isNotEmpty).join(', ');
    }
    
    int bedrooms = int.tryParse(property['residentialDetails']?['bedrooms']?.toString() ?? '0') ?? 0;
    int bathrooms = int.tryParse(property['residentialDetails']?['bathrooms']?.toString() ?? '0') ?? 0;
    
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/view_property', arguments: property);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  isNetworkImage ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity) : Image.asset(imageUrl, fit: BoxFit.cover, width: double.infinity),
                  Positioned(bottom: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF0A66C2), borderRadius: BorderRadius.circular(5)), child: Text(listingType, style: const TextStyle(color: Colors.white, fontSize: 12)))),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(child: Text(displayLocation, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    if (bedrooms > 0 || bathrooms > 0)
                      Row(
                        children: [
                          if (bedrooms > 0) ...[const Icon(Icons.bed, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('$bedrooms Beds', style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(width: 10)],
                          if (bathrooms > 0) ...[const Icon(Icons.bathtub, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('$bathrooms Baths', style: const TextStyle(fontSize: 12, color: Colors.grey))],
                        ],
                      ),
                    Text(_formatPrice(price), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2))),
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

// =========================================================================
// CUSTOM WIDGETS
// =========================================================================

class _ExpandableDescription extends StatefulWidget {
  final String text;
  const _ExpandableDescription({Key? key, required this.text}) : super(key: key);

  @override
  __ExpandableDescriptionState createState() => __ExpandableDescriptionState();
}

class __ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.length < 250) {
      return Text(widget.text, style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.6));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
                stops: const [0.5, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Text(
              widget.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.6),
            ),
          ),
          secondChild: Text(
            widget.text,
            style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.6),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isExpanded ? "Read Less" : "Read More",
                style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: const Color(0xFF0A66C2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlinkingSnackBarContent extends StatefulWidget {
  final String message;
  final Color initialColor;
  final Color blinkColor;
  final Color initialTextColor;
  final Color blinkTextColor;
  final bool isFavoriteAction;

  const _BlinkingSnackBarContent({
    Key? key,
    required this.message,
    required this.initialColor,
    required this.blinkColor,
    required this.initialTextColor,
    required this.blinkTextColor,
    required this.isFavoriteAction,
  }) : super(key: key);

  @override
  _BlinkingSnackBarContentState createState() => _BlinkingSnackBarContentState();
}

class _BlinkingSnackBarContentState extends State<_BlinkingSnackBarContent> {
  late Color _currentColor;
  late Color _currentTextColor;
  late Border _currentBorder;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _toggleColorState({required bool isBlinking}) {
    setState(() {
      if (isBlinking) {
        _currentColor = widget.blinkColor;
        _currentTextColor = widget.blinkTextColor;
        _currentBorder = Border.all(color: widget.blinkColor, width: 2);
      } else {
        _currentColor = widget.initialColor;
        _currentTextColor = widget.initialTextColor;
        _currentBorder = Border.all(color: widget.initialTextColor.withOpacity(0.5), width: 1);
      }
    });
  }

  void _startAnimation() {
    if (widget.isFavoriteAction) {
      _toggleColorState(isBlinking: false);
      _blinkTimer = Timer(const Duration(milliseconds: 250), () { if (mounted) _toggleColorState(isBlinking: true); });
      _blinkTimer = Timer(const Duration(milliseconds: 750), () { if (mounted) _toggleColorState(isBlinking: false); });
      _blinkTimer = Timer(const Duration(milliseconds: 1250), () { if (mounted) _toggleColorState(isBlinking: true); });
    } else {
      _currentColor = widget.initialColor; 
      _currentTextColor = Colors.red[700]!; 
      _currentBorder = Border.all(color: Colors.red[700]!, width: 1); 
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _currentColor,
        borderRadius: BorderRadius.circular(10),
        border: _currentBorder, 
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: _currentTextColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(color: _currentTextColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}