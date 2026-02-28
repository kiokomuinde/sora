// lib/screens/view_property_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; 
import 'package:flutter/services.dart'; 
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

// 🎯 CRITICAL: SEO Package Import
import 'package:seo/seo.dart';

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

class _ViewPropertyScreenState extends State<ViewPropertyScreen> with TickerProviderStateMixin {
  late CommonWidgets commonWidgets;
  final PageController _pageController = PageController();
  final ScrollController _thumbnailScrollController = ScrollController(); 
  final ScrollController _similarPropertiesScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();
  
  late final FirestoreService _firestoreService;

  int _currentPage = 0;
  Map<String, dynamic>? _fetchedPropertyData;
  List<Map<String, dynamic>> _similarProperties = [];
  
  bool _isLoading = true; 
  bool _isLoadingSimilar = true;
  bool _isFavorite = false; 
  String? _userId;
  bool _isHoveringGallery = false; 
  
  // 🔥 NEW: State for Sticky Action Bar
  bool _showStickyActions = false;

  // Mortgage Calculator State
  double _downPaymentPercent = 20.0;
  int _loanTermYears = 15;
  double _interestRate = 12.5;

  // Animations
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    _firestoreService = FirestoreService(); 

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _fetchPropertyData().then((_) {
      if (mounted && _fetchedPropertyData != null) {
        _checkInitialFavoriteStatus();
        _fetchSimilarProperties();
        _fadeController.forward();
      }
    });

