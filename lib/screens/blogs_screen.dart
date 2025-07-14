// /lib/screens/blogs_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/services/auth_service.dart';

class BlogsScreen extends StatefulWidget {
  final AuthService authService;

  const BlogsScreen({super.key, required this.authService});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  final TextEditingController _newsletterEmailController = TextEditingController();
  String _currentListingTypeFilter = '';

  // Mock blog data
  final List<Map<String, dynamic>> _blogPosts = [
    {
      "id": "1",
      "title": "The Future of Real Estate in Africa: 2025 Trends",
      "image": "assets/images/blog1.webp",
      "category": "Market Trends",
      "date": "July 10, 2025",
      "snippet": "Explore the emerging trends shaping the African real estate market, from sustainable development to digital transformation.",
      "content": "The African real estate market is on the cusp of a major transformation. With rapid urbanization, a growing middle class, and increased foreign investment, the demand for both residential and commercial properties is soaring. In 2025, we anticipate several key trends to dominate the landscape. Firstly, sustainable and green building practices will become more prevalent as developers respond to environmental concerns and government incentives. Secondly, proptech (property technology) will continue to revolutionize how properties are bought, sold, and managed, making processes more efficient and transparent. Virtual tours, AI-powered valuation tools, and blockchain for secure transactions are no longer futuristic concepts but present realities. Thirdly, affordable housing initiatives will gain momentum, driven by both public and private sectors aiming to address housing deficits across the continent. Finally, the rise of co-living and co-working spaces will cater to the evolving lifestyles of young professionals and digital nomads, fostering community and flexibility. These trends collectively point towards a dynamic and innovative future for real estate in Africa, promising significant opportunities for investors and homeowners alike."
    },
    {
      "id": "2",
      "title": "Investing in African Property: A Beginner's Guide",
      "image": "assets/images/blog2.webp",
      "category": "Investment",
      "date": "June 28, 2025",
      "snippet": "A comprehensive guide for new investors looking to enter the vibrant and diverse African property market.",
      "content": "Investing in African property can be highly rewarding, but it requires careful consideration and a solid understanding of local markets. For beginners, the first step is to research specific countries and cities. Each region has its unique economic drivers, legal frameworks, and property types that influence investment viability. Key factors to consider include political stability, economic growth rates, infrastructure development, and population demographics. Diversification is crucial; instead of putting all your eggs in one basket, consider a mix of residential, commercial, and even agricultural properties. Engaging with local experts, such as reputable real estate agents, lawyers, and financial advisors, is indispensable. They can provide invaluable insights into market nuances, assist with due diligence, and navigate complex legal processes. Understanding financing options, including local bank loans and international investment funds, is also vital. Finally, be prepared for long-term commitment. Real estate investment, especially in emerging markets, often yields the best returns over extended periods. With strategic planning and informed decisions, African property can be a cornerstone of a robust investment portfolio."
    },
    {
      "id": "3",
      "title": "Top 5 Eco-Friendly Home Features for 2025",
      "image": "assets/images/blog3.webp",
      "category": "Sustainable Living",
      "date": "June 15, 2025",
      "snippet": "Discover the top eco-friendly features that are becoming essential for modern homes in Africa.",
      "content": "As environmental consciousness grows and energy costs fluctuate, eco-friendly home features are no longer niche but mainstream. For 2025, here are the top five features making a significant impact in African homes: 1. Solar Power Systems: Beyond basic solar water heaters, full-fledged photovoltaic (PV) systems are gaining traction, providing energy independence and reducing electricity bills. Advances in battery storage make off-grid living more feasible. 2. Rainwater Harvesting and Greywater Recycling: Efficient systems for collecting rainwater for irrigation and recycling greywater (from sinks, showers) for non-potable uses are essential for water conservation, especially in water-stressed regions. 3. Natural Ventilation and Passive Cooling: Architects are increasingly designing homes to maximize natural airflow and minimize heat gain, reducing the need for air conditioning. This includes strategic window placement, high ceilings, and thermal mass construction. 4. Smart Home Energy Management: Integrated smart home systems allow homeowners to monitor and control energy consumption of appliances, lighting, and HVAC systems, optimizing efficiency and reducing waste. 5. Sustainable Building Materials: The use of locally sourced, recycled, and low-carbon materials like bamboo, compressed earth blocks, and recycled plastic bricks is becoming more common, reducing the environmental footprint of construction. These features not only benefit the planet but also offer long-term cost savings and enhanced living comfort."
    },
    {
      "id": "4",
      "title": "Navigating Property Laws in East Africa",
      "image": "assets/images/blog4.webp",
      "category": "Legal Guide",
      "date": "May 30, 2025",
      "snippet": "A simplified overview of the key property laws and regulations across East African countries.",
      "content": "Navigating property laws in East Africa can be complex due to varying legal systems and land tenure arrangements across countries like Kenya, Tanzania, Uganda, and Rwanda. While each nation has its specific nuances, some common themes and critical considerations emerge for buyers and sellers. Firstly, land tenure systems differ significantly, ranging from freehold and leasehold to customary land rights. It is paramount to understand the specific tenure of a property before any transaction. Secondly, due diligence is non-negotiable. This involves verifying the authenticity of title deeds, checking for encumbrances (e.g., mortgages, caveats), and ensuring the seller has the legal right to dispose of the property. Engaging a local, reputable lawyer is crucial for this process. Thirdly, foreign ownership rules vary. Some countries have restrictions or specific requirements for non-citizens acquiring land. Fourthly, registration processes are vital for securing ownership. Property transfers must be registered with the relevant land registries to be legally recognized. Finally, taxes and fees associated with property transactions (e.g., stamp duty, capital gains tax) should be factored into the overall cost. Staying informed and seeking expert legal advice are the best ways to ensure a smooth and secure property transaction in East Africa."
    },
    {
      "id": "5",
      "title": "The Rise of Smart Homes: Technology in Real Estate",
      "image": "assets/images/blog5.webp",
      "category": "Technology",
      "date": "May 10, 2025",
      "snippet": "How smart home technology is transforming living spaces and property values in the modern era.",
      "content": "Smart home technology is rapidly evolving from a luxury to a standard expectation in modern real estate, fundamentally transforming how we interact with our living spaces. These integrated systems, which connect devices like lighting, thermostats, security cameras, and entertainment systems, offer unparalleled convenience, energy efficiency, and security. For homeowners, smart technology provides remote control over various aspects of their home, allowing them to adjust settings, monitor security, and even manage appliances from anywhere in the world via a smartphone app. This level of control enhances comfort and peace of mind. From a property value perspective, homes equipped with advanced smart features are increasingly attractive to buyers, often commanding higher prices and selling faster. Energy-saving smart thermostats and lighting systems appeal to environmentally conscious buyers and those looking to reduce utility bills. Enhanced security features, such as smart locks and surveillance systems, provide an added layer of safety. The integration of voice assistants and automated routines further streamlines daily life, making homes more intuitive and responsive to inhabitants' needs. As technology continues to advance, smart homes will become an even more integral part of the real estate landscape, redefining modern living."
    },
    {
      "id": "6",
      "title": "Affordable Housing Solutions for Urban Africa",
      "image": "assets/images/blog6.webp",
      "category": "Urban Development",
      "date": "April 22, 2025",
      "snippet": "Addressing the challenge of affordable housing in rapidly growing urban centers across Africa.",
      "content": "Rapid urbanization across Africa presents a significant challenge: providing adequate and affordable housing for its burgeoning urban populations. Traditional construction methods often struggle to keep pace with demand, leading to informal settlements and overcrowding. However, innovative solutions are emerging to tackle this critical issue. One key approach is the adoption of modular and prefabricated construction techniques, which significantly reduce building time and costs while maintaining quality. These methods allow for mass production of housing units, making them more accessible. Another strategy involves leveraging local materials and sustainable building practices, which not only lower expenses but also promote environmental responsibility. Governments and private developers are increasingly forming partnerships to implement large-scale affordable housing projects, often incorporating mixed-income developments to foster inclusive communities. Furthermore, innovative financing models, such as rent-to-own schemes, microfinance for housing, and public-private partnerships, are making homeownership more attainable for lower and middle-income households. Policy reforms that simplify land acquisition and streamline regulatory processes are also crucial. By combining technological innovation, sustainable practices, and supportive policies, urban Africa can move closer to ensuring that all its citizens have access to safe, decent, and affordable housing."
    },
  ];

