// lib/screens/blogs_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:sora_app/services/firestore_service.dart'; 
import 'package:share_plus/share_plus.dart'; 

// 🎯 CRITICAL: SEO Package Import
import 'package:seo/seo.dart';

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
  final FirestoreService _firestoreService = FirestoreService(); 
  
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
    _checkAdminStatus(); 
  }

  Future<void> _checkAdminStatus() async {
    final user = widget.authService.getCurrentUser();
    if (user != null) {
      final isAdmin = await _firestoreService.checkAdminStatus(user.uid);
      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
        });
      }
    }
  }

  @override
  void dispose() {
    _newsletterEmailController.dispose();
    super.dispose();
  }

  void _shareBlog(Map<String, dynamic> blog) {
    final blogId = blog['blogId'] ?? blog['id'];
    final blogTitle = blog['title'] ?? 'A Blog Post from Sora Properties';
    const String baseDomain = 'https://soraproperties.co.ke';

    final String shareUrl = blogId != null 
        ? '$baseDomain/#/blog_view/$blogId' 
        : '$baseDomain/#/blogs'; 

    final String shareMessage = 'Check out this post: $blogTitle\n\n$shareUrl';

    Share.share(
      shareMessage, 
      subject: blogTitle,
    ); 
  }
  
  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _currentListingTypeFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
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

    final List<dynamic>? imageUrlsDynamic = blog['imageUrls'] as List<dynamic>?;
    final List<String> imageUrls = imageUrlsDynamic?.map((e) => e.toString()).toList() ?? [];
    final String imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : 'https://placehold.co/600x400/E0E0E0/white?text=No+Image';
    
    final blogTitle = blog['title'] ?? 'Untitled Blog Post';
    final blogIdForNav = blog['blogId'] ?? blog['id']; 
    final blogSnippet = blog['snippet'] ?? 'A brief snippet about the blog post content.';
    
    // 🎯 SEO: Crawlable Link Wrapping the entire card
    return Seo.link(
      href: 'https://soraproperties.co.ke/#/blog_view/$blogIdForNav',
      anchor: blogTitle,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/blog_view/$blogIdForNav',
            arguments: blog,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack( 
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    // 🎯 SEO: Image Tag with Alt Text
                    child: Seo.image(
                      src: imageUrl,
                      alt: blogTitle,
                      child: Image.network(
                        imageUrl,
                        height: 200, 
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  Positioned( 
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6), 
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.white, size: 20),
                        onPressed: () {
                          _shareBlog(blog);
                        },
                        tooltip: 'Share this post',
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A66C2).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        blog['category'] ?? 'Uncategorized',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded( 
                child: Padding(
                  padding: const EdgeInsets.all(16.0), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🎯 SEO: H2 Semantic Header for Blog Titles
                      Seo.text(
                        text: blogTitle,
                        style: TextTagStyle.h2,
                        child: Text(
                          blogTitle,
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20, 
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A66C2),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8), 
                      Expanded( 
                        // 🎯 SEO: Paragraph Semantic Tag for Snippets
                        child: Seo.text(
                          text: blogSnippet,
                          style: TextTagStyle.p,
                          child: Text(
                            blogSnippet,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 15, 
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                            maxLines: 3, 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'By ${blog['userId'] ?? 'Sora Team'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
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
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E90FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/blog_view/$blogIdForNav',
                                  arguments: blog,
                                );
                              },
                              icon: const Icon(Icons.arrow_forward, color: Color(0xFF1E90FF)),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(), 
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

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, 
      children: [
        // Title and Subtitle
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 30 : 50, 
            horizontal: 20
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🎯 SEO: Main H1 Page Header
              Seo.text(
                text: 'Sora Blog: Insights & Trends',
                style: TextTagStyle.h1,
                child: Text(
                  'Sora Blog: Insights & Trends',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0A66C2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 🎯 SEO: Paragraph Descriptor
              Seo.text(
                text: 'Your source for the latest real estate market analysis, investment tips, and homeowner guides.',
                style: TextTagStyle.p,
                child: Text(
                  'Your source for the latest real estate market analysis, investment tips, and homeowner guides.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 18,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Categories/Filters
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          alignment: Alignment.center,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildFilterChip('All', ''),
              _buildFilterChip('Market Trends', 'Market Trends'),
              _buildFilterChip('Selling Tips', 'Selling Tips'),
              _buildFilterChip('Investment', 'Investment'),
              _buildFilterChip('Technology', 'Technology'),
              _buildFilterChip('Financing', 'Financing'),
              _buildFilterChip('Real Estate', 'Real Estate'),
              _buildFilterChip('BNB', 'Airbnb'), 
            ],
          ),
        ),

        // Blog Posts Grid/List
        Padding( 
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 15.0 : 30.0, vertical: 10.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getBlogs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Color(0xFF0A66C2)),
                  )
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text('Error loading blogs: ${snapshot.error}'),
                  )
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text('No blog posts found.', style: TextStyle(fontSize: 16)),
                ));
              }

              final allBlogs = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['blogId'] = doc.id; 
                return data;
              }).toList();
              
              final filteredBlogs = allBlogs.where((blog) {
                final category = blog['category'] ?? '';
                if (_currentListingTypeFilter.isEmpty) {
                  return true;
                }
                return category == _currentListingTypeFilter;
              }).toList();

              if (filteredBlogs.isEmpty) {
                 return Center(
                   child: Padding(
                     padding: const EdgeInsets.all(40.0),
                     child: Text('No blogs found in the category: $_currentListingTypeFilter', style: const TextStyle(fontSize: 16)),
                   )
                 );
              }

              // Responsive logic for the grid
              int crossAxisCount;
              if (screenWidth > 1200) {
                crossAxisCount = 4;
              } else if (screenWidth > 900) {
                crossAxisCount = 3;
              } else if (screenWidth > 600) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 1;
              }

              return GridView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isMobile ? 15 : 25,
                  mainAxisSpacing: isMobile ? 15 : 25,
                  mainAxisExtent: 420, 
                ),
                itemCount: filteredBlogs.length,
                itemBuilder: (context, index) {
                  return _buildBlogCard(context, filteredBlogs[index]);
                },
              );
            },
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Newsletter Signup
        _buildNewsletterSignup(context),
        
        // Footer
        commonWidgets.buildFooter(),
      ],
    );
  }

  Widget _buildNewsletterSignup(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 50, 
        horizontal: 20
      ),
      color: const Color(0xFFF0F8FF), 
      child: Column(
        children: [
          // 🎯 SEO: H2 Semantic Header for Newsletter
          Seo.text(
            text: 'Stay Updated',
            style: TextTagStyle.h2,
            child: Text(
              'Stay Updated',
              style: TextStyle(
                fontSize: isMobile ? 24 : 30,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A66C2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Seo.text(
            text: 'Subscribe to our newsletter for exclusive real estate insights.',
            style: TextTagStyle.p,
            child: Text(
              'Subscribe to our newsletter for exclusive real estate insights.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 25),
          
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: isMobile 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _newsletterEmailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        // Implement Newsletter Logic
                        _newsletterEmailController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscribed successfully!')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E90FF),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Subscribe',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
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
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Implement Newsletter Logic
                        _newsletterEmailController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscribed successfully!')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E90FF),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
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

    // 🎯 SEO: Dynamic Page Titles based on Filter
    final String categoryTitle = _currentListingTypeFilter.isNotEmpty 
        ? '$_currentListingTypeFilter - ' 
        : '';
    final String pageTitle = '${categoryTitle}Real Estate Blog & Insights | Sora Properties';
    final String pageDesc = 'Stay updated with the latest real estate news, investment tips, and market trends in Kenya with the Sora Properties blog.';

    // 🎯 SEO: Core Head Wrapper
    return Seo.head(
      tags: [
        MetaTag(name: 'title', content: pageTitle),
        MetaTag(name: 'description', content: pageDesc),
        MetaTag(name: 'keywords', content: 'Real Estate Blog, Kenya Real Estate, Investment Tips, Property Market Trends, Sora Properties'),
        MetaTag(name: 'og:title', content: pageTitle),
        MetaTag(name: 'og:description', content: pageDesc),
        MetaTag(name: 'og:type', content: 'blog'),
        MetaTag(name: 'og:url', content: 'https://soraproperties.co.ke/#/blogs'),
        MetaTag(name: 'twitter:card', content: 'summary_large_image'),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.buildAppBar(),
        endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
        floatingActionButton: isLoggedIn && _isAdmin
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
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
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      Navigator.pushNamed(context, '/create_blog');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.edit, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Write Post',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
          child: _buildContent(context),
        ),
      ),
    );
  }
}