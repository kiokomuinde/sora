// lib/screens/blog_view_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart'; 
import 'dart:ui'; 

// 🎯 CRITICAL: SEO Package Import
import 'package:seo/seo.dart';

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
  
  bool _isAdmin = false; 

  final List<String> _categories = [
    'Market Trends', 'Selling Tips', 'Investment', 'Technology', 
    'Financing', 'Real Estate', 'Airbnb'
  ];

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService); 
    _loadBlogFuture = _fetchBlogData();
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
    } else {
      if (mounted) {
        setState(() {
          _isAdmin = false;
        });
      }
    }
  }

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

  void _shareBlog() {
    final blogId = widget.blogSlug ?? _currentBlogPost?['blogId'] ?? _currentBlogPost?['id'];
    final blogTitle = _currentBlogPost?['title'] ?? 'A New Blog Post from Sora Properties';
    
    const String baseDomain = 'https://soraproperties.co.ke';

    final String shareUrl = blogId != null 
        ? '$baseDomain/#/blog_view/$blogId' 
        : '$baseDomain/#/'; 

    Clipboard.setData(ClipboardData(text: shareUrl)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Link copied to clipboard!'),
            backgroundColor: const Color(0xFF1E90FF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    final String shareMessage = '$blogTitle\n\nRead more here: $shareUrl';

    Share.share(
      shareMessage, 
      subject: blogTitle,
    ); 
  }

  // --- MOBILE BOTTOM SHEETS ---
  void _showCategoriesBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(child: _buildLeftColumn()),
            ],
          ),
        );
      },
    );
  }

  void _showRelatedTopicsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  child: _buildRightColumn(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  // ----------------------------

  Widget _buildSubtopic(Map<String, dynamic> subtopic, {String? imageUrl}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎯 SEO: H2 Semantic Header for Subtopics
          Seo.text(
            text: subtopic['title'] ?? '',
            style: TextTagStyle.h2,
            child: Text(
              subtopic['title'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E90FF),
              ),
            ),
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 7, offset: const Offset(0, 3)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                // 🎯 SEO: Image tagging for Contextual Media
                child: Seo.image(
                  src: imageUrl,
                  alt: subtopic['title'] ?? 'Article Image',
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: isMobile ? 180 : 250,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 15),
          // 🎯 SEO: Paragraph tag for the main body
          Seo.text(
            text: subtopic['body'] ?? '',
            style: TextTagStyle.p,
            child: Text(
              subtopic['body'] ?? '',
              style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF333333)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedTopics(String currentBlogId, String currentBlogCategory) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _firestoreService.getRelatedBlogs(currentBlogCategory, currentBlogId, limit: 3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No other related blog topics found.'));
        }
        
        return Column(
          children: snapshot.data!.map((blog) => _buildRelatedBlogCard(context, blog)).toList(),
        );
      },
    );
  }

  Widget _buildRelatedBlogCard(BuildContext context, Map<String, dynamic> blog) {
    final String imageUrl = blog['imageUrls']?.isNotEmpty == true ? blog['imageUrls'][0] : 'https://placehold.co/600x400/E0E0E0/white?text=No+Image';
    final String blogIdForNav = (blog['blogId'] ?? blog['id'] ?? '') as String; 
    final String blogTitle = blog['title'] ?? 'No Title';

    // 🎯 SEO: Internal Crawlable link creation
    return Seo.link(
      href: 'https://soraproperties.co.ke/#/blog_view/$blogIdForNav',
      anchor: blogTitle,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/blog_view/$blogIdForNav', arguments: blog);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Seo.image(
                  src: imageUrl,
                  alt: blogTitle,
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Seo.text(
                      text: blogTitle,
                      style: TextTagStyle.h3,
                      child: Text(
                        blogTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDate(blog['timestamp']),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildRightColumn() {
    final rawId = _currentBlogPost?['blogId'] ?? _currentBlogPost?['id'];
    final rawCategory = _currentBlogPost?['category'];
    final currentBlogId = (rawId is String && rawId.isNotEmpty) ? rawId : null;
    final currentBlogCategory = (rawCategory is String && rawCategory.isNotEmpty) ? rawCategory : null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          const Text(
            'Related Topics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E90FF)),
          ),
          const SizedBox(height: 20),
          if (currentBlogId != null && currentBlogCategory != null) 
            _buildRelatedTopics(currentBlogId, currentBlogCategory) 
          else 
            const Text('Related topics unavailable.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLeftColumn() {
    const Color darkBlueTitle = Color(0xFF0A66C2);
    const Color primaryBlue = Color(0xFF1E90FF);

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getBlogs(),
      builder: (context, snapshot) {
        Map<String, int> categoryCounts = {};
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final cat = (doc.data() as Map<String, dynamic>)['category'] as String?;
            if (cat != null) {
              categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
            }
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
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
                  fontWeight: FontWeight.w900,
                  color: darkBlueTitle,
                  shadows: [Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 5, offset: const Offset(1, 1))],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: _categories.map((category) {
                    final count = categoryCounts[category] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(category, style: const TextStyle(fontSize: 16, color: primaryBlue, fontWeight: FontWeight.w700)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                            child: Text('$count', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          )
                        ],
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadBlogFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
        
        final String blogTitle = currentBlogPost['title'] ?? 'Untitled Post';
        final String blogSummary = currentBlogPost['summary'] ?? '';
        final String coverImage = imageUrls.isNotEmpty ? imageUrls[0] : 'https://placehold.co/600x400/E0E0E0/white?text=No+Image';

        // 🎯 SEO: Dynamic Page Metadata Setup
        final String pageTitle = '$blogTitle | Sora Properties Blog';
        final String pageDesc = blogSummary.isNotEmpty ? blogSummary : 'Read the latest real estate insights and tips from Sora Properties.';
        final String pageUrl = 'https://soraproperties.co.ke/#/blog_view/${widget.blogSlug ?? currentBlogPost['blogId'] ?? currentBlogPost['id']}';

        final Widget mainArticleContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.share, color: Color(0xFF1E90FF)),
                onPressed: _shareBlog,
                tooltip: 'Share Article',
              ),
            ),
            // 🎯 SEO: Primary H1 Header for the Blog Entry
            Seo.text(
              text: blogTitle,
              style: TextTagStyle.h1,
              child: Text(
                blogTitle,
                style: TextStyle(
                  fontSize: isLargeScreen ? 40 : 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A66C2),
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Published: ${_formatDate(currentBlogPost['timestamp'])}',
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                // 🎯 SEO: Main article image tagging
                child: Seo.image(
                  src: coverImage,
                  alt: blogTitle,
                  child: Image.network(
                    coverImage,
                    width: double.infinity,
                    height: isLargeScreen ? 500 : 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: isLargeScreen ? 500 : 250,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey)),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
            const Text(
              'Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E90FF)),
            ),
            const SizedBox(height: 10),
            // 🎯 SEO: Paragraph tag
            Seo.text(
              text: blogSummary,
              style: TextTagStyle.p,
              child: Text(
                blogSummary,
                style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF4B5563)),
              ),
            ),
            const SizedBox(height: 40),
            const Divider(),
            ...subtopics.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> subtopic = entry.value;
              String? imageUrl = (index + 1 < imageUrls.length) ? imageUrls[index + 1] : null;
              return _buildSubtopic(subtopic, imageUrl: imageUrl);
            }).toList(),
            
            if (isLargeScreen) ...[
              const SizedBox(height: 60),
              const Divider(),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: SizedBox(height: 500, child: _buildLeftColumn())),
                  const SizedBox(width: 40),
                  Expanded(child: SizedBox(height: 500, child: _buildRightColumn())),
                ],
              ),
            ]
          ],
        );

        final blogContent = SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 1400),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                child: isLargeScreen 
                    ? Row( // Desktop wide layout mapping
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: mainArticleContent),
                          const SizedBox(width: 60),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                SizedBox(height: 450, child: _buildLeftColumn()), // Categories
                                const SizedBox(height: 40),
                                _buildRightColumn(), // Related
                              ],
                            ),
                          ),
                        ],
                      )
                    : mainArticleContent, // Mobile layout mapping
              ),
              commonWidgets.buildFooter(),
              if (!isLargeScreen) const SizedBox(height: 80),
            ],
          ),
        );

        // 🎯 SEO: Wrapping the Page Scaffold in Seo.head for Dynamic Search Metadata
        return Seo.head(
          tags: [
            MetaTag(name: 'title', content: pageTitle),
            MetaTag(name: 'description', content: pageDesc),
            MetaTag(name: 'og:title', content: pageTitle),
            MetaTag(name: 'og:description', content: pageDesc),
            MetaTag(name: 'og:image', content: coverImage),
            MetaTag(name: 'og:url', content: pageUrl),
            MetaTag(name: 'og:type', content: 'article'),
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
                      gradient: const LinearGradient(colors: [Color(0xFF1E90FF), Color(0xFF8A2BE2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 3))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () => Navigator.pushNamed(context, '/create_blog'),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Write Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : null, 
            body: Stack(
              children: [
                blogContent,
                if (!isLargeScreen)
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: _showCategoriesBottomSheet,
                                icon: const Icon(Icons.category_rounded, color: Color(0xFF1E90FF), size: 20),
                                label: const Text('Categories', style: TextStyle(color: Color(0xFF1E90FF), fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                              ),
                              Container(width: 1, height: 24, color: Colors.grey[300]),
                              TextButton.icon(
                                onPressed: _showRelatedTopicsBottomSheet,
                                icon: const Icon(Icons.article_rounded, color: Color(0xFF1E90FF), size: 20),
                                label: const Text('Related', style: TextStyle(color: Color(0xFF1E90FF), fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}