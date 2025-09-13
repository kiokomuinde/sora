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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;

    return Scaffold(
      appBar: AppBar(
        title: Text(blogPost['title']),
        actions: [
          if (isLargeScreen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/create_blog');
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Blog'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0A66C2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !isLargeScreen
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/create_blog');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Blog'),
              backgroundColor: const Color(0xFF1E90FF),
            )
          : null,
      body: SingleChildScrollView(
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
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'By ${blogPost['author']} on ${blogPost['date']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }
}
