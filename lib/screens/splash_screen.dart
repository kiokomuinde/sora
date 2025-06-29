// /lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
// kIsWeb import is no longer needed here as main.dart handles the web check
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Animation duration
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: -10, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // After a short delay (e.g., 3 seconds), determine navigation for mobile.
    // For web, main.dart already redirects directly to /home, so this logic won't run.
    Future.delayed(const Duration(seconds: 1), () async {
      final prefs = await SharedPreferences.getInstance();
      final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      if (hasSeenOnboarding) {
        // If onboarding has been seen, go straight to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // If onboarding has NOT been seen, go to the onboarding screen
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This SplashScreen widget will only be rendered on non-web platforms,
    // as main.dart handles the initial routing for web.
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient (Blue to Dodger Blue)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E90FF), // Dodger Blue
                  Color(0xFF007BFF), // Deeper Blue
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo with Fade and Scale Animation
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: ScaleTransition(
                      scale: _controller.drive(
                          Tween<double>(begin: 0.5, end: 1.0).chain(
                              CurveTween(curve: Curves.easeOutBack))),
                      child: Image.asset(
                        'assets/images/sora_logo.png', // Path to your transparent image asset
                        height: 220, // Increased size
                        width: 220,  // Increased size
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // App Title with Slide and Fade Animation
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOutCubic,
                      )),
                      child: const Text( // Added const for Text widget
                        "SORA",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black, // Changed color for shadow
                              offset: Offset(3.0, 3.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10), // Margin between name and slogan

                  // Slogan with Slide Animation
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: child,
                      );
                    },
                    child: Text(
                      "Real Estate, Redefined.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Loading Indicator with Glow Effect
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 0),
                        )
                      ],
                    ),
                    child: CircularProgressIndicator(
                      color: Colors.white.withOpacity(0.9),
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}