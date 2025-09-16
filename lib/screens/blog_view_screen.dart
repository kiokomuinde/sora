// lib/screens/blog_view_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';

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
          // This Expanded widget ensures the content takes up the available space,
          // pushing the footer to the bottom.
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (blogPost['imageUrl'] != null)
                    Image.network(
                      blogPost['imageUrl'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 250,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blogPost['title'],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A66C2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Corrected the key from 'author' to 'user'
                        Text(
                          'By ${blogPost['user'] ?? 'Sora Team'} on ${blogPost['date']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          blogPost['content'],
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
          
          // The footer is now placed outside the scrollable area,
          // so it stays at the bottom of the screen.
          commonWidgets.buildFooter(),
        ],
      ),
    );
  }
}