// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/firebase_options.dart';
import 'package:sora_app/services/auth_service.dart';
import 'package:sora_app/services/firestore_service.dart'; 
import 'dart:html' as html;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// CRITICAL: Import for PathUrlStrategy
import 'package:flutter_web_plugins/url_strategy.dart'; 

// SEO Packages
import 'package:meta_seo/meta_seo.dart';
import 'package:seo/seo.dart'; // <-- Updated import

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
import 'screens/add_property_screen.dart';
import 'screens/view_property_screen.dart';
import 'screens/my_favorites_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/profile_settings_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/recently_viewed_screen.dart';
import 'screens/create_blog_screen.dart'; 
import 'screens/admin_screen.dart';

void main() async {
  // 1. THIS MUST BE FIRST for Web SEO/Clean URLs
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Meta SEO for web crawlers
  if (kIsWeb) {
    MetaSEO().config();
  }

  try {
    await dotenv.load(fileName: "env.txt");
  } catch (e) {
    debugPrint("Error loading env file: $e");
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final AuthService authService = AuthService(firebaseAuth: FirebaseAuth.instance);
  final FirestoreService firestoreService = FirestoreService(); 
  
  // Removed RobotDetector. runApp now simply launches the app.
  runApp(
    MyApp(
      authService: authService,
      firestoreService: firestoreService, 
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final FirestoreService firestoreService;

  const MyApp({
    Key? key, 
    required this.authService,
    required this.firestoreService, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Improved initial route logic for Web
    String chosenInitialRoute = '/home';
    if (kIsWeb) {
      final path = html.window.location.pathname;
      if (path != null && path != '/' && path.isNotEmpty) {
        chosenInitialRoute = path;
      }
    } else {
      chosenInitialRoute = '/splash';
    }

    // 3. Wrap MaterialApp with SeoController here in the build method
    return SeoController(
      enabled: true,
      tree: WidgetTree(context: context),
      child: MaterialApp(
        title: 'Sora Properties',
        debugShowCheckedModeBanner: false,
        // Removed seoRouteObserver from navigatorObservers
        theme: ThemeData.light().copyWith(
          textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Inter'),
        ),
        initialRoute: chosenInitialRoute,
        onGenerateRoute: (settings) {
          // This handles deep links like /view_property/some-id-123
          final uri = Uri.parse(settings.name ?? '/home');
          final pathSegments = uri.pathSegments;

          String routeName = pathSegments.isEmpty ? '/home' : '/${pathSegments.first}';
          String? parameter = pathSegments.length > 1 ? pathSegments[1] : null;

          switch (routeName) {
            case '/splash':
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case '/onboarding':
              return MaterialPageRoute(builder: (_) => const OnboardingScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => HomeScreen(authService: authService));
              
            case '/property_listing':
            case '/buy':
            case '/rent':
            case '/lease':
            case '/airbnb':
              String type = routeName == '/property_listing' ? (parameter ?? '') : routeName.substring(1);
              return MaterialPageRoute(builder: (_) => PropertyListingScreen(
                authService: authService,
                listingType: type,
              ));
              
            case '/view_property':
              // Logic for sharing valid links: /view_property/PROPERTY_ID
              String? id = parameter;
              if (settings.arguments is Map<String, dynamic>) {
                final args = settings.arguments as Map<String, dynamic>;
                id = args['id'];
              }
              return MaterialPageRoute(builder: (_) => ViewPropertyScreen(
                authService: authService,
                propertyId: id,
              ));
              
            case '/add_property':
              return MaterialPageRoute(builder: (_) => AddPropertyScreen(authService: authService));
            case '/about':
              return MaterialPageRoute(builder: (_) => AboutScreen(authService: authService));
            case '/signin':
              return MaterialPageRoute(builder: (_) => SignInScreen(authService: authService));
            case '/signup':
              return MaterialPageRoute(builder: (_) => SignUpScreen(authService: authService));
            case '/agents':
              return MaterialPageRoute(builder: (_) => AgentsScreen(authService: authService));
            case '/contact':
              return MaterialPageRoute(builder: (_) => ContactScreen(authService: authService));
            case '/careers':
              return MaterialPageRoute(builder: (_) => CareersScreen(authService: authService));
            case '/blogs':
              return MaterialPageRoute(builder: (_) => BlogsScreen(authService: authService));
              
            case '/blog_view':
              String? slug = parameter;
              if (settings.arguments is Map<String, dynamic>) {
                final args = settings.arguments as Map<String, dynamic>;
                slug = args['blogId'];
              }
              return MaterialPageRoute(
                builder: (_) => BlogViewScreen(
                  authService: authService,
                  blogSlug: slug,
                )
              );
              
            case '/create_blog':
              return MaterialPageRoute(builder: (_) => CreateBlogScreen(authService: authService));
            case '/testimonials':
              return MaterialPageRoute(builder: (_) => TestimonialsScreen(authService: authService));
            case '/faqs':
              return MaterialPageRoute(builder: (_) => FAQsScreen(authService: authService));
            case '/local_guides':
              return MaterialPageRoute(builder: (_) => LocalGuidesScreen(authService: authService));
            case '/terms': 
              return MaterialPageRoute(builder: (_) => TermsOfServiceScreen(authService: authService));
            case '/sitemap':
              return MaterialPageRoute(builder: (_) => SitemapScreen(authService: authService));
            case '/support':
              return MaterialPageRoute(builder: (_) => SupportScreen(authService: authService));
            case '/events':
              return MaterialPageRoute(builder: (_) => EventsScreen(authService: authService));
            case '/privacy': 
              return MaterialPageRoute(builder: (_) => PrivacyPolicyScreen(authService: authService));
            case '/cookies': 
              return MaterialPageRoute(builder: (_) => CookiePolicyScreen(authService: authService));
            case '/my_favorites':
              return MaterialPageRoute(builder: (_) => MyFavoritesScreen(authService: authService, firestoreService: firestoreService));
            case '/my_listings':
              return MaterialPageRoute(builder: (_) => MyListingsScreen(authService: authService));
            case '/profile_settings':
              return MaterialPageRoute(builder: (_) => ProfileSettingsScreen(authService: authService));
            case '/dashboard':
              return MaterialPageRoute(builder: (_) => DashboardScreen(authService: authService));
            case '/admin': 
              return MaterialPageRoute(builder: (_) => AdminScreen(authService: authService));
            case '/recently_viewed':
              return MaterialPageRoute(builder: (_) => RecentlyViewedScreen(authService: authService));
            default:
              return MaterialPageRoute(builder: (_) => HomeScreen(authService: authService));
          }
        },
      ),
    );
  }
}