// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/firebase_options.dart';
import 'package:sora_app/services/auth_service.dart';
import 'dart:html' as html;
// Add the flutter_dotenv import
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
import 'screens/dashboard_screen.dart';
import 'screens/recently_viewed_screen.dart';
import 'screens/add_property_screen.dart';
// New screen for Airbnb
import 'screens/airbnb_screen.dart';
// New screen to view single property details
import 'screens/view_property_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the .env file
  await dotenv.load(fileName: "env.txt");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully for current platform.');
  } catch (e) {
    print('Error during Firebase initialization: $e');
  }

  AuthService? authService;
  if (Firebase.apps.isNotEmpty) {
    authService = AuthService(firebaseAuth: FirebaseAuth.instance);
  } else {
    print('AuthService not initialized because Firebase is not initialized.');
  }

  runApp(SoraApp(authService: authService));
}

class SoraApp extends StatelessWidget {
  final AuthService? authService;

  const SoraApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    if (authService == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
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

    final Map<String, WidgetBuilder> appRoutes = {
      '/splash': (context) => const SplashScreen(),
      '/onboarding': (context) => const OnboardingScreen(),
      '/home': (context) => HomeScreen(authService: authService!),
      '/buy': (context) => PropertyListingScreen(authService: authService!, listingType: 'Buy'),
      '/rent': (context) => PropertyListingScreen(authService: authService!, listingType: 'Rent'),
      '/lease': (context) => PropertyListingScreen(authService: authService!, listingType: 'Lease'),
      '/airbnb': (context) => AirbnbScreen(authService: authService!), // New Airbnb route
      '/about': (context) => AboutScreen(authService: authService!),
      '/signin': (context) => SignInScreen(authService: authService!),
      '/signup': (context) => SignUpScreen(authService: authService!),
      '/agents': (context) => AgentsScreen(authService: authService!),
      '/contact': (context) => ContactScreen(authService: authService!),
      '/careers': (context) => CareersScreen(authService: authService!),
      '/blogs': (context) => BlogsScreen(authService: authService!),
      '/blog_view': (context) => const BlogViewScreen(),
      '/testimonials': (context) => TestimonialsScreen(authService: authService!),
      '/faqs': (context) => FAQsScreen(authService: authService!),
      '/local_guides': (context) => LocalGuidesScreen(authService: authService!),
      '/terms_of_service': (context) => TermsOfServiceScreen(authService: authService!),
      '/sitemap': (context) => SitemapScreen(authService: authService!),
      '/support': (context) => SupportScreen(authService: authService!),
      '/events': (context) => EventsScreen(authService: authService!),
      '/privacy_policy': (context) => PrivacyPolicyScreen(authService: authService!),
      '/cookie_policy': (context) => CookiePolicyScreen(authService: authService!),
      '/disclaimer': (context) => DisclaimerScreen(authService: authService!),
      '/sell_property': (context) => SellPropertyScreen(authService: authService!),
      '/list_property': (context) => ListPropertyScreen(authService: authService!),
      '/my_favorites': (context) => MyFavoritesScreen(authService: authService!),
      '/my_listings': (context) => MyListingsScreen(authService: authService!),
      '/profile_settings': (context) => ProfileSettingsScreen(authService: authService!),
      '/dashboard': (context) => DashboardScreen(authService: authService!),
      '/recently_viewed': (context) => RecentlyViewedScreen(authService: authService!),
      '/add_property': (context) => AddPropertyScreen(authService: authService!),
      '/view_property': (context) => ViewPropertyScreen(authService: authService!, propertyData: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
    };

    String chosenInitialRoute;
    if (kIsWeb) {
      chosenInitialRoute = html.window.location.pathname ?? '/home';
      if (!appRoutes.keys.contains(chosenInitialRoute)) {
        chosenInitialRoute = '/home';
      }
    } else {
      chosenInitialRoute = '/splash';
    }

    print('App starting with initial route: $chosenInitialRoute (kIsWeb: $kIsWeb)');

    return MaterialApp(
      title: 'SORA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Inter'),
      ),
      initialRoute: chosenInitialRoute,
      routes: appRoutes,
      onUnknownRoute: (settings) {
        print('Unknown route attempted: ${settings.name}');
        return MaterialPageRoute(builder: (context) => Text('Error: Unknown route ${settings.name}'));
      },
    );
  }
}