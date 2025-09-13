// lib/screens/create_blog_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';

class CreateBlogScreen extends StatefulWidget {
  final AuthService authService;

  const CreateBlogScreen({super.key, required this.authService});

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _snippetController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'Market Trends';
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
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _snippetController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitBlog() {
    if (_formKey.currentState!.validate()) {
      // Logic to save the blog post to a database (e.g., Firestore)
      // For this example, we'll just show a success message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Blog post "${_titleController.text}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // You would normally add the post to your database here
      // and then navigate back.
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Blog Post'),
        backgroundColor: const Color(0xFF0A66C2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 40.0,
            horizontal: isLargeScreen ? 200.0 : 24.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Write Your Article',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 40 : 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0A66C2),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Title',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., The Future of Real Estate',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Image URL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., https://example.com/image.jpg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Snippet',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _snippetController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'A short summary of the blog post',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a snippet';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Content',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  maxLines: 15,
                  decoration: const InputDecoration(
                    hintText: 'Write the full content of your blog post here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitBlog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Publish Blog'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
