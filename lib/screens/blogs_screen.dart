// /lib/screens/blogs_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets

class BlogsScreen extends StatefulWidget {
  final AuthService authService;

  const BlogsScreen({super.key, required this.authService});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  final TextEditingController _newsletterEmailController = TextEditingController();
  String _currentListingTypeFilter = '';
  late CommonWidgets commonWidgets; // Declare commonWidgets

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService); // Initialize commonWidgets
  }

  // Mock blog data
  final List<Map<String, dynamic>> _blogPosts = [
    {
      "id": "1",
      "title": "The Future of Real Estate in Africa: 2025 Trends",
      "image": "assets/images/blog1.webp",
      "category": "Market Trends",
      "date": "July 10, 2025",
      "snippet": "Explore the emerging trends shaping the African real estate market, from sustainable development to digital transformation.",
      "content": "The African real estate market is on the cusp of a major transformation. With rapid urbanization, a growing middle class, and increased foreign investment, the demand for both residential and commercial properties is soaring. In 2025, we anticipate several key trends to dominate the landscape. Firstly, sustainable and green building practices will become more prevalent as developers and buyers become more environmentally conscious. Secondly, technology will play an even bigger role, with virtual tours, AI-powered property matching, and blockchain for secure transactions becoming standard. Thirdly, affordable housing initiatives will gain momentum, driven by government policies and private sector innovation. Finally, cross-border investments are expected to surge, as Africa continues to be seen as a frontier market with high growth potential. Understanding these trends is crucial for anyone looking to invest or participate in the African real estate sector.",
    },
    {
      "id": "2",
      "title": "Home Staging Tips to Sell Your Property Faster",
      "image": "assets/images/blog2.webp",
      "category": "Selling Tips",
      "date": "June 28, 2025",
      "snippet": "Discover professional home staging techniques that can significantly reduce your property's time on the market.",
      "content": "Home staging is an art and a science that can dramatically impact how quickly your property sells and for what price. The goal is to make your home appealing to the widest possible range of potential buyers. Start by decluttering and depersonalizing; remove family photos, excessive knick-knacks, and personal items. This allows buyers to envision themselves in the space. Next, deep clean every corner of your home, paying attention to often-overlooked areas like grout and baseboards. Enhance curb appeal by tidying up the exterior, adding fresh flowers, and ensuring the entrance is inviting. Inside, focus on neutral colors for walls and decor, as this creates a sense of spaciousness and allows buyers to project their own style. Arrange furniture to highlight the room's best features and ensure good flow. Finally, consider minor repairs like leaky faucets or chipped paint, as these small fixes can make a big difference in a buyer's perception of the home's maintenance. A well-staged home not only sells faster but often fetches a higher price.",
    },
    {
      "id": "3",
      "title": "Investing in Rental Properties: A Beginner's Guide",
      "image": "assets/images/blog3.webp",
      "category": "Investment",
      "date": "May 15, 2025",
      "snippet": "A comprehensive guide for first-time investors looking to venture into the lucrative world of rental properties.",
      "content": "Investing in rental properties can be a lucrative venture, offering both passive income and long-term appreciation. For beginners, it's essential to start with a solid understanding of the market and a clear strategy. First, research potential locations thoroughly. Look for areas with strong rental demand, good schools (if targeting families), low vacancy rates, and positive economic indicators. Second, understand the financials: calculate potential rental income, property taxes, insurance, maintenance costs, and potential mortgage payments. Aim for a positive cash flow. Third, consider the type of property – single-family homes, multi-family units, or apartments each have their pros and cons. Fourth, be prepared for landlord responsibilities, or budget for a property management company. This includes tenant screening, maintenance, and handling emergencies. Finally, build a strong network of professionals, including real estate agents, lenders, and contractors. By approaching rental property investment strategically, you can build a robust portfolio.",
    },
    {
      "id": "4",
      "title": "Smart Home Technology: Enhancing Property Value",
      "image": "assets/images/blog4.webp",
      "category": "Technology",
      "date": "April 01, 2025",
      "snippet": "Learn how integrating smart home devices can boost your property's appeal and market value.",
      "content": "In today's tech-driven world, smart home technology is no longer a luxury but a desirable feature that can significantly enhance property value and appeal. Buyers are increasingly looking for homes that offer convenience, security, and energy efficiency. Integrating smart thermostats, lighting systems, security cameras, and smart locks can make your property stand out. Smart thermostats, for example, allow for remote temperature control, leading to energy savings that appeal to eco-conscious buyers. Smart lighting systems offer ambiance control and can be programmed for various scenarios, adding a touch of modern luxury. Advanced security systems with remote monitoring capabilities provide peace of mind. Even smart appliances can be a draw. While the initial investment might seem significant, these upgrades often yield a strong return on investment by attracting tech-savvy buyers and justifying a higher asking price. It’s about offering a lifestyle of convenience and modernity.",
    },
    {
      "id": "5",
      "title": "Understanding Mortgage Options: A Guide for Buyers",
      "image": "assets/images/blog5.webp",
      "category": "Financing",
      "date": "March 20, 2025",
      "snippet": "Navigate the complexities of mortgage options with this essential guide for first-time and experienced homebuyers.",
      "content": "Securing a mortgage is a critical step in the home-buying process, and understanding your options is key to making an informed decision. There are several types of mortgages, each with different features. Fixed-rate mortgages offer a consistent interest rate for the life of the loan, providing stability in monthly payments. Adjustable-rate mortgages (ARMs) have an initial fixed rate, which then adjusts periodically based on market indices; these can offer lower initial payments but come with interest rate risk. FHA loans are government-insured and popular among first-time homebuyers due to lower down payment requirements. VA loans, for eligible veterans, offer competitive rates and no down payment. Conventional loans are not government-backed and require good credit and a stable income. It's crucial to compare interest rates, terms, closing costs, and eligibility criteria for each option. Consulting with a mortgage advisor is highly recommended to determine the best fit for your financial situation.",
    },
  ];

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
                Navigator.of(context).pop(); // Dismiss dialog
                Navigator.pushNamed(context, '/signin'); // Navigate to sign-in
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blogs'),
        backgroundColor: const Color(0xFF0A66C2),
        elevation: 0,
        actions: [
          if (isLargeScreen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/create_blog');
                },
                icon: const Icon(Icons.add, color: Color(0xFF0A66C2)),
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
      endDrawer: !isLargeScreen ? commonWidgets.buildDrawer() : null,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Latest Blogs',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Stay informed with expert insights, market trends, and helpful tips.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Blog Posts Grid
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
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
                      crossAxisSpacing: isLargeScreen ? 30 : 20,
                      mainAxisSpacing: isLargeScreen ? 30 : 20,
                      childAspectRatio: isLargeScreen ? 0.75 : (isMediumScreen ? 0.7 : 0.85), // Adjusted for content
                    ),
                    itemCount: _blogPosts.length,
                    itemBuilder: (context, index) {
                      final blog = _blogPosts[index];
                      return _buildBlogCard(blog);
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
                      Navigator.pushNamed(context, '/contact'); // Navigate to Contact screen
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
              color: const Color(0xFFF0F2F5), // Light grey background
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/blog_view',
          arguments: blog, // Pass the entire blog map as arguments
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
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(blog['image']!),
                    fit: BoxFit.cover,
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
                    const Spacer(), // Pushes date and read more to the bottom
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        blog['date']!,
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
                            arguments: blog, // Pass the entire blog map as arguments
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
