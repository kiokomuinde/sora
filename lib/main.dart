// /lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:sora_app/firebase_options.dart';
import 'package:sora_app/services/auth_service.dart'; // Import AuthService

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/property_listing_screen.dart';
import 'package:sora_app/screens/about_screen.dart';
import 'package:sora_app/screens/signin_screen.dart'; // Import SignInScreen
import 'package:sora_app/screens/signup_screen.dart'; // Import SignUpScreen


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize AuthService once and pass it down
  final AuthService authService = AuthService();

  runApp(SoraApp(authService: authService));
}

class SoraApp extends StatelessWidget {
  final AuthService authService; // Receive AuthService

  const SoraApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    Map<String, WidgetBuilder> appRoutes = {
      // SplashScreen only used on non-web, as per previous logic.
      // It will handle navigation to Onboarding or Home.
      '/': (context) => const SplashScreen(),
      '/home': (context) => HomeScreen(authService: authService), // Pass authService here
      '/property_listings': (context) => PropertyListingScreen(),
      '/about': (context) => AboutScreen(authService: authService), // Pass authService here!
      '/signin': (context) => SignInScreen(authService: authService), // New SignIn route
      '/signup': (context) => SignUpScreen(authService: authService), // New SignUp route
    };

    // Conditionally add the onboarding route ONLY if NOT on web
    if (!kIsWeb) {
      appRoutes['/onboarding'] = (context) => const OnboardingScreen();
    }

    return MaterialApp(
      title: 'SORA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      // Conditionally set the initial route based on platform
      initialRoute: kIsWeb ? '/home' : '/', // If web, go straight to home, otherwise go to splash
      routes: appRoutes, // Use the conditionally built routes map
    );
  }
}
