// lib/screens/blog_view_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BlogViewScreen extends StatefulWidget {
  final Map<String, dynamic> blogPost;
  final AuthService authService;

  const BlogViewScreen({
    super.key,
    required this.blogPost,
    required this.authService,
  });

  @override
  State<BlogViewScreen> createState() => _BlogViewScreenState();
}

class _BlogViewScreenState extends State<BlogViewScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late CommonWidgets commonWidgets;

  // Predefined list of categories from create_blog_screen.dart
  final List<String> _categories = [
    'Market Trends',
    'Selling Tips',
    'Investment',
    'Technology',
    'Financing',
    'Real Estate',
    'Airbnb'
  ];

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
  }

  // Helper method to format the date
  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate().toString().split(' ')[0];
    }
    return 'Date Unavailable';
  }

  // Helper method to build a subtopic section with an optional image
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

  Widget _buildLeftColumn() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getBlogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No categories available.'));
        }

        final blogs = snapshot.data!.docs;
        final Map<String, int> categoryCounts = {};
        for (var blog in blogs) {
          final data = blog.data() as Map<String, dynamic>;
          final category = data['category'] ?? 'Uncategorized';
          categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
        }

        return Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Blog Categories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E90FF),
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
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRightColumn() {
    final currentBlogId = widget.blogPost['blogId'];
    final currentBlogCategory = widget.blogPost['category'];

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getBlogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No related blogs available.'));
        }

        final allBlogs = snapshot.data!.docs.map((doc) => {
          ...doc.data() as Map<String, dynamic>,
          'blogId': doc.id,
        }).toList();

        // Filter out the current blog and find related ones
        final relatedBlogs = allBlogs.where((blog) {
          return blog['blogId'] != currentBlogId && blog['category'] == currentBlogCategory;
        }).toList();

        if (relatedBlogs.isEmpty) {
          return const Center(child: Text('No related blogs found.'));
        }

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: ListView.builder(
                  itemCount: relatedBlogs.length,
                  itemBuilder: (context, index) {
                    final blog = relatedBlogs[index];
                    final String imageUrl = blog['imageUrls']?.isNotEmpty == true ? blog['imageUrls'][0] : 'https://placehold.co/600x400/E0E0E0/white?text=No+Image';
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the related blog post view
                        Navigator.pushNamed(
                          context,
                          '/blog_view',
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
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isLoggedIn = widget.authService.getCurrentUser() != null;
    final List<String> imageUrls = widget.blogPost['imageUrls']?.cast<String>() ?? [];
    final List<Map<String, dynamic>> subtopics = widget.blogPost['subtopics']?.cast<Map<String, dynamic>>() ?? [];

    // The main content of the blog post
    final blogContent = SingleChildScrollView(
      child: Column(
        children: [
          // Blog Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.blogPost['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A66C2),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'By ${widget.blogPost['userId'] ?? 'Sora Team'} on ${_formatDate(widget.blogPost['timestamp'])}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.blogPost['snippet'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Blog Content Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.blogPost['introduction'] ?? '',
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
                  widget.blogPost['summary'] ?? '',
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
          // Left Column for large screens
          if (isLargeScreen)
            Expanded(
              flex: 1,
              child: _buildLeftColumn(),
            ),
          // Center Column for blog content
          Expanded(
            flex: 2,
            child: blogContent,
          ),
          // Right Column for large screens
          if (isLargeScreen)
            Expanded(
              flex: 1,
              child: _buildRightColumn(),
            ),
        ],
      ),
    );
  }
}