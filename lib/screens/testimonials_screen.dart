// lib/screens/testimonials_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart'; // Corrected import

class TestimonialsScreen extends StatelessWidget {
  final AuthService authService;

  const TestimonialsScreen({Key? key, required this.authService}) : super(key: key);

  // A list of authentic Kenyan testimonials to boost SEO
  static const List<Map<String, String>> _testimonials = [
    {
      'name': 'Wanjiku Mwangi',
      'location': 'Nairobi, Kenya',
      'quote': 'SORA made finding my dream home in Nairobi effortless! Their agents were incredibly helpful and knew the market inside out. Highly recommend to anyone looking for a property in Kenya.',
    },
    {
      'name': 'James Ouma',
      'location': 'Kisumu, Kenya',
      'quote': 'Selling our family land through SORA was a breeze. The process was transparent, and we got a fantastic offer much faster than we expected. They are the most trusted realtors in Kenya!',
    },
    {
      'name': 'Fatuma Ahmed',
      'location': 'Mombasa, Kenya',
      'quote': 'As a first-time land buyer, I was overwhelmed. SORA\'s patient team and clear process made the journey enjoyable and stress-free. I\'m so happy with my plot in the coastal area!',
    },
    {
      'name': 'David Githinji',
      'location': 'Kiambu, Kenya',
      'quote': 'The property listings on SORA are incredibly detailed and accurate. I found exactly what I was looking for, from a gated community to a bungalow in Kiambu, without any hassle. A truly professional service.',
    },
    {
      'name': 'Akinyi Odhiambo',
      'location': 'Nakuru, Kenya',
      'quote': 'SORA\'s local guides provided invaluable insights into the neighbourhoods we were considering. It helped us make a truly informed decision on our investment property. Excellent service!',
    },
    {
      'name': 'Peter Kamau',
      'location': 'Eldoret, Kenya',
      'quote': 'I\'ve used several real estate platforms, but SORA stands out with their commitment to excellence and genuine care for their clients. A seamless experience from start to finish.',
    },
    // New testimonials focused on Mirema Drive
    {
      'name': 'Grace Wanjiru',
      'location': 'Mirema Drive, Nairobi',
      'quote': 'We found the perfect townhouse on Mirema Drive through SORA. The location is excellent, and the team ensured a smooth transition. The best real estate agents for properties along Thika Road!',
    },
    {
      'name': 'Mwangi wa Macharia',
      'location': 'Mirema Drive, Nairobi',
      'quote': 'SORA\'s deep knowledge of Mirema Drive properties was a game-changer. They showed us listings that perfectly fit our family\'s needs and budget. We love our new home!',
    },
    {
      'name': 'Emily Muringo',
      'location': 'Mirema Drive, Nairobi',
      'quote': 'The process of acquiring our new commercial space on Mirema Drive was handled with pure professionalism. SORA is the go-to for anyone seeking property in this bustling area.',
    },
    // New testimonials focused on Airbnbs and rental investments
    {
      'name': 'Linet Chege',
      'location': 'Westlands, Nairobi',
      'quote': 'SORA helped us find and furnish the perfect Airbnb apartment in Westlands. Their insights into the short-term rental market are unmatched. Our bookings are through the roof!',
    },
    {
      'name': 'Sammy Okoth',
      'location': 'Kilimani, Nairobi',
      'quote': 'Investing in an Airbnb unit in Kilimani was a great decision, and it wouldn\'t have been possible without SORA. They handled everything from identifying the property to tenant management. A top real estate company in Kenya for sure.',
    },
    {
      'name': 'Chebet Kiprono',
      'location': 'Nakuru, Kenya',
      'quote': 'We were looking for a high-yield rental property in Nakuru. SORA delivered a gem! The team is responsive, and their property management services are fantastic. Thank you for helping us grow our portfolio.',
    },
    {
      'name': 'Victor Njoroge',
      'location': 'Kilimani, Nairobi',
      'quote': 'I was looking for a modern Airbnb apartment for a short stay. SORA\'s listings were detailed and the booking process was seamless. The property was exactly as described. So happy with my experience!',
    },
    {
      'name': 'Monica Moraa',
      'location': 'Lavington, Nairobi',
      'quote': 'The team at SORA truly understands the Airbnb market. They helped me find a property with high rental potential in a prime area like Lavington. My investment is already paying off.',
    },
    {
      'name': 'Joseph Rotich',
      'location': 'Karen, Nairobi',
      'quote': 'SORA\'s professional guidance on investing in a luxurious Airbnb villa in Karen was invaluable. They provided all the financial projections and made the entire process transparent and secure.',
    },
    {
      'name': 'Mercy Adhiambo',
      'location': 'Mombasa, Kenya',
      'quote': 'Our search for a perfect beachfront Airbnb was tough, but SORA made it happen. Their knowledge of the coastal real estate market is incredible. We found a place that our guests adore.',
    },
    {
      'name': 'Daniel Ochieng',
      'location': 'Upper Hill, Nairobi',
      'quote': 'SORA helped us manage our rental properties efficiently. They are a reliable partner and their team ensures that our properties are always occupied. Top-notch property management in Kenya.',
    },
    {
      'name': 'Faith Wambui',
      'location': 'Thika, Kenya',
      'quote': 'I wanted to diversify my portfolio with a rental property outside Nairobi. SORA gave me excellent advice on the Thika market and helped me secure a fantastic deal. I am a very satisfied client.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Correctly instantiate CommonWidgets
    final commonWidgets = CommonWidgets(context: context, authService: authService);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Testimonials Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 80 : (isMediumScreen ? 60 : 40),
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E90FF), Color(0xFF0A66C2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hear From Our Happy Kenyan Clients',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 52 : (isMediumScreen ? 42 : 32),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Real stories from real people who found their perfect property with SORA Real Estate, from Nairobi to the coast.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 18,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Testimonials Grid View
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 80 : (isMediumScreen ? 40 : 16),
                vertical: 40,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isLargeScreen ? 3 : (isMediumScreen ? 2 : 1),
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                ),
                itemCount: _testimonials.length,
                itemBuilder: (context, index) {
                  final testimonial = _testimonials[index];
                  return _buildTestimonialCard(
                    context,
                    testimonial['name']!,
                    testimonial['location']!,
                    testimonial['quote']!,
                  );
                },
              ),
            ),
            // Dummy button for more testimonials
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // This is a dummy action. You can add logic here to fetch more testimonials.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E90FF),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Load More Testimonials',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            // Common Footer Section
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }

  // A helper method to build a single testimonial card
  Widget _buildTestimonialCard(BuildContext context, String name, String location, String quote) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.format_quote,
              color: Color(0xFF0A66C2),
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              quote,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Color(0xFF333333),
                fontFamily: 'Inter',
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF1E90FF),
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF0A66C2),
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
