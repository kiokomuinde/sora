// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type
import 'package:sora_app/firebase_options.dart'; // Assuming this file exists and provides DefaultFirebaseOptions
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'dart:convert'; // Import for jsonDecode
import 'dart:js' as js; // Import for dart:js to interact with JS global objects

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/property_listing_screen.dart'; // This is the correct import for your full PropertyListingScreen
import 'package:sora_app/screens/about_screen.dart';
import 'package:sora_app/screens/signin_screen.dart';
import 'package:sora_app/screens/signup_screen.dart';
import 'package:sora_app/screens/agents_screen.dart';
import 'package:sora_app/screens/contact_screen.dart';
import 'package:sora_app/screens/careers_screen.dart';
import 'package:sora_app/screens/blogs_screen.dart';
import 'package:sora_app/screens/blog_view_screen.dart';

// New screens
import 'package:sora_app/screens/testimonials_screen.dart';
import 'package:sora_app/screens/faqs_screen.dart';
import 'package:sora_app/screens/support_screen.dart';
import 'package:sora_app/screens/terms_screen.dart';
import 'package:sora_app/screens/local_guides_screen.dart';
import 'package:sora_app/screens/events_screen.dart';
import 'package:sora_app/screens/terms_of_service_screen.dart';
import 'package:sora_app/screens/sitemap_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Access Firebase config and auth token from global JavaScript scope if on web
  Map<String, dynamic> firebaseConfig = {};
  String initialAuthToken = '';

  if (kIsWeb) {
    if (js.context.hasProperty('__firebase_config')) {
      try {
        firebaseConfig = jsonDecode(js.context['__firebase_config'] as String);
        print('Firebase config loaded from JS context.');
      } catch (e) {
        print('Error parsing __firebase_config from JS context: $e');
      }
    }
    if (js.context.hasProperty('__initial_auth_token')) {
      initialAuthToken = js.context['__initial_auth_token'] as String;
      print('Initial auth token loaded from JS context.');
    }
  }

  try {
    if (firebaseConfig['apiKey'] != null && (firebaseConfig['apiKey'] as String).isNotEmpty) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: firebaseConfig['apiKey'] as String,
          appId: firebaseConfig['appId'] as String,
          messagingSenderId: firebaseConfig['messagingSenderId'] as String,
          projectId: firebaseConfig['projectId'] as String,
          authDomain: firebaseConfig['authDomain'] as String?,
          databaseURL: firebaseConfig['databaseURL'] as String?,
          storageBucket: firebaseConfig['storageBucket'] as String?,
        ),
      );
      print('Firebase initialized with provided config.');
    } else {
      // Fallback for local development or if config not provided by JS context
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized with DefaultFirebaseOptions.');
    }
  } catch (e) {
    print('Error during Firebase initialization: $e');
    // If Firebase initialization fails, the app might not function correctly,
    // but we still try to runApp to avoid a blank screen.
  }

  // Initialize AuthService once and pass it down
  final AuthService authService = AuthService();

  // Sign in anonymously if no initial auth token is provided or custom token fails
  final auth = FirebaseAuth.instance;
  try {
    if (initialAuthToken.isNotEmpty) {
      try {
        await auth.signInWithCustomToken(initialAuthToken);
        print('Signed in with custom token successfully.');
      } on FirebaseAuthException catch (e) {
        print('Firebase Auth Error with custom token: ${e.code} - ${e.message}');
        // If custom token fails, try anonymous sign-in
        await auth.signInAnonymously();
        print('Signed in anonymously as a fallback from custom token failure.');
      } catch (e) {
        print('Unexpected error during custom token sign-in: $e');
        // If custom token fails for other reasons, try anonymous sign-in
        await auth.signInAnonymously();
        print('Signed in anonymously as a fallback from unexpected custom token error.');
      }
    } else {
      // If no initial auth token, sign in anonymously
      await auth.signInAnonymously();
      print('No initial auth token, signed in anonymously.');
    }
  } catch (e) {
    print('Error during Firebase authentication (anonymous or custom token): $e');
    // If authentication itself fails, the app might still run but without auth.
  }

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
      '/': (context) => const SplashScreen(), // This route is only active if !kIsWeb
      '/home': (context) => HomeScreen(authService: authService),
      '/property_listings': (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
        return PropertyListingScreen( // This will now correctly refer to the imported Stateful Widget
          authService: authService, // Ensure authService is passed
          listingType: args?['listingType'] ?? '',
        );
      },
      '/about': (context) => AboutScreen(authService: authService),
      '/signin': (context) => SignInScreen(authService: authService),
      '/signup': (context) => SignUpScreen(authService: authService),
      '/agents': (context) => AgentsScreen(authService: authService),
      '/contact': (context) => ContactScreen(authService: authService),
      '/careers': (context) => CareersScreen(authService: authService),
      '/blogs': (context) => BlogsScreen(authService: authService),
      '/blog_view': (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return BlogViewScreen(
          authService: authService, // Ensure authService is passed
          blogPost: args, // Pass the blog post data
        );
      },
      // New routes for the requested screens
      '/testimonials': (context) => TestimonialsScreen(authService: authService),
      '/faqs': (context) => FAQsScreen(authService: authService),
      '/support': (context) => SupportScreen(authService: authService),
      '/terms': (context) => TermsScreen(authService: authService),
      '/local_guides': (context) => LocalGuidesScreen(authService: authService),
      '/events': (context) => EventsScreen(authService: authService),
      '/terms_of_service': (context) => TermsOfServiceScreen(authService: authService),
      '/sitemap': (context) => SitemapScreen(authService: authService),
    };

    // Conditionally add the onboarding route ONLY if NOT on web
    if (!kIsWeb) {
      appRoutes['/onboarding'] = (context) => const OnboardingScreen();
    }

    // Debug print for initial route
    final String chosenInitialRoute = kIsWeb ? '/home' : '/';
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

// Placeholder class for BlogViewScreen (if it's still a placeholder in its own file)
// If you have a full BlogViewScreen in lib/screens/blog_view_screen.dart, you should remove this placeholder too.
class BlogViewScreen extends StatelessWidget {
  final AuthService authService;
  final Map<String, dynamic>? blogPost;

  const BlogViewScreen({Key? key, required this.authService, this.blogPost}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(blogPost?['title'] ?? 'Blog Post')),
      body: Center(child: Text('Blog View Screen for ${blogPost?['title'] ?? 'a blog post'}')),
    );
  }
}