  @override
  void dispose() {
    _newsletterEmailController.dispose();
    super.dispose();
  }

  // Common dialog for login/signup prompt
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sign Up'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/signup');
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A66C2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Login'),
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

  // Handles sign-out action
  Future<void> _handleSignOut() async {
    try {
      await widget.authService.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An unknown error occurred.";
      if (e.code == 'network-request-failed') {
        errorMessage =
            "Network error. Please check your internet connection and try again.";
      } else if (e.code == 'requires-recent-login') {
        errorMessage =
            "This operation is sensitive and requires recent authentication. Please log in again.";
      } else {
        errorMessage = "Sign out failed: ${e.message}";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred during sign out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isLargeScreen = screenWidth >= 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: isLargeScreen ? 60.0 : 16.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/sora_logo.png',
                      height: 45,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1E90FF),
                          child: const Center(
                            child: Icon(Icons.home, size: 45, color: Color(0xFF0A66C2)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SORA',
                      style: TextStyle(
                        color: Color(0xFF0A66C2),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLargeScreen)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildAppBarButton(
                          'Buy',
                              () {
                            Navigator.pushNamed(
                              context,
                              '/property_listings',
                              arguments: {'listingType': 'Buy'},
                            );
                          },
                          isSelected: _currentListingTypeFilter == 'Buy',
                        ),
                        const SizedBox(width: 20),
                        _buildAppBarButton(
                          'Rent',
                              () {
                            Navigator.pushNamed(
                              context,
                              '/property_listings',
                              arguments: {'listingType': 'Rent'},
                            );
                          },
                          isSelected: _currentListingTypeFilter == 'Rent',
                        ),
                        const SizedBox(width: 20),
                        _buildAppBarButton(
                          'Lease',
                              () {
                            Navigator.pushNamed(
                              context,
                              '/property_listings',
                              arguments: {'listingType': 'Lease'},
                            );
                          },
                        ),
                        const SizedBox(width: 40),
                        const SizedBox(width: 20),
                        _buildAppBarButton('List Property', () {
                          if (widget.authService.currentUserNotifier.value == null) {
                            _showLoginSignupDialog();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Redirecting to list property page (coming soon)!')),
                            );
                          }
                        }, isFilled: true),
                        const SizedBox(width: 20),
                        ValueListenableBuilder<User?>(
                          valueListenable: widget.authService.currentUserNotifier,
                          builder: (context, user, child) {
                            if (user != null) {
                              return PopupMenuButton<int>(
                                icon: CircleAvatar(
                                  backgroundColor: const Color(0xFF0A66C2),
                                  radius: 20,
                                  child: (user.email != null && user.email!.isNotEmpty)
                                      ? Text(
                                          user.email![0].toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        )
                                      : const Icon(Icons.person, color: Colors.white),
                                ),
                                onSelected: (item) {
                                  if (item == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Viewing profile for ${user.email ?? "User"}')),
                                    );
                                  } else if (item == 1) {
                                    _handleSignOut();
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<int>(
                                    value: 0,
                                    child: Text('View Profile'),
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 1,
                                    child: Text('Sign Out'),
                                  ),
                                ],
                              );
                            } else {
                              return _buildAppBarButton('Login', () {
                                Navigator.pushNamed(context, '/signin');
                              }, icon: Icons.login);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          actions: !isLargeScreen
              ? [
                  Builder(
                    builder: (BuildContext innerContext) {
                      return IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF0A66C2)),
                        onPressed: () {
                          Scaffold.of(innerContext).openEndDrawer();
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ]
              : null,
        ),
      ),
      endDrawer: !isLargeScreen
          ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 100.0,
              decoration: const BoxDecoration(
                color: Color(0xFF1E90FF),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ValueListenableBuilder<User?>(
                    valueListenable: widget.authService.currentUserNotifier,
                    builder: (context, user, child) {
                      return Text(
                        user != null ? 'Hello, ${user.email?.split('@').first ?? "User"}' : 'SORA Menu',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Builder(
              builder: (BuildContext innerContext) {
                return ListTile(
                  title: const Text('Buy'),
                  onTap: () {
                    Scaffold.of(innerContext).closeEndDrawer();
                    Navigator.pushNamed(
                      innerContext,
                      '/property_listings',
                      arguments: {'listingType': 'Buy'},
                    );
                  },
                );
              },
            ),
            Builder(
              builder: (BuildContext innerContext) {
                return ListTile(
                  title: const Text('Rent'),
                  onTap: () {
                    Scaffold.of(innerContext).closeEndDrawer();
                    Navigator.pushNamed(
                      innerContext,
                      '/property_listings',
                      arguments: {'listingType': 'Rent'},
                    );
                  },
                );
              },
            ),
            Builder(
              builder: (BuildContext innerContext) {
                return ListTile(
                  title: const Text('Lease'),
                  onTap: () {
                    Scaffold.of(innerContext).closeEndDrawer();
                    Navigator.pushNamed(
                      innerContext,
                      '/property_listings',
                      arguments: {'listingType': 'Lease'},
                    );
                  },
                );
              },
            ),
            Builder(
              builder: (BuildContext innerContext) {
                return ListTile(
                  title: const Text('Sell'),
                  onTap: () {
                    Scaffold.of(innerContext).closeEndDrawer();
                    if (widget.authService.currentUserNotifier.value == null) {
                      _showLoginSignupDialog();
                    } else {
                      ScaffoldMessenger.of(innerContext).showSnackBar(
                        const SnackBar(content: Text('Redirecting to sell property page (coming soon)!')),
                      );
                    }
                  },
                );
              },
            ),
            ListTile(
              title: const Text('Agents'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/agents');
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
            ListTile(
              title: const Text('Contact'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contact');
              },
            ),
            ListTile(
              title: const Text('Careers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/careers');
              },
            ),
            ListTile(
              title: const Text('Blog'), // Added Blog link
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/blogs');
              },
            ),
            ValueListenableBuilder<User?>(
              valueListenable: widget.authService.currentUserNotifier,
              builder: (context, user, child) {
                if (user != null) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0A66C2),
                      child: (user.email != null && user.email!.isNotEmpty)
                          ? Text(
                              user.email![0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            )
                          : const Icon(Icons.person, color: Colors.white),
                    ),
                    title: const Text('Logout'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      _handleSignOut();
                    },
                  );
                } else {
                  return ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Login'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/signin');
                    },
                  );
                }
              },
            ),
          ],
        ),
      )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section for Blog Page
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/blog_hero.webp'), // Placeholder image
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 80.0, left: 24.0, right: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Insights from the World of Real Estate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            // Blog Categories/Filter Section (Optional, but good for creativity)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('All', isSelected: true),
                    _buildCategoryChip('Market Trends'),
                    _buildCategoryChip('Investment'),
                    _buildCategoryChip('Sustainable Living'),
                    _buildCategoryChip('Legal Guide'),
                    _buildCategoryChip('Technology'),
                    _buildCategoryChip('Urban Development'),
                  ],
                ),
              ),
            ),
            // Main Blog Grid Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest Articles',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBlogGrid(isLargeScreen, isMediumScreen, isSmallScreen, _blogPosts),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // --- Footer ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 24.0),
              color: Colors.grey[100],
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isLargeScreen ? 1200 : (isMediumScreen ? 800 : double.infinity)),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 40.0,
                      runSpacing: 20.0,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFooterColumn('Sora', ['About', 'Agents', 'Contact', 'Careers', 'Blog', 'Testimonials'],
                          onLinkTapped: (linkText) {
                            if (linkText == 'About') {
                              Navigator.pushNamed(context, '/about');
                            } else if (linkText == 'Agents') {
                              Navigator.pushNamed(context, '/agents');
                            } else if (linkText == 'Contact') {
                              Navigator.pushNamed(context, '/contact');
                            } else if (linkText == 'Careers') {
                              Navigator.pushNamed(context, '/careers');
                            } else if (linkText == 'Blog') {
                              Navigator.pushNamed(context, '/blogs');
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$linkText functionality coming soon!')),
                              );
                            }
                          },
                        ),
                        _buildFooterColumn('Resources', ['Buy', 'Rent', 'Lease', 'FAQs', 'Support', 'Terms'],
                          onLinkTapped: (linkText) {
                            if (linkText == 'Buy') {
                              Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Buy'});
                            } else if (linkText == 'Rent') {
                              Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Rent'});
                            } else if (linkText == 'Lease') {
                              Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Lease'});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$linkText functionality coming soon!')),
                              );
                            }
                          },
                        ),
                        _buildFooterColumn('Community', ['Local Guides', 'Events'],
                          onLinkTapped: (linkText) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$linkText functionality coming soon!')),
                            );
                          },
                        ),
                        _buildFooterColumn('Legal', ['Privacy Policy', 'Terms of Service', 'Sitemap'],
                          onLinkTapped: (linkText) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$linkText functionality coming soon!')),
                            );
                          },
                        ),
                        _buildNewsletterSection(),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(FontAwesomeIcons.facebookF, 'Facebook', const Color(0xFF1877F2)),
                        const SizedBox(width: 20),
                        _buildSocialIcon(FontAwesomeIcons.discord, 'Discord', const Color(0xFF5865F2)),
                        const SizedBox(width: 20),
                        _buildSocialIcon(FontAwesomeIcons.linkedinIn, 'LinkedIn', const Color(0xFF0A66C2)),
                        const SizedBox(width: 20),
                        _buildSocialIcon(FontAwesomeIcons.instagram, 'Instagram', const Color(0xFFE1306C)),
                        const SizedBox(width: 20),
                        _buildSocialIcon(FontAwesomeIcons.tiktok, 'TikTok', Colors.black),
                        const SizedBox(width: 20),
                        _buildSocialIcon(FontAwesomeIcons.xTwitter, 'X (Twitter)', Colors.black),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    Text(
                      '© 2025 SORA Properties. All rights reserved.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      textAlign: TextAlign.center,
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

  // Helper method for AppBar buttons
  Widget _buildAppBarButton(String text, VoidCallback onPressed, {bool isSelected = false, bool isFilled = false, IconData? icon}) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : const Color(0xFF0A66C2),
        backgroundColor: isSelected ? const Color(0xFF0A66C2) : (isFilled ? const Color(0xFF0A66C2) : Colors.transparent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: isFilled ? BorderSide.none : const BorderSide(color: Color(0xFF0A66C2), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: isSelected || isFilled ? Colors.white : const Color(0xFF0A66C2)),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected || isFilled ? FontWeight.bold : FontWeight.normal,
              color: isSelected || isFilled ? Colors.white : const Color(0xFF0A66C2),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for Blog Category Chips
  Widget _buildCategoryChip(String text, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0A66C2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xFF0A66C2).withOpacity(isSelected ? 1.0 : 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Grid View for Blog Posts
  Widget _buildBlogGrid(bool isLargeScreen, bool isMediumScreen, bool isSmallScreen, List<Map<String, dynamic>> blogs) {
    int crossAxisCount;
    if (isLargeScreen) {
      crossAxisCount = 3;
    } else if (isMediumScreen) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the grid itself
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        childAspectRatio: isSmallScreen ? 0.8 : (isMediumScreen ? 0.9 : 1.0), // Adjust aspect ratio
      ),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        return _buildBlogCard(blogs[index]);
      },
    );
  }

  // Helper method for individual Blog Cards in the grid
  Widget _buildBlogCard(Map<String, dynamic> blog) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/blog_view',
          arguments: blog, // Pass the entire blog map to the view screen
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
              child: Image.asset(
                blog['image']!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog['category']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
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
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/blog_view',
                          arguments: blog,
                        );
                      },
                      icon: const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF1E90FF)),
                      label: const Text(
                        'Read More',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E90FF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for Footer columns
  Widget _buildFooterColumn(String title, List<String> links, {ValueChanged<String>? onLinkTapped}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A66C2),
          ),
        ),
        const SizedBox(height: 10),
        ...links.where((link) => link != 'Sell').map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () {
              if (onLinkTapped != null) {
                if (link == 'About') {
                  Navigator.pushNamed(context, '/about');
                } else if (link == 'Agents') {
                  Navigator.pushNamed(context, '/agents');
                } else if (link == 'Contact') {
                  Navigator.pushNamed(context, '/contact');
                } else if (link == 'Careers') {
                  Navigator.pushNamed(context, '/careers');
                } else if (link == 'Blog') {
                  Navigator.pushNamed(context, '/blogs');
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$link functionality coming soon!')),
                  );
                }
              }
            },
            child: Text(
              link,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        )).toList(),
      ],
    );
  }

  // Helper method for Newsletter section in Footer
  Widget _buildNewsletterSection() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscribe to our Newsletter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newsletterEmailController,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
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
    );
  }

  // Helper method for Social Icons in Footer
  Widget _buildSocialIcon(IconData icon, String socialMediaName, Color color) {
    return IconButton(
      icon: FaIcon(icon, size: 28, color: color),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $socialMediaName...')),
        );
      },
      tooltip: 'Visit our $socialMediaName page',
    );
  }
}
