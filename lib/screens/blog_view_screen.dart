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

    return Scaffold(
      appBar: AppBar(
        title: Text(blogPost['title']),
        // You can add an endDrawer here if you need one.
      ),
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