    _pageController.addListener(() {
      int next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) {
        setState(() { _currentPage = next; });
        _scrollToActiveThumbnail(next);
      }
    });

    // 🔥 NEW: Listener for the Sticky Action Bar
    _mainScrollController.addListener(() {
      if (!mounted) return;
      // When user scrolls down 400 pixels (past the image), show the sticky bar
      if (_mainScrollController.offset > 400 && !_showStickyActions) {
        setState(() { _showStickyActions = true; });
      } else if (_mainScrollController.offset <= 400 && _showStickyActions) {
        setState(() { _showStickyActions = false; });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailScrollController.dispose();
    _similarPropertiesScrollController.dispose();
    _mainScrollController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
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
    const Duration shortDuration = Duration(seconds: 3); 

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
      try {
        final data = await _firestoreService.getPropertyById(widget.propertyId!);
        if (mounted) {
          setState(() {
            _fetchedPropertyData = data;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error fetching property data: $e');
        if (mounted) setState(() => _isLoading = false);
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
    
    try {
      final isFav = await _firestoreService.isFavorite(_userId!, propertyId);
      if (mounted) setState(() { _isFavorite = isFav; });
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
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

  Future<void> _fetchSimilarProperties() async {
    setState(() { _isLoadingSimilar = true; });
    final currentProperty = _fetchedPropertyData;
    if (currentProperty == null) return;
    
    final String? currentListingType = currentProperty['listingType'] as String?;
    final String? currentPropertyId = currentProperty['id'] as String?;

    if (currentListingType == null || currentListingType.isEmpty || currentPropertyId == null || currentPropertyId.isEmpty) {
      setState(() { _isLoadingSimilar = false; });
      return;
    }
    try {
      final allProperties = await _firestoreService.getPropertiesByListingType(currentListingType);
      final similar = allProperties.where((property) {
        final fetchedPropertyId = property['id'] as String?;
        final fetchedListingType = property['listingType'] as String?;
        return fetchedPropertyId != null && fetchedPropertyId != currentPropertyId && fetchedListingType == currentListingType;
      }).toList();
      
      if (mounted) {
        setState(() {
          _similarProperties = similar.take(6).toList();
          _isLoadingSimilar = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching similar properties: $e');
      if (mounted) setState(() { _isLoadingSimilar = false; });
    }
  }
  
  void _scrollSimilarProperties(bool isForward) {
    if (!_similarPropertiesScrollController.hasClients) return;
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

  Future<void> _shareProperty() async {
    final propertyId = _fetchedPropertyData?['id']; 
    final propertyTitle = _fetchedPropertyData?['title'] ?? 'A Property from Sora Properties';
    const String baseDomain = 'https://soraproperties.co.ke';
    
    final String shareUrl = propertyId != null && propertyId.isNotEmpty ? '$baseDomain/view_property/$propertyId' : baseDomain; 
    final String shareMessage = '$propertyTitle\n\nView this property here: $shareUrl';
    
    await Clipboard.setData(ClipboardData(text: shareUrl));
    _showCustomSnackBar('Link copied and ready to share!', isFavoriteAction: true);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch the phone dialer.')));
      }
    }
  }

  Future<void> _launchEmail() async {
    final property = _fetchedPropertyData;
    if (property == null) return;

    final String email = property['contactInfo']?['email'] ?? 'info@soraproperties.co.ke';
    final String title = property['title'] ?? 'Property Inquiry';
    final Uri url = Uri.parse("mailto:$email?subject=Inquiry about $title");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Email client.')));
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Google Maps.')));
      }
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

  Widget _buildPremiumImageGallery(List<String> imageUrls, String listingTag, String propertyTitle) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1000;
    final double carouselHeight = isDesktop ? 600 : 400;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveringGallery = true),
      onExit: (_) => setState(() => _isHoveringGallery = false),
      child: Column(
        children: [
          Container(
            height: carouselHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.grey[200], 
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
                    child: imageUrls.isEmpty 
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No Images Available', style: TextStyle(color: Colors.grey, fontSize: 18)),
                            ],
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            final imgUrl = imageUrls[index];
                            final isNetwork = imgUrl.startsWith('http');
                            
                            return GestureDetector(
                              onTap: () => _showFullScreenGallery(imageUrls, index),
                              child: Hero(
                                tag: 'property_image_$index',
                                child: Seo.image(
                                  alt: '$propertyTitle - Gallery Image ${index + 1}',
                                  src: imgUrl,
                                  child: isNetwork 
                                    ? Image.network(imgUrl, fit: BoxFit.cover, width: double.infinity, 
                                        errorBuilder: (c,e,s) => const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey))) 
                                    : Image.asset(imgUrl, fit: BoxFit.cover, width: double.infinity,
                                        errorBuilder: (c,e,s) => const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey))),
                                ),
                              ),
                            );
                          },
                        ),
                  ),

                  if (imageUrls.isNotEmpty) ...[
                    Positioned(
                      top: 0, left: 0, right: 0, height: 120,
                      child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent]))),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0, height: 150,
                      child: IgnorePointer(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.85), Colors.transparent])))),
                    ),
                  ],

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
                              Text("Premium", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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

                  if (imageUrls.isNotEmpty)
                    Positioned(
                      bottom: 24, right: 24,
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

                  if (isDesktop && imageUrls.isNotEmpty) ...[
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          if (imageUrls.length > 1)
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isDesktop && imageUrls.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
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
                          return GestureDetector(
                            onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 12),
                              width: isSelected ? 100 : 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSelected ? const Color(0xFF0A66C2) : Colors.transparent, width: 3),
                                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0A66C2).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: imgUrl.startsWith('http') 
                                  ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image))
                                  : Image.asset(imgUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (isDesktop && imageUrls.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: _buildThumbnailArrow(Icons.chevron_right, () => _scrollThumbnailsManually(true)),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicButton(IconData icon, Color iconColor, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailArrow(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, color: const Color(0xFF0A66C2), size: 24),
      ),
    );
  }

  void _showFullScreenGallery(List<String> imageUrls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final url = imageUrls[index];
              return InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: 'property_image_$index',
                    child: url.startsWith('http') 
                      ? Image.network(url, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.white, size: 100)) 
                      : Image.asset(url, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.white, size: 100)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // MAIN LAYOUT BUILDERS (Desktop & Mobile)
  // =========================================================================

  Widget _buildDesktopLayout(Map<String, dynamic> property, List<String> imageUrls, String propertyTitle) {
    final String price = _formatPrice(property['price']);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPremiumImageGallery(imageUrls, _getListingTag(property['listingType']), propertyTitle),
              const SizedBox(height: 40),
              _buildHeaderInfo(property, propertyTitle, price),
              const SizedBox(height: 40),
              _buildPropertyDescription(property),
              const SizedBox(height: 40),
              _buildPropertyDetailsGrid(property),
              const SizedBox(height: 40),
              _buildAmenitiesSection(property),
              const SizedBox(height: 40),
              _buildMortgageCalculator(price),
              const SizedBox(height: 40),
              _buildMapSection(property), 
              const SizedBox(height: 40),
              _buildAgentProfileCard(property), 
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 3,
          child: _buildSidebar(property, price),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> property, List<String> imageUrls, String propertyTitle) {
    final String price = _formatPrice(property['price']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPremiumImageGallery(imageUrls, _getListingTag(property['listingType']), propertyTitle),
        const SizedBox(height: 24),
        _buildHeaderInfo(property, propertyTitle, price),
        const SizedBox(height: 30),
        _buildMobileActionRow(property),
        const SizedBox(height: 30),
        _buildPropertyDescription(property),
        const SizedBox(height: 30),
        _buildPropertyDetailsGrid(property),
        const SizedBox(height: 30),
        _buildAmenitiesSection(property),
        const SizedBox(height: 30),
        _buildMortgageCalculator(price),
        const SizedBox(height: 30),
        _buildMapSection(property), 
        const SizedBox(height: 30),
        _buildAgentProfileCard(property), 
      ],
    );
  }

  // =========================================================================
  // DETAILED SECTIONS 
  // =========================================================================

  Widget _buildHeaderInfo(Map<String, dynamic> property, String title, String price) {
    final location = property['location']?['town'] ?? 'Location not specified';
    final locality = property['location']?['locality'] ?? '';
    final fullLocation = locality.isNotEmpty ? '$locality, $location' : location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A66C2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getListingTag(property['listingType']).toUpperCase(),
                      style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Seo.text(
                    text: title,
                    style: TextTagStyle.h1,
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), height: 1.2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Seo.text(
                        text: fullLocation,
                        style: TextTagStyle.h3,
                        child: Text(
                          fullLocation,
                          style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width >= 1000)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Asking Price', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Seo.text(
                    text: price,
                    style: TextTagStyle.h2,
                    child: Text(
                      price,
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0A66C2)),
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (MediaQuery.of(context).size.width < 1000) ...[
          const SizedBox(height: 20),
          Seo.text(
            text: price,
            style: TextTagStyle.h2,
            child: Text(
              price,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0A66C2)),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildPropertyDescription(Map<String, dynamic> property) {
    final description = property['description'] ?? 'No detailed description provided for this property.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Seo.text(
          text: 'Property Description',
          style: TextTagStyle.h2,
          child: const Text('Property Description', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        ),
        const SizedBox(height: 16),
        Seo.text(
          text: description,
          style: TextTagStyle.p,
          child: Text(
            description,
            style: const TextStyle(fontSize: 16, height: 1.8, color: Color(0xFF4B5563)),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyDetailsGrid(Map<String, dynamic> property) {
    final String type = property['propertyType'] ?? 'N/A';
    Map<String, dynamic> specs = {};
    if (type == 'Residential') specs = property['residentialDetails'] ?? {};
    if (type == 'Vocational') specs = property['airbnbDetails'] ?? {};
    if (type == 'Commercial') specs = property['commercialDetails'] ?? {};
    if (type == 'Land') specs = property['landDetails'] ?? {};

    final List<Map<String, dynamic>> gridItems = [
      {'icon': Icons.home_work_outlined, 'label': 'Property Type', 'value': type},
      if (property['size'] != null) {'icon': Icons.aspect_ratio, 'label': 'Size', 'value': '${property['size']} sqft'},
      if (specs['bedrooms'] != null) {'icon': Icons.king_bed_outlined, 'label': 'Bedrooms', 'value': specs['bedrooms'].toString()},
      if (specs['bathrooms'] != null) {'icon': Icons.bathtub_outlined, 'label': 'Bathrooms', 'value': specs['bathrooms'].toString()},
      if (property['yearBuilt'] != null) {'icon': Icons.calendar_today_outlined, 'label': 'Year Built', 'value': property['yearBuilt'].toString()},
      if (property['propertyStatus'] != null) {'icon': Icons.info_outline, 'label': 'Status', 'value': property['propertyStatus']},
    ];

    if (gridItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Seo.text(
          text: 'Property Highlights',
          style: TextTagStyle.h2,
          child: const Text('Property Highlights', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: gridItems.length,
          itemBuilder: (context, index) {
            final item = gridItems[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF0A66C2).withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(item['icon'] as IconData, color: const Color(0xFF0A66C2), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item['label'] as String, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(item['value'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(Map<String, dynamic> property) {
    final List<dynamic> amenities = property['amenities'] ?? [];
    if (amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Seo.text(
          text: 'Premium Amenities',
          style: TextTagStyle.h2,
          child: const Text('Premium Amenities', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: amenities.map((amenity) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF0A66C2), size: 20),
                  const SizedBox(width: 10),
                  Seo.text(
                    text: amenity.toString(),
                    style: TextTagStyle.p,
                    child: Text(amenity.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMortgageCalculator(String priceString) {
    final listingType = _fetchedPropertyData?['listingType'] ?? '';
    if (listingType != 'For Sale') return const SizedBox.shrink();

    double basePrice = 0.0;
    try {
      basePrice = double.parse(priceString.replaceAll(RegExp(r'[^0-9.]'), ''));
    } catch (e) {
      return const SizedBox.shrink();
    }

    final double downPaymentAmount = basePrice * (_downPaymentPercent / 100);
    final double principal = basePrice - downPaymentAmount;
    final double monthlyInterestRate = (_interestRate / 100) / 12;
    final int numberOfPayments = _loanTermYears * 12;
    
    double monthlyPayment = 0.0;
    if (monthlyInterestRate > 0) {
      monthlyPayment = principal * (monthlyInterestRate * pow(1 + monthlyInterestRate, numberOfPayments)) / (pow(1 + monthlyInterestRate, numberOfPayments) - 1);
    } else {
      monthlyPayment = principal / numberOfPayments;
    }

    final formatter = NumberFormat('#,###', 'en_US');

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.calculate_outlined, color: Colors.green, size: 28),
              ),
              const SizedBox(width: 16),
              Seo.text(
                text: 'Estimated Mortgage Calculator',
                style: TextTagStyle.h2,
                child: const Text('Mortgage Calculator', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildSliderRow('Down Payment', '${_downPaymentPercent.toInt()}%', _downPaymentPercent, 0, 100, (val) => setState(() => _downPaymentPercent = val)),
                    const SizedBox(height: 20),
                    _buildSliderRow('Interest Rate', '${_interestRate.toStringAsFixed(1)}%', _interestRate, 1, 20, (val) => setState(() => _interestRate = val)),
                    const SizedBox(height: 20),
                    _buildSliderRow('Loan Term', '$_loanTermYears Years', _loanTermYears.toDouble(), 5, 30, (val) => setState(() => _loanTermYears = val.toInt())),
                  ],
                ),
              ),
              if (MediaQuery.of(context).size.width >= 800) const SizedBox(width: 40),
              if (MediaQuery.of(context).size.width >= 800)
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0A66C2), Color(0xFF1E3A8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Estimated Monthly Payment', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 12),
                        Text('KSH ${formatter.format(monthlyPayment.toInt())}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 24),
                        _buildMortgageDetailRow('Principal Loan', 'KSH ${formatter.format(principal.toInt())}'),
                        const SizedBox(height: 12),
                        _buildMortgageDetailRow('Down Payment', 'KSH ${formatter.format(downPaymentAmount.toInt())}'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (MediaQuery.of(context).size.width < 800) ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0A66C2), Color(0xFF1E3A8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Estimated Monthly Payment', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('KSH ${formatter.format(monthlyPayment.toInt())}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, String value, double sliderValue, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A66C2))),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF0A66C2),
            inactiveTrackColor: Colors.grey.withOpacity(0.2),
            thumbColor: Colors.white,
            trackHeight: 6.0,
          ),
          child: Slider(value: sliderValue, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildMortgageDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMapSection(Map<String, dynamic> property) {
    final locationData = property['location'] as Map<String, dynamic>?;
    if (locationData == null) return const SizedBox.shrink();

    final locationString = '${locationData['locality'] ?? ''}, ${locationData['town'] ?? ''}'.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Seo.text(
          text: 'Location & Map',
          style: TextTagStyle.h2,
          child: const Text('Location & Map', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        ),
        const SizedBox(height: 20),
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            color: const Color(0xFFE5E7EB), 
          ),
          child: Stack(
            children: [
              Center(
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 60),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(20), 
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
                        ),
                        child: Text(locationString, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20, right: 20,
                child: ElevatedButton.icon(
                  onPressed: () => _launchMaps(locationData),
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text('Get Directions', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A66C2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgentProfileCard(Map<String, dynamic> property) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Listed By Agent', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.person, size: 40, color: Color(0xFF0A66C2)), 
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Seo.text(
                      text: 'Sora Properties Official Agent',
                      style: TextTagStyle.h3,
                      child: const Text('Sora Properties Agent', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                    ),
                    const SizedBox(height: 4),
                    const Text('Premium Real Estate Expert', style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        const Text('(120+ Reviews)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: Seo.link(
                  href: 'tel:+254702778897',
                  anchor: 'Call Agent',
                  child: ElevatedButton.icon(
                    onPressed: _launchCall,
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: const Text('Call Now', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A66C2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Seo.link(
                  href: 'https://wa.me/254702778897',
                  anchor: 'WhatsApp Agent',
                  child: OutlinedButton.icon(
                    onPressed: _launchWhatsApp,
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                    label: const Text('WhatsApp', style: TextStyle(color: Colors.green)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // =========================================================================
  // FIXED SIDEBAR (Desktop) & MOBILE ACTION ROW
  // =========================================================================

  Widget _buildSidebar(Map<String, dynamic> property, String price) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Asking Price', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0A66C2))),
          const SizedBox(height: 30),
          
          _buildSidebarActionButton(Icons.phone, 'Call Agent', const Color(0xFF0A66C2), Colors.white, _launchCall),
          const SizedBox(height: 16),
          _buildSidebarActionButton(Icons.chat, 'WhatsApp Us', Colors.green, Colors.white, _launchWhatsApp),
          const SizedBox(height: 16),
          _buildSidebarActionButton(Icons.email_outlined, 'Send Email', Colors.white, const Color(0xFF1F2937), _launchEmail, isOutlined: true),
          
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          const Text('Safety Tips:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildSafetyTip('Do not pay before viewing.'),
          _buildSafetyTip('Verify the agent\'s identity.'),
          _buildSafetyTip('Meet in a public location.'),
        ],
      ),
    );
  }

  Widget _buildSidebarActionButton(IconData icon, String label, Color bgColor, Color textColor, VoidCallback onTap, {bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: textColor),
              label: Text(label, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: textColor),
              label: Text(label, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
    );
  }

  Widget _buildSafetyTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildMobileActionRow(Map<String, dynamic> property) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _launchCall,
                  icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                  label: const Text('Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A66C2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _launchWhatsApp,
                  icon: const Icon(Icons.chat, color: Colors.white, size: 20),
                  label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _launchEmail,
              icon: const Icon(Icons.email_outlined, color: Color(0xFF4B5563)),
              label: const Text('Email Agent', style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // =========================================================================
  // SIMILAR PROPERTIES SECTION
  // =========================================================================

  Widget _buildSimilarPropertiesSection() {
    if (_isLoadingSimilar) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_similarProperties.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Seo.text(
          text: 'Similar Properties You May Like',
          style: TextTagStyle.h2,
          child: const Text('Similar Properties', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 380,
          child: Stack(
            children: [
              ListView.builder(
                controller: _similarPropertiesScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _similarProperties.length,
                itemBuilder: (context, index) {
                  final prop = _similarProperties[index];
                  return Seo.link(
                    href: 'https://soraproperties.co.ke/view_property/${prop['id']}',
                    anchor: prop['title'] ?? 'View Property',
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SizedBox(
                        width: 300,
                        child: _buildSimplePropertyCard(prop),
                      ),
                    ),
                  );
                },
              ),
              if (MediaQuery.of(context).size.width >= 1000) ...[
                Positioned(
                  left: 0, top: 150,
                  child: _buildThumbnailArrow(Icons.chevron_left, () => _scrollSimilarProperties(false)),
                ),
                Positioned(
                  right: 0, top: 150,
                  child: _buildThumbnailArrow(Icons.chevron_right, () => _scrollSimilarProperties(true)),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimplePropertyCard(Map<String, dynamic> prop) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewPropertyScreen(propertyId: prop['id'], authService: widget.authService)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: prop['coverImageUrl'] != null 
                ? Image.network(
                    prop['coverImageUrl'],
                    height: 200, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (c,e,s) => Container(height: 200, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                  )
                : Container(height: 200, color: Colors.grey[200], child: const Icon(Icons.home, color: Colors.grey, size: 50)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatPrice(prop['price']), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A66C2))),
                  const SizedBox(height: 8),
                  Text(prop['title'] ?? 'Property', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(prop['location']?['town'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey))),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 🔥 NEW: STICKY TOP ACTION BAR BUILDER
  // =========================================================================

  Widget _buildStickyTopActionBar(String price, String title, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: isDesktop ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
            children: [
              if (isDesktop) 
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFF0A66C2).withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.home, color: Color(0xFF0A66C2), size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(price, style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Seo.link(
                    href: 'tel:+254702778897',
                    anchor: 'Call Agent Sticky',
                    child: ElevatedButton.icon(
                      onPressed: _launchCall,
                      icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                      label: const Text('Call Now', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A66C2),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Seo.link(
                    href: 'https://wa.me/254702778897',
                    anchor: 'WhatsApp Agent Sticky',
                    child: ElevatedButton.icon(
                      onPressed: _launchWhatsApp,
                      icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                      label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // MAIN BUILD - SEO HEAD WRAPPER
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: commonWidgets.buildAppBar(),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF0A66C2))),
      );
    }

    if (_fetchedPropertyData == null) {
      return Scaffold(
        appBar: commonWidgets.buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Seo.text(text: 'Property Not Found', style: TextTagStyle.h1, child: const Text('Property Not Found', style: TextStyle(fontSize: 24))),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/home'),
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      );
    }

    final property = _fetchedPropertyData!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;
    
    final propertyTitle = property['title'] ?? 'Luxury Property in Kenya';
    final propertyDesc = property['description'] ?? 'View this exclusive property listing managed by Sora Properties. Contact our agent today to schedule a viewing.';
    final propertyUrl = property['id'] != null ? 'https://soraproperties.co.ke/view_property/${property['id']}' : 'https://soraproperties.co.ke';
    final coverImage = property['coverImageUrl'] ?? 'https://soraproperties.co.ke/assets/images/sora_logo.png';
    final locationName = property['location']?['town'] ?? 'Kenya';
    final price = _formatPrice(property['price']);

    final List<String> imageUrls = [
      if (property['coverImageUrl'] != null) property['coverImageUrl'],
      ...(property['additionalImageUrls']?.cast<String>() ?? []),
    ];

    return Seo.head(
      tags: [
        MetaTag(name: 'title', content: '$propertyTitle | Sora Properties'),
        MetaTag(name: 'description', content: propertyDesc),
        MetaTag(name: 'keywords', content: 'Real Estate, $locationName, Buy, Rent, Airbnb, Sora Properties, Kenya, Premium Property'),
        MetaTag(name: 'og:title', content: propertyTitle),
        MetaTag(name: 'og:description', content: propertyDesc),
        MetaTag(name: 'og:image', content: coverImage),
        MetaTag(name: 'og:url', content: propertyUrl),
        MetaTag(name: 'og:type', content: 'product'),
        MetaTag(name: 'twitter:card', content: 'summary_large_image'),
        MetaTag(name: 'twitter:title', content: propertyTitle),
        MetaTag(name: 'twitter:description', content: propertyDesc),
        MetaTag(name: 'twitter:image', content: coverImage),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: commonWidgets.buildAppBar(),
        endDrawer: commonWidgets.buildDrawer(),
        // 🔥 FIXED: Wrapped Body in a Stack to support the Sticky Action Overlay
        body: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                controller: _mainScrollController,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 1400), 
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 60 : 20, 
                        vertical: isDesktop ? 40 : 20
                      ),
                      child: Column(
                        children: [
                          isDesktop 
                              ? _buildDesktopLayout(property, imageUrls, propertyTitle)
                              : _buildMobileLayout(property, imageUrls, propertyTitle),
                          
                          const SizedBox(height: 60),
                          const Divider(),
                          const SizedBox(height: 40),
                          
                          _buildSimilarPropertiesSection(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    commonWidgets.buildFooter(),
                  ],
                ),
              ),
            ),
            
            // 🔥 NEW: The Smooth Sliding Sticky Action Bar Overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: _showStickyActions ? 0 : -100, // Slides out of view when false
              left: 0,
              right: 0,
              child: _buildStickyTopActionBar(price, propertyTitle, isDesktop),
            ),
          ],
        ),
      ),
    );
  }
}

// SnackBar helper 
class _BlinkingSnackBarContent extends StatefulWidget {
  final String message;
  final Color initialColor;
  final Color blinkColor;
  final Color initialTextColor;
  final Color blinkTextColor;
  final bool isFavoriteAction;

  const _BlinkingSnackBarContent({
    required this.message,
    required this.initialColor,
    required this.blinkColor,
    required this.initialTextColor,
    required this.blinkTextColor,
    required this.isFavoriteAction,
  });

  @override
  State<_BlinkingSnackBarContent> createState() => _BlinkingSnackBarContentState();
}

class _BlinkingSnackBarContentState extends State<_BlinkingSnackBarContent> {
  Timer? _blinkTimer;
  late Color _currentColor;
  late Color _currentTextColor;
  late Border _currentBorder;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _currentTextColor = widget.initialTextColor;
    _currentBorder = Border.all(color: Colors.transparent);
    _startBlinking();
  }

  void _toggleColorState({required bool isBlinking}) {
    if (!mounted) return;
    setState(() {
      if (isBlinking) {
        _currentColor = widget.blinkColor;
        _currentTextColor = widget.blinkTextColor;
      } else {
        _currentColor = widget.initialColor;
        _currentTextColor = widget.initialTextColor;
      }
    });
  }

  void _startBlinking() {
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
              style: TextStyle(color: _currentTextColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}