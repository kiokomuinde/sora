// lib/screens/blog_view_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp

class BlogViewScreen extends StatelessWidget {
  final Map<String, dynamic> blogPost;
  final AuthService authService;

  const BlogViewScreen({
    super.key,
    required this.blogPost,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final commonWidgets = CommonWidgets(context: context, authService: authService);
    final bool isLoggedIn = authService.getCurrentUser() != null;
    final List<String> imageUrls = blogPost['imageUrls']?.cast<String>() ?? [];

    // Helper method to build the full blog content
    String _buildFullContent() {
      final introduction = blogPost['introduction'] ?? '';
      final subtopics = blogPost['subtopics']?.cast<Map<String, dynamic>>() ?? [];
      String fullContent = introduction;
      if (subtopics.isNotEmpty) {
        for (var subtopic in subtopics) {
          fullContent += '\n\n**${subtopic['title']}**\n${subtopic['body']}';
        }
      }
      return fullContent;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: isLoggedIn
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E90FF), // A beautiful blue
                    Color(0xFF8A2BE2), // A beautiful purple
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
                    // Navigate to the create blog screen
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
          : null, // Hide the button if the user is not logged in
      
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (imageUrls.isNotEmpty)
                    Image.network(
                      imageUrls[0],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 250,
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
                  else
                    Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Center(
                        child: Text(
                          'Image Unavailable',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blogPost['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A66C2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'By ${blogPost['userId'] ?? 'Sora Team'} on ${_formatDate(blogPost['timestamp'])}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _buildFullContent(),
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          commonWidgets.buildFooter(),
        ],
      ),
    );
  }

  // Helper method to format the date
  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate().toString().split(' ')[0];
    }
    return 'Date Unavailable';
  }
}