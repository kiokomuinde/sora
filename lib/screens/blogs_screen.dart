// /lib/screens/blogs_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:sora_app/services/firestore_service.dart'; 
import 'package:share_plus/share_plus.dart'; // Import for sharing functionality

class BlogsScreen extends StatefulWidget {
  final AuthService authService;

  // FIX: Removed duplicate 'required' keyword
  const BlogsScreen({super.key, required this.authService});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  final TextEditingController _newsletterEmailController = TextEditingController();
  String _currentListingTypeFilter = '';
  late CommonWidgets commonWidgets;
  final FirestoreService _firestoreService = FirestoreService(); 

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
  }

  @override
  void dispose() {
    // FIX: Corrected typo from _newsletterEmailEmailController to _newsletterEmailController
    _newsletterEmailController.dispose();
    super.dispose();
  }

  // Function to handle sharing a blog post
  void _shareBlog(Map<String, dynamic> blog) {
    // Determine the unique identifier for the URL
    final blogId = blog['blogId'] ?? blog['id'];
    final blogTitle = blog['title'] ?? 'A Blog Post from Sora Properties';
    
    // Define the base domain (ensure this matches your application's domain)
    const String baseDomain = 'https://soraproperties.co.ke';

    // Construct the full URL for the blog post view
    final String shareUrl = blogId != null 
        ? '$baseDomain/#/blog_view/$blogId' 
        : '$baseDomain/#/blogs'; // Fallback URL

    // Create the final share message
    final String shareMessage = 'Check out this post: $blogTitle\n\n$shareUrl';

    // Execute the share dialog
    Share.share(
      shareMessage, 
      subject: blogTitle,
    ); 
  }
  
  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _currentListingTypeFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _currentListingTypeFilter = selected ? value : '';
          });
        },
        selectedColor: const Color(0xFF1E90FF).withOpacity(0.1),
        checkmarkColor: const Color(0xFF1E90FF),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF1E90FF) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF1E90FF) : Colors.grey[300]!,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, Map<String, dynamic> blog) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // --- SAFETY CHECK: Robustly extract image URL from potentially dynamic list ---
    final List<dynamic>? imageUrlsDynamic = blog['imageUrls'] as List<dynamic>?;
    // Map list to string safely, assuming Firestore arrays are lists of strings
    final List<String> imageUrls = imageUrlsDynamic?.map((e) => e.toString()).toList() ?? [];
    final String imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : 'https://placehold.co/600x400/E0E0E0/white?text=No+Image';
    // -------------------------------------------------------------------------------
    
    return GestureDetector(
      onTap: () {
        // Navigate to the blog view screen
        // IMPORTANT: Use the blog ID/Slug for navigation in the URL path
        final blogIdForNav = blog['blogId'] ?? blog['id']; 
        Navigator.pushNamed(
          context,
          '/blog_view/$blogIdForNav',
          arguments: blog,
        );
      },
      child: Container(
        // CRITICAL FIX: Increased horizontal margin to reduce visible card width and increase horizontal gap
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section wrapped in Stack to include the share icon
            Stack( 
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.network(
                    imageUrl,
                    // CRITICAL FIX: Increased image height to ensure it occupies the upper half of the compact card.
                    height: isMobile ? 200 : 280, 
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: isMobile ? 200 : 280,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
                    ),
                  ),
                ),
                // Share Icon positioned at the top right
                Positioned( 
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5), // Semi-transparent black background
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white, size: 20),
                      onPressed: () {
                        // Stop the gesture detector from navigating when the share button is pressed
                        _shareBlog(blog);
                      },
                      tooltip: 'Share this post',
                    ),
                  ),
                ),
              ],
            ),
            // Blog details section
            // CRITICAL FIX: Wrap Padding with Expanded to allow the inner Column to use Spacer
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog['category'] ?? 'Uncategorized',
                      style: TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 5), // Reduced spacing
                    Text(
                      blog['title'] ?? 'Untitled Blog Post',
                      style: const TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5), // Reduced spacing
                    Text(
                      blog['snippet'] ?? 'A brief snippet about the blog post content.',
                      style: TextStyle(
                        fontSize: 15, 
                        color: Colors.grey[700],
                      ),
                      maxLines: 2, // CRITICAL: Reduced max lines from 3 to 2 for smaller card height
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // CRITICAL FIX: Use Spacer to push the metadata and button to the bottom
                    const Spacer(), 

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Author/User ID (Simplified)
                        Text(
                          'By ${blog['userId'] ?? 'Sora Team'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        // Date
                        Text(
                          // Format the timestamp if it exists, otherwise use a placeholder
                          blog['timestamp'] != null
                              ? (blog['timestamp'] as Timestamp).toDate().toString().split(' ')[0]
                              : 'Date Unavailable',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // Spacing between metadata and button
                    
                    // This Align widget ensures the button is correctly positioned at the bottom right.
                    Align(
                      alignment: Alignment.bottomRight,
                      // Redesigned "Read More" button
                      child: Container(
                        decoration: BoxDecoration(
                          // Added a subtle gradient background
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E90FF), Color(0xFF0A66C2)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E90FF).withOpacity(0.4),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final blogIdForNav = blog['blogId'] ?? blog['id']; 
                            Navigator.pushNamed(
                              context,
                              '/blog_view/$blogIdForNav',
                              arguments: blog,
                            );
                          },
                          // Removed default button styling background/shadow
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // Make button background transparent
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          label: const Text(
                            'Read More',
                            style: TextStyle(
                              color: Colors.white, // White text for contrast on gradient
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures children take full width
      children: [
        // Title and Subtitle
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                'Sora Blog: Insights & Trends',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A66C2),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your source for the latest real estate market analysis, investment tips, and homeowner guides.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        // Categories/Filters
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterChip('All', ''),
                _buildFilterChip('Market Trends', 'Market Trends'),
                _buildFilterChip('Selling Tips', 'Selling Tips'),
                _buildFilterChip('Investment', 'Investment'),
                _buildFilterChip('Technology', 'Technology'),
                _buildFilterChip('Financing', 'Financing'),
                _buildFilterChip('Real Estate', 'Real Estate'),
                _buildFilterChip('Airbnb', 'Airbnb'),
              ],
            ),
          ),
        ),

        // Blog Posts Grid/List
        Padding( 
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getBlogs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                print('DEBUG: Blogs Stream is waiting...');
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print('DEBUG: Error loading blogs: ${snapshot.error}');
                return Center(child: Text('Error loading blogs: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                print('DEBUG: No blog posts found in snapshot.');
                // Use a sized box to give space to the "No blogs found" message
                return const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text('No blog posts found.'),
                ));
              }

              final allBlogs = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['blogId'] = doc.id; // Ensure the ID is present in the map
                return data;
              }).toList();
              
              print('DEBUG: Successfully loaded ${allBlogs.length} blogs.'); // Print the count
              
              final filteredBlogs = allBlogs.where((blog) {
                final category = blog['category'] ?? '';
                if (_currentListingTypeFilter.isEmpty) {
                  return true;
                }
                return category == _currentListingTypeFilter;
              }).toList();

              if (filteredBlogs.isEmpty) {
                 return Center(child: Text('No blogs found in the category: $_currentListingTypeFilter'));
              }

              return GridView.builder(
                shrinkWrap: true, // IMPORTANT: Allows GridView to size based on its children
                physics: const NeverScrollableScrollPhysics(), // IMPORTANT: Disables GridView's own scrolling
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : MediaQuery.of(context).size.width > 600 ? 2 : 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  // CRITICAL FIX: Increased aspect ratio to aggressively shorten the card height
                  childAspectRatio: MediaQuery.of(context).size.width > 900 ? 0.9 : 1.0, 
                ),
                itemCount: filteredBlogs.length,
                itemBuilder: (context, index) {
                  return _buildBlogCard(context, filteredBlogs[index]);
                },
              );
            },
          ),
        ),
        
        // Newsletter Signup
        _buildNewsletterSignup(),
        
        // Footer
        commonWidgets.buildFooter(),
      ],
    );
  }

  Widget _buildNewsletterSignup() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      color: const Color(0xFFF0F8FF), // Light background for contrast
      child: Column(
        children: [
          const Text(
            'Stay Updated',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Subscribe to our newsletter for exclusive real estate insights.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 400,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newsletterEmailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement newsletter signup logic (e.g., save to Firestore/CMS)
                    print('Subscribing: ${_newsletterEmailController.text}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Subscribe',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = widget.authService.getCurrentUser() != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.buildAppBar(),
      endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
      floatingActionButton: isLoggedIn
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E90FF),
                    Color(0xFF8A2BE2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.pushNamed(context, '/create_blog');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Create Blog',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: _buildContent(),
      ),
    );
  }
}
