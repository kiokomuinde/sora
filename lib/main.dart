// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sora_app/firebase_options.dart';
import 'package:sora_app/services/auth_service.dart';
import 'dart:html' as html;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// 🎯 CRITICAL: Import for PathUrlStrategy
import 'package:flutter_web_plugins/url_strategy.dart'; 

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "env.txt");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  final AuthService authService = AuthService(firebaseAuth: FirebaseAuth.instance);
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String chosenInitialRoute;
    if (kIsWeb) {
      chosenInitialRoute = html.window.location.pathname ?? '/home';
    } else {
      chosenInitialRoute = '/splash';
    }

    return MaterialApp(
      title: 'SORA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Inter'),
      ),
      initialRoute: chosenInitialRoute,
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);
        final pathSegments = uri.pathSegments;

        String routeName;
        if (pathSegments.isEmpty) {
          routeName = '/home';
        } else {
          routeName = '/${pathSegments.first}';
        }

        String? parameter;
        if (pathSegments.length > 1) {
          parameter = pathSegments[1];
        }

        switch (routeName) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => HomeScreen(authService: authService));
            
          case '/property_listing':
            String listingType = parameter ?? '';
            if (settings.arguments is Map<String, dynamic>) {
                final args = settings.arguments as Map<String, dynamic>;
                listingType = args['listingType'] ?? listingType;
            }
            return MaterialPageRoute(builder: (_) => PropertyListingScreen(
              authService: authService,
              listingType: listingType,
            ));
            
          case '/buy':
          case '/rent':
          case '/lease':
          case '/airbnb':
            String listingType = routeName.substring(1); 
            if (settings.arguments is Map<String, dynamic>) {
                final args = settings.arguments as Map<String, dynamic>;
                listingType = args['listingType'] ?? listingType;
            }
            return MaterialPageRoute(builder: (_) => PropertyListingScreen(
              authService: authService,
              listingType: listingType,
            ));
            
          case '/view_property':
            if (settings.arguments is Map<String, dynamic>) {
                final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(builder: (_) => ViewPropertyScreen(authService: authService, propertyData: args));
            }
            return MaterialPageRoute(builder: (_) => PropertyListingScreen(authService: authService));
            
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
            // 1. Internal Navigation
            if (settings.arguments is Map<String, dynamic>) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (_) => BlogViewScreen(
                    blogPost: args, 
                    authService: authService,
                    blogSlug: args['blogId'] as String?, 
                  )
                );
            } 
            // 2. Deep Link
            else if (parameter != null) {
                return MaterialPageRoute(
                  builder: (_) => BlogViewScreen(
                    authService: authService,
                    blogSlug: parameter, 
                    blogPost: null, 
                  )
                );
            } else {
                return MaterialPageRoute(builder: (_) => BlogsScreen(authService: authService));
            }
            
          case '/create_blog':
            return MaterialPageRoute(builder: (_) => CreateBlogScreen(authService: authService));
          case '/testimonials':
            return MaterialPageRoute(builder: (_) => TestimonialsScreen(authService: authService));
          case '/faqs':
            return MaterialPageRoute(builder: (_) => FAQsScreen(authService: authService));
          case '/local_guides':
            return MaterialPageRoute(builder: (_) => LocalGuidesScreen(authService: authService));
          case '/terms_of_service':
            return MaterialPageRoute(builder: (_) => TermsOfServiceScreen(authService: authService));
          case '/sitemap':
            return MaterialPageRoute(builder: (_) => SitemapScreen(authService: authService));
          case '/support':
            return MaterialPageRoute(builder: (_) => SupportScreen(authService: authService));
          case '/events':
            return MaterialPageRoute(builder: (_) => EventsScreen(authService: authService));
          case '/privacy_policy':
            return MaterialPageRoute(builder: (_) => PrivacyPolicyScreen(authService: authService));
          case '/cookie_policy':
            return MaterialPageRoute(builder: (_) => CookiePolicyScreen(authService: authService));
          case '/my_favorites':
            return MaterialPageRoute(builder: (_) => MyFavoritesScreen(authService: authService));
          case '/my_listings':
            return MaterialPageRoute(builder: (_) => MyListingsScreen(authService: authService));
          case '/profile_settings':
            return MaterialPageRoute(builder: (_) => ProfileSettingsScreen(authService: authService));
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => DashboardScreen(authService: authService));
          case '/recently_viewed':
            return MaterialPageRoute(builder: (_) => RecentlyViewedScreen(authService: authService));
          default:
            return MaterialPageRoute(builder: (context) {
              return HomeScreen(authService: authService);
            });
        }
      },
    );
  }
}