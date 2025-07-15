// lib/screens/sell_property_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/widgets/common_widgets.dart';

class SellPropertyScreen extends StatelessWidget {
  final AuthService authService;

  const SellPropertyScreen({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            // Header Section
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
                    'Sell Your Property',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 38 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 10),
                  Text(
                    'Ready to sell? We make the process simple, fast, and rewarding.',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : 30,
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.house_siding,
                          size: isLargeScreen ? 120 : 80,
                          color: Color(0xFF0A66C2),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Sell Your Property Feature Coming Soon!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 28 : (isMediumScreen ? 24 : 20),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'We are working hard to bring you the best tools to list and sell your property with ease.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/contact');
                          },
                          icon: const Icon(Icons.email),
                          label: const Text('Contact Our Agents'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A66C2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isLargeScreen ? 60 : 30),
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }
}
