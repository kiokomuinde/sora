// lib/screens/create_blog_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/widgets/common_widgets.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import the new services
import 'package:sora_app/services/cloudinary_service.dart';
import 'package:sora_app/services/firestore_service.dart';

class CreateBlogScreen extends StatefulWidget {
  final AuthService authService;

  const CreateBlogScreen({super.key, required this.authService});

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers for Step 1
  final TextEditingController _mainTopicController = TextEditingController();
  final TextEditingController _snippetController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();
  final TextEditingController _subtopicsCountController = TextEditingController();
  final TextEditingController _imagesCountController = TextEditingController();

  String? _selectedCategory;
  int _subtopicsCount = 1;
  int _imagesCount = 1;
  bool _isSubmitting = false; // New variable to track submission state

  // Controllers for Step 2
  List<TextEditingController> _subtopicTitleControllers = [];
  List<TextEditingController> _subtopicBodyControllers = [];

  // Controllers for Step 3
  final TextEditingController _summaryController = TextEditingController();
  List<XFile> _imageFiles = [];

  final List<String> _categories = [
    'Market Trends',
    'Selling Tips',
    'Investment',
    'Technology',
    'Financing',
    'Real Estate',
    'Airbnb'
  ];

  // NEW: Instantiate your services here
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _subtopicsCountController.text = _subtopicsCount.toString();
    _imagesCountController.text = _imagesCount.toString();
    _updateSubtopicControllers();
  }

  void _updateSubtopicControllers() {
    // Dispose previous controllers to prevent memory leaks
    for (var controller in _subtopicTitleControllers) {
      controller.dispose();
    }
    for (var controller in _subtopicBodyControllers) {
      controller.dispose();
    }
    _subtopicTitleControllers =
        List.generate(_subtopicsCount, (index) => TextEditingController());
    _subtopicBodyControllers =
        List.generate(_subtopicsCount, (index) => TextEditingController());
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mainTopicController.dispose();
    _snippetController.dispose();
    _introductionController.dispose();
    _summaryController.dispose();
    _subtopicsCountController.dispose();
    _imagesCountController.dispose();

    for (var controller in _subtopicTitleControllers) {
      controller.dispose();
    }
    for (var controller in _subtopicBodyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.page!.round() == 0) {
      if (_formKey.currentState!.validate()) {
        final subtopicCount = int.tryParse(_subtopicsCountController.text);
        final imageCount = int.tryParse(_imagesCountController.text);

        if (subtopicCount != null && imageCount != null) {
          _subtopicsCount = subtopicCount;
          _imagesCount = imageCount;
          _updateSubtopicControllers();
        }

        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } else if (_pageController.page!.round() == 1) {
      bool allFieldsFilled = true;
      for (var i = 0; i < _subtopicTitleControllers.length; i++) {
        if (_subtopicTitleControllers[i].text.isEmpty ||
            _subtopicBodyControllers[i].text.isEmpty) {
          allFieldsFilled = false;
          break;
        }
      }

      if (allFieldsFilled) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all subtopic fields to proceed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Future<void> _submitBlog() async {
    // Check if the final summary is not empty
    if (_summaryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a final summary.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if the correct number of images have been selected
    if (_imageFiles.length != _imagesCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select exactly $_imagesCount images.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Since the form in Step 1 is no longer in the widget tree,
    // we cannot call _formKey.currentState!.validate().
    // The validation for that form was already done in _nextPage().

    // Start the submission process
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Step 1: Upload images to Cloudinary
      final List<String> imageUrls = await _cloudinaryService.uploadMultipleImages(_imageFiles);

      if (imageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed. Please try again.'), backgroundColor: Colors.red),
        );
        return;
      }

      // Step 2: Prepare the data for Firestore
      final blogData = {
        'title': _mainTopicController.text,
        'category': _selectedCategory,
        'snippet': _snippetController.text,
        'introduction': _introductionController.text,
        'summary': _summaryController.text,
        'imageUrls': imageUrls, // Store the Cloudinary image URLs
        'subtopics': _subtopicTitleControllers.asMap().entries.map((entry) {
          final int index = entry.key;
          return {
            'title': entry.value.text,
            'body': _subtopicBodyControllers[index].text,
          };
        }).toList(),
      };

      // Step 3: Save the blog data to Firestore
      final bool success = await _firestoreService.addBlog(blogData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blog post created successfully!'),
            backgroundColor: Colors.green, // Green for success
          ),
        );
        // Corrected navigation to go directly to the blogs screen
        Navigator.of(context).pushReplacementNamed('/blogs');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save blog post to Firestore.'),
            backgroundColor: Colors.red, // Red for failure
          ),
        );
      }
    } catch (e) {
      print('Submission error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during submission: $e'),
          backgroundColor: Colors.red, // Red for general errors
        ),
      );
    } finally {
      // Ensure the button state is reset after completion
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        // Append selected images, but don't exceed the limit
        final availableSlots = _imagesCount - _imageFiles.length;
        _imageFiles.addAll(pickedFiles.take(availableSlots));

        if (pickedFiles.length > availableSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected images trimmed to fit the requested count of $_imagesCount.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    }
  }

  void _removeImage(XFile imageFile) {
    setState(() {
      _imageFiles.remove(imageFile);
    });
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Step 1: General Information',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E90FF)),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _mainTopicController,
                        labelText: 'Main Topic / Title',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _subtopicsCountController,
                              labelText: 'Number of Subtopics',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    int.tryParse(value) == null ||
                                    int.parse(value) <= 0) {
                                  return 'Enter a positive number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _imagesCountController,
                              labelText: 'Number of Images',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    int.tryParse(value) == null ||
                                    int.parse(value) <= 0) {
                                  return 'Enter a positive number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomDropdown<String>(
                        value: _selectedCategory,
                        hintText: 'Category',
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _snippetController,
                        labelText: 'Summary / Snippet',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a summary';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _introductionController,
                        labelText: 'Introduction',
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an introduction';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Step 2: Subtopics',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E90FF)),
                    ),
                    const SizedBox(height: 20),
                    for (int i = 0; i < _subtopicsCount; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: _subtopicTitleControllers[i],
                              labelText: 'Subtopic ${i + 1} Title',
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: _subtopicBodyControllers[i],
                              labelText: 'Subtopic ${i + 1} Body Content',
                              maxLines: 8,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Step 3: Final Touches',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E90FF)),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _summaryController,
                      labelText: 'Summary of the entire blog',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a final summary';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Blog Images',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 15.0, // horizontal spacing
                      runSpacing: 15.0, // vertical spacing
                      children: [
                        ..._imageFiles.map((imageFile) => _buildImagePreview(imageFile)),
                        if (_imageFiles.length < _imagesCount)
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F8FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFB0C4DE)!),
                              ),
                              child: Icon(Icons.add_a_photo,
                                  color: Colors.blue[300], size: 40),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_imageFiles.length} / $_imagesCount images uploaded',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBlog, // Disable the button while submitting
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isSubmitting // Show a loader or the button text
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(XFile imageFile) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb
                ? Image.network(
                    imageFile.path,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(imageFile.path),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: -5,
          right: -5,
          child: GestureDetector(
            onTap: () => _removeImage(imageFile),
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Color(0xFF1E90FF),
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Create New Blog'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1(),
          _buildStep2(),
          _buildStep3(),
        ],
      ),
    );
  }
}