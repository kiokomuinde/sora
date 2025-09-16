// /lib/screens/blogs_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NEW: Import Firestore classes
import 'package:sora_app/services/firestore_service.dart'; // NEW: Import FirestoreService

class BlogsScreen extends StatefulWidget {
  final AuthService authService;

  const BlogsScreen({super.key, required this.authService});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  final TextEditingController _newsletterEmailController = TextEditingController();
  String _currentListingTypeFilter = '';
  late CommonWidgets commonWidgets;
  final FirestoreService _firestoreService = FirestoreService(); // NEW: Instantiate the FirestoreService

  // Mock blog data has been removed

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
  }

  @override
  void dispose() {
    _newsletterEmailController.dispose();
    super.dispose();
  }

  // Common dialog for login/signup prompt, copied from home_screen.dart
  void _showLoginSignupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Login or Sign Up Required',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          content: const Text(
            'Please log in or create an account to proceed with this action.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E90FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Login / Sign Up'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/signin');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isLoggedIn = widget.authService.getCurrentUser() != null;

    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blogs Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 80 : (isMediumScreen ? 60 : 40),
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E90FF).withOpacity(0.8), Color(0xFF0A66C2).withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: isLargeScreen
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Our Latest Blogs',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Stay informed with expert insights, market trends, and helpful tips.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        if (isLoggedIn)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/create_blog');
                            },
                            icon: const Icon(Icons.add, color: Color(0xFF0A66C2)),
                            label: const Text('Create Blog'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0A66C2),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 5,
                            ),
                          ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Latest Blogs',
                          style: TextStyle(
                            fontSize: isMediumScreen ? 38 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isMediumScreen ? 10 : 5),
                        Text(
                          'Stay informed with expert insights, market trends, and helpful tips.',
                          style: TextStyle(
                            fontSize: isMediumScreen ? 16 : 14,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: isMediumScreen ? 20 : 15),
                        if (isLoggedIn)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/create_blog');
                            },
                            icon: const Icon(Icons.add, color: Color(0xFF0A66C2)),
                            label: const Text('Create Blog'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0A66C2),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 5,
                            ),
                          ),
                      ],
                    ),
            ),

            // Blog Posts Grid with StreamBuilder
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : 30,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Articles',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 30 : 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getBlogs(), // NEW: Listen to the blog stream
                    builder: (context, snapshot) {
                      // Handle loading state
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Handle error state
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      // Handle no data state
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No blog posts found.'));
                      }

                      // Convert snapshots to a list of blog data maps
                      final blogPosts = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        data['id'] = doc.id; // Store the document ID
                        return data;
                      }).toList();

                      // Display the data in a GridView
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
                          crossAxisSpacing: isLargeScreen ? 30 : 20,
                          mainAxisSpacing: isLargeScreen ? 30 : 20,
                          childAspectRatio: isLargeScreen ? 0.75 : (isMediumScreen ? 0.7 : 0.85),
                        ),
                        itemCount: blogPosts.length,
                        itemBuilder: (context, index) {
                          final blog = blogPosts[index];
                          return _buildBlogCard(blog);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // Call to Action: Suggest a Topic
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 80 : (isMediumScreen ? 60 : 40),
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A66C2), Color(0xFF1E90FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Have a Blog Topic Suggestion?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 40 : (isMediumScreen ? 32 : 24),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 15),
                  Text(
                    'We\'d love to hear your ideas for future articles and guides.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 40 : 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/contact');
                    },
                    icon: const Icon(Icons.lightbulb),
                    label: const Text('Suggest a Topic'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0A66C2),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),

            // Newsletter Signup Section (from original footer, adapted)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : 30,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              color: const Color(0xFFF0F2F5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Stay Updated with SORA News',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : (isMediumScreen ? 26 : 22),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A66C2),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 15),
                  Text(
                    'Subscribe to our newsletter for the latest property listings, market insights, and exclusive offers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 30 : 20),
                  Container(
                    constraints: BoxConstraints(maxWidth: isLargeScreen ? 500 : double.infinity),
                    child: TextField(
                      controller: _newsletterEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_newsletterEmailController.text.isNotEmpty && _newsletterEmailController.text.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Subscribed with ${_newsletterEmailController.text}!')),
                        );
                        _newsletterEmailController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid email address.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Subscribe'),
                  ),
                ],
              ),
            ),

            // Footer
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogCard(Map<String, dynamic> blog) {
    // The blog map now contains a 'id' key and an 'imageUrls' list
    final String imageUrl = blog['imageUrls'] != null && blog['imageUrls'].isNotEmpty
        ? blog['imageUrls'][0] // Use the first image URL from the list
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/blog_view',
          arguments: blog,
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                // Check if a valid image URL exists
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                              child: Text(
                                  'Image not found',
                                  style: TextStyle(color: Colors.grey[600]),
                              ),
                          );
                        },
                      )
                    : Center( // Fallback if no image URL
                        child: Text(
                          'Image Unavailable',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog['category']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E90FF),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      blog['title']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      blog['snippet']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        // Format the timestamp if it exists, otherwise use a placeholder
                        blog['timestamp'] != null
                            ? (blog['timestamp'] as Timestamp).toDate().toString().split(' ')[0]
                            : 'Date Unavailable',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/blog_view',
                            arguments: blog,
                          );
                        },
                        child: const Text(
                          'Read More',
                          style: TextStyle(
                            color: Color(0xFF1E90FF),
                            fontWeight: FontWeight.bold,
                          ),
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
}