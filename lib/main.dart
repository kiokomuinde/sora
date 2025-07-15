// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type
import 'package:sora_app/firebase_options.dart'; // Assuming this file exists and provides DefaultFirebaseOptions
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'dart:html' as html; // Import for dart:html for web paths (still needed for location.pathname)

// New screens
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/property_listing_screen.dart';
import 'screens/about_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/agents_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/careers_screen.dart';
import 'screens/blogs_screen.dart';
import 'screens/blog_view_screen.dart';
import 'screens/testimonials_screen.dart';
import 'screens/faqs_screen.dart';
import 'screens/local_guides_screen.dart';
import 'screens/terms_of_service_screen.dart';
import 'screens/sitemap_screen.dart';
import 'screens/support_screen.dart';
import 'screens/events_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/cookie_policy_screen.dart';
import 'screens/disclaimer_screen.dart';
import 'screens/sell_property_screen.dart';
import 'screens/list_property_screen.dart';
import 'screens/my_favorites_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/profile_settings_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using DefaultFirebaseOptions for all platforms
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully for current platform.');
  } catch (e) {
    print('Error during Firebase initialization: $e');
    // You might want to show an error screen or dialog here
  }

  // Initialize AuthService ONLY if Firebase has been successfully initialized
  AuthService? authService;
  if (Firebase.apps.isNotEmpty) {
    // Pass FirebaseAuth.instance to AuthService constructor
    authService = AuthService(firebaseAuth: FirebaseAuth.instance);
  } else {
    print('AuthService not initialized because Firebase is not initialized.');
  }

  runApp(SoraApp(authService: authService));
}

class SoraApp extends StatelessWidget {
  final AuthService? authService; // Now nullable

  const SoraApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    // If authService is null, it means Firebase initialization failed.
    // Display a loading indicator or an error message.
    if (authService == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Initializing app... Please ensure Firebase is configured correctly.'),
              ],
            ),
          ),
        ),
      );
    }

    // Define routes with AuthService passed to each screen
    final Map<String, WidgetBuilder> appRoutes = {
      '/splash': (context) => const SplashScreen(),
      '/onboarding': (context) => const OnboardingScreen(),
      '/home': (context) => HomeScreen(authService: authService!), // Use ! because we checked for null above
      '/buy': (context) => PropertyListingScreen(authService: authService!, listingType: 'Buy'),
      '/rent': (context) => PropertyListingScreen(authService: authService!, listingType: 'Rent'),
      '/lease': (context) => PropertyListingScreen(authService: authService!, listingType: 'Lease'),
      '/about': (context) => AboutScreen(authService: authService!),
      '/signin': (context) => SignInScreen(authService: authService!),
      '/signup': (context) => SignUpScreen(authService: authService!),
      '/agents': (context) => AgentsScreen(authService: authService!),
      '/contact': (context) => ContactScreen(authService: authService!),
      '/careers': (context) => CareersScreen(authService: authService!),
      '/blogs': (context) => BlogsScreen(authService: authService!),
      '/blog_view': (context) => const BlogViewScreen(), // BlogViewScreen gets blog data via arguments
      '/testimonials': (context) => TestimonialsScreen(authService: authService!),
      '/faqs': (context) => FAQsScreen(authService: authService!),
      '/local_guides': (context) => LocalGuidesScreen(authService: authService!),
      '/terms_of_service': (context) => TermsOfServiceScreen(authService: authService!),
      '/sitemap': (context) => SitemapScreen(authService: authService!),
      '/support': (context) => SupportScreen(authService: authService!),
      '/events': (context) => EventsScreen(authService: authService!),

      // New placeholder routes
      '/privacy_policy': (context) => PrivacyPolicyScreen(authService: authService!),
      '/cookie_policy': (context) => CookiePolicyScreen(authService: authService!),
      '/disclaimer': (context) => DisclaimerScreen(authService: authService!),
      '/sell_property': (context) => SellPropertyScreen(authService: authService!),
      '/list_property': (context) => ListPropertyScreen(authService: authService!),
      '/my_favorites': (context) => MyFavoritesScreen(authService: authService!),
      '/my_listings': (context) => MyListingsScreen(authService: authService!),
      '/profile_settings': (context) => ProfileSettingsScreen(authService: authService!),
    };

    // Determine the initial route based on platform
    String chosenInitialRoute;
    if (kIsWeb) {
      // On web, always start at home or the requested path if provided
      // Ensure pathname is not null before assigning
      chosenInitialRoute = html.window.location.pathname ?? '/home'; // Added null-aware operator and fallback
      if (!appRoutes.keys.contains(chosenInitialRoute)) {
        chosenInitialRoute = '/home'; // Fallback to home if path is not a defined route
      }
    } else {
      // On mobile, use the splash screen to determine onboarding status
      chosenInitialRoute = '/splash';
    }

    print('App starting with initial route: $chosenInitialRoute (kIsWeb: $kIsWeb)');

    return MaterialApp(
      title: 'SORA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        // Set Inter as the default font for the entire app
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Inter'),
      ),
      // Conditionally set the initial route based on platform
      initialRoute: chosenInitialRoute,
      routes: appRoutes, // Use the conditionally built routes map
      onUnknownRoute: (settings) {
        // Handle unknown routes, e.g., navigate to a 404 page or home
        print('Unknown route attempted: ${settings.name}'); // Debug print for unknown routes
        return MaterialPageRoute(builder: (context) => Text('Error: Unknown route ${settings.name}'));
      },
    );
  }
}
