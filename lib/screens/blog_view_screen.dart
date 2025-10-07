// lib/screens/blog_view_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart'; 
import 'dart:ui'; // Import for BackdropFilter

class BlogViewScreen extends StatefulWidget {
  final Map<String, dynamic>? blogPost; 
  final AuthService authService;
  final String? blogSlug; 

  const BlogViewScreen({
    super.key,
    this.blogPost, 
    required this.authService,
    this.blogSlug, 
  });

  @override
  State<BlogViewScreen> createState() => _BlogViewScreenState();
}

class _BlogViewScreenState extends State<BlogViewScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late CommonWidgets commonWidgets;
  
  Map<String, dynamic>? _currentBlogPost;
  late Future<void> _loadBlogFuture;

  final List<String> _categories = [
    'Market Trends', 'Selling Tips', 'Investment', 'Technology', 
    'Financing', 'Real Estate', 'Airbnb'
  ];

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService); 
    _loadBlogFuture = _fetchBlogData();
  }

  /// Fetches blog data based on provided blogPost or blogSlug.
  Future<void> _fetchBlogData() async {
    if (widget.blogPost != null && widget.blogPost!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _currentBlogPost = widget.blogPost;
        });
      }
      return;
    }

    if (widget.blogSlug != null) {
      final fetchedBlog = await _firestoreService.getBlogBySlugOrId(widget.blogSlug!);
      if (mounted) {
        setState(() {
          _currentBlogPost = fetchedBlog;
        });
      }
      return;
    }
    
    if (mounted) {
       setState(() {
         _currentBlogPost = {}; 
       });
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate().toString().split(' ')[0];
    }
    return 'Date Unavailable';
  }

  // --- SHARING METHOD ---
  void _shareBlog() {
    // 1. Get the blog ID and Title
    final blogId = widget.blogSlug ?? _currentBlogPost?['blogId'] ?? _currentBlogPost?['id'];
    final blogTitle = _currentBlogPost?['title'] ?? 'A New Blog Post from Sora Properties';
    
    // 2. Define the base URL using your domain
    const String baseDomain = 'https://soraproperties.co.ke';

    // 3. Construct the full URL for the blog post
    final String shareUrl = blogId != null 
        ? '$baseDomain/#/blog_view/$blogId' 
        : '$baseDomain/#/'; 

    // 4. Create the final share message with line breaks (\n)
    final String shareMessage = '$blogTitle\n\nRead more here: $shareUrl';

    // 5. Execute the share dialog
    Share.share(
      shareMessage, 
      subject: blogTitle,
    ); 
  }
  // ----------------------

  Widget _buildSubtopic(Map<String, dynamic> subtopic, {String? imageUrl}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            subtopic['title'] ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E90FF),
            ),
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: isMobile ? 180 : 250,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: isMobile ? 180 : 250,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: isMobile ? 180 : 250,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.error, color: Colors.red)),
                    );
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            subtopic['body'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display related topics
  Widget _buildRelatedTopics(String currentBlogId, String currentBlogCategory) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      // Call with correct positional arguments
      future: _firestoreService.getRelatedBlogs(currentBlogCategory, currentBlogId, limit: 3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // This displays the index error if the index is not yet built
          return Text(
            'Error loading related topics: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final relatedBlogs = snapshot.data;

        if (relatedBlogs == null || relatedBlogs.isEmpty) {
          return const Center(child: Text('No other related blog topics found.'));
        }
        
        return Column(
          children: relatedBlogs.map((blog) {
            return _buildRelatedBlogCard(context, blog);
          }).toList(),
        );
      },
    );
  }

  // Helper for related blog card and navigation
  Widget _buildRelatedBlogCard(BuildContext context, Map<String, dynamic> blog) {
    final String imageUrl = blog['imageUrls']?.isNotEmpty == true ? blog['imageUrls'][0] : 'https://placehold.co/600x400/E0E0E0/white?text=No+Image';
    
    // Use 'blogId' key
    final String blogIdForNav = (blog['blogId'] ?? '') as String; 

    return GestureDetector(
      onTap: () {
        // Navigate to the new blog post
        Navigator.pushNamed(
          context,
          '/blog_view/$blogIdForNav', 
          arguments: blog, 
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatDate(blog['timestamp']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightColumn() {
    // Robustly find the ID (either 'blogId' from fetch or 'id' from passed argument)
    final rawId = _currentBlogPost?['blogId'] ?? _currentBlogPost?['id'];
    final rawCategory = _currentBlogPost?['category'];

    final currentBlogId = (rawId is String && rawId.isNotEmpty) ? rawId : null; 
    final currentBlogCategory = (rawCategory is String && rawCategory.isNotEmpty) ? rawCategory : null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: ListView( 
        children: [
          const Text(
            'Related Topics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E90FF),
            ),
          ),
          const SizedBox(height: 20),
          if (currentBlogId != null && currentBlogCategory != null)
            _buildRelatedTopics(currentBlogId, currentBlogCategory)
          else
            const Text('Related topics unavailable until blog data is loaded or if blog is missing ID/category.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- UPDATED LEFT COLUMN WITH LIGHTER GRADIENT AND BOLDER TEXT ---
  Widget _buildLeftColumn() {
    // Define the colors used in the middle column for consistency
    const Color darkBlueTitle = Color(0xFF0A66C2);
    const Color primaryBlue = Color(0xFF1E90FF);
    
    // Define new colors for the gradient
    const Color deepPurple = Color(0xFF8A2BE2);
    const Color lightBlue = Color(0xFF87CEEB); 
    const Color lightPurple = Color(0xFFDDA0DD); 

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getBlogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No blogs available.'));
        }

        final blogs = snapshot.data!.docs;
        final Map<String, int> categoryCounts = {};
        for (var blog in blogs) {
          final data = blog.data() as Map<String, dynamic>;
          final category = data['category'] ?? 'Uncategorized';
          categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
        }
        
        // Wrap content in Padding, ClipRRect, and BackdropFilter for the effect
        return Padding( 
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20), // Rounded corners
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // Blur remains the same
              child: Container(
                // Use a much lighter transparent gradient for the background
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryBlue.withOpacity(0.1),    // Blue - Reduced opacity
                      deepPurple.withOpacity(0.1),     // Purple - Reduced opacity
                      lightBlue.withOpacity(0.1),      // Light Blue - Reduced opacity
                      lightPurple.withOpacity(0.1),    // Light Purple - Reduced opacity
                      Colors.white.withOpacity(0.05),  // White - Reduced opacity
                    ],
                    stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  // White border for definition
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6), 
                    width: 1.5,
                  ),
                  // Subtle shadow
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), // Lighter shadow
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blog Categories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900, // <-- VERY BOLD
                        color: darkBlueTitle, 
                        // Text shadow for clarity
                        shadows: [
                          Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 5, offset: Offset(1, 1)) 
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: _categories.map((category) {
                          final count = categoryCounts[category] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              '$category ($count)',
                              style: const TextStyle(
                                fontSize: 16,
                                color: primaryBlue, 
                                fontWeight: FontWeight.w700, // <-- BOLD
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  // ----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadBlogFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_currentBlogPost == null || _currentBlogPost!.isEmpty) {
            return Scaffold( 
            appBar: commonWidgets.buildAppBar(),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Blog post not found or data is missing.', style: TextStyle(fontSize: 18, color: Colors.red)),
              ),
            ),
          );
        }

        final currentBlogPost = _currentBlogPost!;
        final screenWidth = MediaQuery.of(context).size.width;
        final bool isLargeScreen = screenWidth >= 1000;
        final bool isLoggedIn = widget.authService.getCurrentUser() != null;
        final List<String> imageUrls = currentBlogPost['imageUrls']?.cast<String>() ?? [];
        final List<Map<String, dynamic>> subtopics = currentBlogPost['subtopics']?.cast<Map<String, dynamic>>() ?? [];

        final blogContent = SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SHARE ICON PLACEMENT ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Color(0xFF1E90FF), size: 30),
                        onPressed: _shareBlog, // Calls the method with the specific format
                        tooltip: 'Share this post',
                      ),
                    ),
                    // ----------------------------
                    Text(
                      currentBlogPost['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'By ${currentBlogPost['userId'] ?? 'Sora Team'} on ${_formatDate(currentBlogPost['timestamp'])}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      currentBlogPost['snippet'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentBlogPost['introduction'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ...subtopics.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final Map<String, dynamic> subtopic = entry.value;
                      final String? imageUrl = index < imageUrls.length ? imageUrls[index] : null;
                      return _buildSubtopic(subtopic, imageUrl: imageUrl);
                    }).toList(),
                    const SizedBox(height: 30),
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E90FF),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentBlogPost['summary'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              commonWidgets.buildFooter(), 
            ],
          ),
        );

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
          body: Row(
            children: [
              if (isLargeScreen)
                Expanded(
                  flex: 1,
                  child: _buildLeftColumn(),
                ),
              Expanded(
                flex: 2,
                child: blogContent,
              ),
              if (isLargeScreen)
                Expanded(
                  flex: 1,
                  child: _buildRightColumn(),
                ),
            ],
          ),
        );
      },
    );
  }
}