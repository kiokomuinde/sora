// /lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sora_app/screens/property_detail_screen.dart'; // Make sure this path is correct
import 'package:sora_app/screens/property_listing_screen.dart'; // Import the property listing screen
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import for Font Awesome icons
import 'package:sora_app/screens/about_screen.dart'; // Import the AboutScreen
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type
import 'dart:ui'; // Import for ImageFilter

class HomeScreen extends StatefulWidget {
  final AuthService authService; // Receive AuthService

  const HomeScreen({super.key, required this.authService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Although carousels are removed, keeping controllers if they might be used elsewhere
  // in future iterations or there's a possibility to bring carousels back.
  // For now, they are not actively used in the UI.
  late ScrollController _featuredScrollController;
  late ScrollController _trendingScrollController;
  late ScrollController _recommendedScrollController;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newsletterEmailController = TextEditingController();

  String _currentListingTypeFilter = '';

  // Removed _isLoggedIn and _currentUser state variables here as they are now directly
  // accessed via widget.authService.currentUserNotifier in the ValueListenableBuilder.
  // This simplifies state management and ensures direct reactivity.

  final List<Map<String, dynamic>> allProperties = [
    {
      "title": "5-Bedroom Mansion - Ongata Rongai",
      "price": "KSH 20,000,000",
      "location": "Olekasasi, Ongata Rongai",
      "images": [
        "assets/images/image1.jpeg",
        "assets/images/image1_1.webp",
        "assets/images/image1_2.webp",
        "assets/images/image1_3.webp",
        "assets/images/image1_4.webp",
        "assets/images/image1_5.webp"
      ],
      "bedrooms": 5,
      "bathrooms": 6,
      "area": "7000",
      "type": "Mansion",
      "listingType": "Buy",
      "description": "A beautiful 3-bedroom mansion located in Olekasasi town. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },
    {
      "title": "Studio Apartment - Kilimani",
      "price": "KSH 20,000/month",
      "location": "Kilimani, Nairobi",
      "images": [
        "assets/images/image2.webp",
        "assets/images/image2_1.webp",
        "assets/images/image2_2.webp",
        "assets/images/image2_3.webp",
        "assets/images/image2_4.webp",
        "assets/images/image2_5.webp"
      ],
      "bedrooms": 1,
      "bathrooms": 1,
      "area": "600",
      "type": "Apartment",
      "listingType": "Rent",
      "description": "Modern studio apartment located in Kilimani, Nairobi. Close to shops, schools, and transport hubs.",
      "isFavorite": false,
    },
    {
      "title": "Luxury Villa - Karen",
      "price": "KSH 80,000,000",
      "location": "Karen, Nairobi",
      "images": [
        "assets/images/image3.webp",
        "assets/images/image3_1.webp",
        "assets/images/image3_2.webp",
        "assets/images/image3_3.webp",
        "assets/images/image3_4.webp",
        "assets/images/image3_5.webp"
      ],
      "bedrooms": 4,
      "bathrooms": 5,
      "area": "5000",
      "type": "Villa",
      "listingType": "Buy",
      "description": "Luxurious villa with top-notch finishes. Includes private pool, garage, and security system.",
      "isFavorite": false,
    },
    {
      "title": "Luxury Mansion - Runda",
      "price": "KSH 110,000,000",
      "location": "Runda, Nairobi",
      "images": [
        "assets/images/image4.webp",
        "assets/images/image4_1.webp",
        "assets/images/image4_2.webp",
        "assets/images/image4_3.webp",
        "assets/images/image4_4.webp",
        "assets/images/image4_5.webp"
      ],
      "bedrooms": 4,
      "bathrooms": 5,
      "area": "1 acre",
      "type": "Mansion",
      "listingType": "Buy",
      "description": "Luxurious mansion with top-notch finishes. Includes private pool, garage, and security system.",
      "isFavorite": false,
    },
    {
      "title": "Office Space - Westlands",
      "price": "KSH 2,400,000/year", // Adjusted from /month to /year (200,000 * 12)
      "location": "Westlands, Nairobi",
      "images": [
        "assets/images/image5.webp",
        "assets/images/image5_1.webp",
        "assets/images/image5_2.webp",
        "assets/images/image5_3.webp",
        "assets/images/image5_4.webp",
        "assets/images/image5_5.webp"
      ],
      "bedrooms": 0,
      "bathrooms": 3,
      "area": "2500",
      "type": "Commercial",
      "listingType": "Lease",
      "description": "Spacious office space available for rent in Westlands, Nairobi. Ideal for businesses looking for central location.",
      "isFavorite": false,
    },
    {
      "title": "Office Space - Nairobi CBD",
      "price": "KSH 1,800,000/year",
      "location": "CBD, Nairobi",
      "images": [
        "assets/images/image6.webp",
        "assets/images/image6_1.webp",
        "assets/images/image6_2.webp",
        "assets/images/image6_3.webp",
        "assets/images/image6_4.webp",
        "assets/images/image6_5.webp"
      ],
      "bedrooms": 0,
      "bathrooms": 5,
      "area": "4500",
      "type": "Commercial",
      "listingType": "Lease",
      "description": "Spacious office space available for rent in Westlands, Nairobi. Ideal for businesses looking for central location.",
      "isFavorite": false,
    },
    {
      "title": "6 Bedroom Luxury Villa - Kileleshwa",
      "price": "KSH 180,000,000",
      "location": "Kileleshwa, Nairobi",
      "images": [
        "assets/images/image7.webp",
        "assets/images/image7_1.webp",
        "assets/images/image7_2.webp",
        "assets/images/image7_3.webp",
        "assets/images/image7_4.webp",
        "assets/images/image7_5.webp"
      ],
      "bedrooms": 6,
      "bathrooms": 8,
      "area": "7000",
      "type": "Villa",
      "listingType": "Buy",
      "description": "Luxurious villa with top-notch finishes. Includes private pool, garage, and security system.",
      "isFavorite": false,
    },
    {
      "title": "4-Bedroom Mansion - Lavington",
      "price": "KSH 100,000,000",
      "location": "Lavington, Nairobi",
      "images": [
        "assets/images/image8.webp",
        "assets/images/image8_1.webp",
        "assets/images/image8_2.webp",
        "assets/images/image8_3.webp",
        "assets/images/image8_4.webp",
        "assets/images/image8_5.webp"
      ],
      "bedrooms": 4,
      "bathrooms": 5,
      "area": "5000",
      "type": "Mansion",
      "listingType": "Buy",
      "description": "A beautiful 4-bedroom mansion located in Olekasasi town. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },
    {
      "title": "4-Bedroom Bungalow - Kitusuru",
      "price": "KSH 100,000,000",
      "location": "Lavington, Nairobi",
      "images": [
        "assets/images/image9.webp",
        "assets/images/image9_1.webp",
        "assets/images/image9_2.webp",
        "assets/images/image9_3.webp",
        "assets/images/image9_4.webp",
        "assets/images/image9_5.webp"
      ],
      "bedrooms": 4,
      "bathrooms": 5,
      "area": "6000", // Area in sq ft or sq meters
      "type": "Bungalow",
      "listingType": "Buy",
      "description":
          "A beautiful 4-bedroom bungalow located in Kitusuru. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "6-Bedroom Bungalow - Muthaiga",
      "price": "KSH 200,000/month",
      "location": "Muthaiga, Nairobi",
      "images": [
        "assets/images/image10.webp",
        "assets/images/image10_1.webp",
        "assets/images/image10_2.webp",
        "assets/images/image10_3.webp",
        "assets/images/image10_4.webp",
        "assets/images/image10_5.webp"
      ],
      "bedrooms": 6,
      "bathrooms": 7,
      "area": "5000", // Area in sq ft or sq meters
      "type": "Bungalow",
      "listingType": "Rent",
      "description":
          "A beautiful 6-bedroom bungalow located in Muthaiga. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "7-Bedroom Mansion - Limuru, Nairobi",
      "price": "KSH 2,000,000/year",
      "location": "Limuru, Nairobi",
      "images": [
        "assets/images/image11.webp",
        "assets/images/image11_1.webp",
        "assets/images/image11_2.webp",
        "assets/images/image11_3.webp",
        "assets/images/image11_4.webp",
        "assets/images/image11_5.webp"
      ],
      "bedrooms": 7,
      "bathrooms": 9,
      "area": "8000", // Area in sq ft or sq meters
      "type": "Mansion",
      "listingType": "Lease",
      "description":
          "A beautiful 7-bedroom mansion located in Limuru. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Beautiful Villa - Diani",
      "price": "KSH 5,000,000/year",
      "location": "Diani, Mombasa",
      "images": [
         "assets/images/image12.webp",
        "assets/images/image12_1.webp",
        "assets/images/image12_2.webp",
        "assets/images/image12_3.webp",
        "assets/images/image12_4.webp",
        "assets/images/image12_5.webp"
      ],
      "bedrooms": 6,
      "bathrooms": 8,
      "area": "9000",
      "type": "Villa",
      "listingType": "Lease",
      "description":
          "Luxurious villa with top-notch finishes. Includes private pool, garage, and security system.",
      "isFavorite": false,
    },

    {
      "title": "Spacious Luxurious Bungalow - Watamu",
      "price": "KSH 500,000/month",
      "location": "Watamu, Mombasa",
      "images": [
        "assets/images/image13.webp",
        "assets/images/image13_1.webp",
        "assets/images/image13_2.webp",
        "assets/images/image13_3.webp",
        "assets/images/image13_4.webp",
        "assets/images/image13_5.webp"
      ],
      "bedrooms": 4,
      "bathrooms": 5,
      "area": "4000", // Area in sq ft or sq meters
      "type": "Bungalow",
      "listingType": "Rent",
      "description":
          "A beautiful 4-bedroom bungalow located in Muthaiga. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Well Maintained Mansion - Gigiri, Kiambu",
      "price": "KSH 1,500,000/year",
      "location": "Limuru, Kiambu",
      "images": [
        "assets/images/image14.webp",
        "assets/images/image14_1.webp",
        "assets/images/image14_2.webp",
        "assets/images/image14_3.webp",
        "assets/images/image14_4.webp",
        "assets/images/image14_5.webp"
      ],
      "bedrooms": 7,
      "bathrooms": 8,
      "area": "9000", // Area in sq ft or sq meters
      "type": "Mansion",
      "listingType": "Lease",
      "description":
          "A beautiful 7-bedroom mansion located in Gigiri. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "5-Bedroom Mansion - Syokimau, Nairobi",
      "price": "KSH 100,000/month",
      "location": "Syokimau, Nairobi",
      "images": [
        "assets/images/image15.webp",
        "assets/images/image15_1.webp",
        "assets/images/image15_2.webp",
        "assets/images/image15_3.webp",
        "assets/images/image15_4.webp",
        "assets/images/image15_5.webp"
      ],
      "bedrooms": 5,
      "bathrooms": 6,
      "area": "4000", // Area in sq ft or sq meters
      "type": "Mansion",
      "listingType": "Rent",
      "description":
          "A beautiful 5-bedroom mansion located in Limuru. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "6-Bedroom Villa - Malindi, Mombasa",
      "price": "KSH 2,500,000/year",
      "location": "Malindi, Mombasa",
      "images": [
        "assets/images/image16.webp",
        "assets/images/image16_1.webp",
        "assets/images/image16_2.webp",
        "assets/images/image16_3.webp",
        "assets/images/image16_4.webp",
        "assets/images/image16_5.webp"
      ],
      "bedrooms": 6,
      "bathrooms": 9,
      "area": "6000", // Area in sq ft or sq meters
      "type": "Villa",
      "listingType": "Lease",
      "description":
          "A beautiful 6-bedroom Villa and a beach house located in Malindi near the sea shore of Indian ocean. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Luxury 10-Bedroom Mansion - Vipingo, Mombasa",
      "price": "KSH 3,500,000/year",
      "location": "Vipingo, Mombasa",
      "images": [
        "assets/images/image17.webp",
        "assets/images/image17_1.webp",
        "assets/images/image17_2.webp",
        "assets/images/image17_3.webp",
        "assets/images/image17_4.webp",
        "assets/images/image17_5.webp"
      ],
      "bedrooms": 10,
      "bathrooms": 13,
      "area": "9000", // Area in sq ft or sq meters
      "type": "Villa",
      "listingType": "Lease",
      "description":
          "A beautiful 10-bedroom Villa and a beach house located in Vipingo in Mombasa. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Beautiful 4-Bedroom Villa - Diani, Mombasa",
      "price": "KSH 30,000,000/year", // Adjusted from /month to /year (2,500,000 * 12)
      "location": "Diani, Mombasa",
      "images": [
        "assets/images/image18.webp",
        "assets/images/image18_1.webp",
        "assets/images/image18_2.webp",
        "assets/images/image18_3.webp",
        "assets/images/image18_4.webp",
        "assets/images/image18_5.webp"
      ],
      "bedrooms": 4,
      "bathrooms": 5,
      "area": "5000", // Area in sq ft or sq meters
      "type": "Villa",
      "listingType": "Lease",
      "description":
          "A beautiful 4-bedroom Villa and a beach house located in Diani near the sea shore of Indian ocean. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "3-Bedroom Villa - Mtwapa, Mombasa",
      "price": "KSH 500,000/month",
      "location": "Mtwapa, Nairobi",
      "images": [
        "assets/images/image19.webp",
        "assets/images/image19_1.webp",
        "assets/images/image19_2.webp",
        "assets/images/image19_3.webp",
        "assets/images/image19_4.webp",
        "assets/images/image19_5.webp"
      ],
      "bedrooms": 3,
      "bathrooms": 5,
      "area": "4500", // Area in sq ft or sq meters
      "type": "Villa",
      "listingType": "Rent",
      "description":
          "A beautiful 3-bedroom Villa and a beach house located in Mtwapa near the sea shore of Indian ocean. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Spacious 8-Bedroom Mansion - Watamu, Mombasa",
      "price": "KSH 3,300,000/year",
      "location": "Watamu, Nairobi",
      "images": [
        "assets/images/image20.webp",
        "assets/images/image20_1.webp",
        "assets/images/image20_2.webp",
        "assets/images/image20_3.webp",
        "assets/images/image20_4.webp",
        "assets/images/image20_5.webp"
      ],
      "bedrooms": 8,
      "bathrooms": 10,
      "area": "6000", // Area in sq ft or sq meters
      "type": "Mansion",
      "listingType": "Lease",
      "description":
          "A beautiful 8-bedroom Mansion and a beach house located in Watamu near the sea shore of Indian ocean. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "6-Bedroom Villa - Nyali, Mombasa",
      "price": "KSH 210,000,000",
      "location": "Nyali, Mombasa",
      "images": [
        "assets/images/image21.webp",
        "assets/images/image21_1.webp",
        "assets/images/image21_2.webp",
        "assets/images/image21_3.webp",
        "assets/images/image21_4.webp",
        "assets/images/image21_5.webp"
      ],
      "bedrooms": 6,
      "bathrooms": 8,
      "area": "8500", // Area in sq ft or sq meters
      "type": "Villa",
      "listingType": "Buy",
      "description":
          "A beautiful 6-bedroom Villa and a beach house located in Nyali near the sea shore of Indian ocean. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Spacious Bedsitter/Studio - Uthiru, Kiambu",
      "price": "KSH 8,000/month",
      "location": "Uthiru, Kiambu",
      "images": [
        "assets/images/image22.webp",
        "assets/images/image22_1.webp",
        "assets/images/image22_2.webp",
        "assets/images/image22_3.webp",
        "assets/images/image22_4.webp",
        "assets/images/image22_5.webp"
      ],
      "bedrooms": 1,
      "bathrooms": 1,
      "area": "2000", // Area in sq ft or sq meters
      "type": "Apartment",
      "listingType": "Rent",
      "description":
          "A beautiful and spacious studio apartment in a green area full of fresh air and noise from the city. With young families and disciplined tenants as potential neighbors",
      "isFavorite": false,
    },

    {
      "title": "Luxurious 3-Bedroom Bungalow - Ruaka",
      "price": "KSH 50,000/month",
      "location": "Ruaka, Nairobi",
      "images": [
        "assets/images/image23.webp",
        "assets/images/image23_1.webp",
        "assets/images/image23_2.webp",
        "assets/images/image23_3.webp",
        "assets/images/image23_4.webp",
        "assets/images/image23_5.webp"
      ],
      "bedrooms": 3,
      "bathrooms": 3,
      "area": "4000", // Area in sq ft or sq meters
      "type": "Bungalow",
      "listingType": "Rent",
      "description":
          "A beautiful 3-bedroom bungalow located in Ruaka. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Luxurious 4-Bedroom Bungalow - Kikuyu",
      "price": "KSH 600,000/month",
      "location": "Kikuyu, Nairobi",
      "images": [
        "assets/images/image24.webp",
        "assets/images/image24_1.webp",
        "assets/images/image24_2.webp",
        "assets/images/image24_3.webp",
        "assets/images/image24_4.webp",
        "assets/images/image24_5.webp"
      ],
      "bedrooms": 4,
      "bathrooms": 4,
      "area": "3000", // Area in sq ft or sq meters
      "type": "Bungalow",
      "listingType": "Lease",
      "description":
          "A beautiful 4-bedroom bungalow located in Kikuyu. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Luxurious 3-Bedroom Bungalow - Ruiru",
      "price": "KSH 30,000/month",
      "location": "Ruiru, Nairobi",
      "images": [
        "assets/images/image25.webp",
        "assets/images/image25_1.webp",
        "assets/images/image25_2.webp",
        "assets/images/image25_3.webp",
        "assets/images/image25_4.webp",
        "assets/images/image25_5.webp"
      ],
      "bedrooms": 3,
      "bathrooms": 3,
      "area": "3500", // Area in sq ft or sq meters
      "type": "Bungalow",
      "listingType": "Rent",
      "description":
          "A beautiful 3-bedroom bungalow located in Ruiru. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Luxurious 5-Bedroom Bungalow - Ruaka",
      "price": "KSH 15,000,000",
      "location": "Ruaka, Nairobi",
      "images": [
        "assets/images/image26.webp",
        "assets/images/image26_1.webp",
        "assets/images/image26_2.webp",
        "assets/images/image26_3.webp",
        "assets/images/image26_4.webp",
        "assets/images/image26_5.webp"
      ],
      "bedrooms": 5,
      "bathrooms": 6,
      "area": "5500", // Area in sq ft or sq meters
      "type": "Bungalow",
      "listingType": "Buy",
      "description":
          "A beautiful 5-bedroom bungalow located in Ruaka, Nairobi. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Well furnished 7-Bedroom Bungalow - Ngong",
      "price": "KSH 30,000,000",
      "location": "Ngong, Nairobi",
      "images": [
        "assets/images/image27.webp",
        "assets/images/image27_1.webp",
        "assets/images/image27_2.webp",
        "assets/images/image27_3.webp",
        "assets/images/image27_4.webp",
        "assets/images/image27_5.webp"
      ],
      "bedrooms": 7,
      "bathrooms": 8,
      "area": "4500", // Area in sq ft or sq meters
      "type": "Bungalow",
      "listingType": "Buy",
      "description":
          "A beautiful 7-bedroom bungalow located in Ngong, Nairobi. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Bungalow with natural lighting - Kitengela",
      "price": "KSH 35,000/month",
      "location": "Kitengela, Nairobi",
      "images": [
        "assets/images/image28.webp",
        "assets/images/image28_1.webp",
        "assets/images/image28_2.webp",
        "assets/images/image28_3.webp",
        "assets/images/image28_4.webp",
        "assets/images/image28_5.webp"
      ],
      "bedrooms": 3,
      "bathrooms": 3,
      "area": "4000", // Area in sq ft or sq meters
      "type": "Bungalow",
      "listingType": "Rent",
      "description":
          "A beautiful 3-bedroom bungalow located in Kitengela. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },

    {
      "title": "Lavish 4-Bedroom Bungalow - Ongata Rongai",
      "price": "KSH 2,500,000/year",
      "location": "Rongai, Nairobi",
      "images": [
        "assets/images/image29.webp",
        "assets/images/image29_1.webp",
        "assets/images/image29_2.webp",
        "assets/images/image29_3.webp",
        "assets/images/image29_4.webp",
        "assets/images/image29_5.webp"
      ],
      "bedrooms": 4,
      "bathrooms": 4,
      "area": "4400", // Area in sq ft or sq meters
      "type": "Bungalow",
      "listingType": "Lease",
      "description":
          "A lavish 4-bedroom bungalow located in Ongata Rongai. Comes with a spacious living room, modern kitchen, and a large compound.",
      "isFavorite": false,
    },
    
    {
      "title": "2BR Apartment - Kilifi",
      "price": "KSH 19,000/month",
      "location": "Kilifi, Mombasa",
      "images": [
        "assets/images/image30.webp",
        "assets/images/image30_1.webp",
        "assets/images/image30_2.webp",
        "assets/images/image30_3.webp",
        "assets/images/image30_4.webp",
        "assets/images/image30_5.webp"
      ],
      "bedrooms": 2,
      "bathrooms": 1,
      "area": "600",
      "type": "Apartment",
      "listingType": "Rent",
      "description":
          "Modern 2 bedroom apartment located in Kilifi in Mombasa. Close to shops, schools, and transport hubs.",
      "isFavorite": false,
    },

    {
      "title": "3 - bedroom Apartment - Kikuyu",
      "price": "KSH 3,000,000",
      "location": "Kikuyu, Nairobi",
      "images": [
        "assets/images/image31.webp",
        "assets/images/image31_1.webp",
        "assets/images/image31_2.webp",
        "assets/images/image31_3.webp",
        "assets/images/image31_4.webp",
        "assets/images/image31_5.webp"
      ],
      "bedrooms": 3,
      "bathrooms": 2,
      "area": "4000",
      "type": "Apartment",
      "listingType": "Buy",
      "description":
          "Modern 3br apartment located in Kikuyu 100 metres from the tarmac. Close to shops, schools, and transport hubs.",
      "isFavorite": false,
    },

    {
      "title": "3BR Apartment - Tatu City",
      "price": "KSH 19,000/year",
      "location": "Tatu City, Nairobi",
      "images": [
        "assets/images/image32.webp",
        "assets/images/image32_1.webp",
        "assets/images/image32_2.webp",
        "assets/images/image32_3.webp",
        "assets/images/image32_4.webp",
        "assets/images/image32_5.webp"
      ],
      "bedrooms": 3,
      "bathrooms": 3,
      "area": "2500",
      "type": "Apartment",
      "listingType": "Lease",
      "description":
          "Modern 3 bedroom apartment located in Tatu city along Thika Road. Close to shops, schools, and transport hubs.",
      "isFavorite": false,
    },

    {
      "title": "2BR Apartment - Shanzu",
      "price": "KSH 220,000/year",
      "location": "Shanzu, Mombasa",
      "images": [
        "assets/images/image33.webp",
        "assets/images/image33_1.webp",
        "assets/images/image33_2.webp",
        "assets/images/image33_3.webp",
        "assets/images/image33_4.webp",
        "assets/images/image33_5.webp"
      ],
      "bedrooms": 2,
      "bathrooms": 1,
      "area": "2000",
      "type": "Apartment",
      "listingType": "Lease",
      "description":
          "Modern 2 bedroom apartment located in Shanzu in Mombasa. Close to shops, schools, and transport hubs.",
      "isFavorite": false,
    },

    {
      "title": "Apartment 2BR available - Ahero",
      "price": "KSH 2,000,000",
      "location": "Ahero, Kisumu",
      "images": [
        "assets/images/image34.webp",
        "assets/images/image34_1.webp",
        "assets/images/image34_2.webp",
        "assets/images/image34_3.webp",
        "assets/images/image34_4.webp",
        "assets/images/image34_5.webp"
      ],
      "bedrooms": 2,
      "bathrooms": 1,
      "area": "3000",
      "type": "Apartment",
      "listingType": "Buy",
      "description":
          "Modern 2 bedroom apartment located in Ahero in Kisumu. Close to shops, schools, and transport hubs.",
      "isFavorite": false,
    },

    {
      "title": "Apartment 2BR available - Kizingo",
      "price": "KSH 200,000/month",
      "location": "Kizingo, Mombasa",
      "images": [
        "assets/images/image35.webp",
        "assets/images/image35_1.webp",
        "assets/images/image35_2.webp",
        "assets/images/image35_3.webp",
        "assets/images/image35_4.webp",
        "assets/images/image35_5.webp"
      ],
      "bedrooms": 2,
      "bathrooms": 1,
      "area": "2500",
      "type": "Apartment",
      "listingType": "Buy",
      "description":
          "Modern 2 bedroom apartment located in Kizingo in Mombasa. Close to shops, schools, and transport hubs.",
      "isFavorite": false,
    },

    {
      "title": "Apartment 3BR available - Vipingo",
      "price": "KSH 25,000/month",
      "location": "Vipingo, Mombasa",
      "images": [
        "assets/images/image36.webp",
        "assets/images/image36_1.webp",
        "assets/images/image36_2.webp",
        "assets/images/image36_3.webp",
        "assets/images/image36_4.webp",
        "assets/images/image36_5.webp"
      ],
      "bedrooms": 3,
      "bathrooms": 2,
      "area": "3500",
      "type": "Apartment",
      "listingType": "Rent",
      "description":
          "Modern 3 bedroom apartment located in Vipingo in Mombasa. Close to shops, schools, and transport hubs.",
      "isFavorite": false,
    },

    {
      "title": "Apartment 2BR available - Tassia",
      "price": "KSH 65,000,000",
      "location": "Tassia, Embakasi",
      "images": [
        "assets/images/image37.webp",
        "assets/images/image37_1.webp",
        "assets/images/image37_2.webp",
        "assets/images/image37_3.webp",
        "assets/images/image37_4.webp",
        "assets/images/image37_5.webp"
      ],
      "bedrooms": 2,
      "bathrooms": 1,
      "area": "2500",
      "type": "Apartment",
      "listingType": "Buy",
      "description":
          "Modern 2 bedroom apartment located in Tassia in Embakasi. Close to shops, schools, and transport hubs. They consist of 32 two bedroom apartments and 2 one bedroom apartments. The apartments have basement parking for 26 cars, 80,000 litres underground water tank, 32,000 litres overhead water tank, common area for tenants. The average estimated monthly rent for each apartment is 19,500 so total monthly rent is 650-700k easy if well managed.",
      "isFavorite": false,
    },

    {
      "title": "A third acre prime plot - Karen, Nairobi",
      "price": "KSH 170,000,000",
      "location": "Karen, Nairobi",
      "images": [
        "assets/images/image38.webp",
        "assets/images/image38_1.webp",
        "assets/images/image38_2.webp",
        "assets/images/image38_3.webp",
        "assets/images/image38_4.webp",
        "assets/images/image38_5.webp"
      ],
      "bedrooms": 0,
      "bathrooms": 0,
      "area": "2500",
      "type": "Plot",
      "listingType": "Buy",
      "description":
          "Karen shopping centre, a third of an acre, triangular shape with the back bordering the petrol station, currently housing Posta property on sale.",
      "isFavorite": false,
    },

    {
      "title": "A  40 by 60 prime plot - SDA, Utawala",
      "price": "KSH 7,000,000",
      "location": "Utawala, Embakasi",
      "images": [
        "assets/images/image39.webp",
        "assets/images/image39_1.webp",
        "assets/images/image39_2.webp",
        "assets/images/image39_3.webp",
        "assets/images/image39_4.webp",
        "assets/images/image39_5.webp"
      ],
      "bedrooms": 0,
      "bathrooms": 0,
      "area": "2400",
      "type": "Plot",
      "listingType": "Buy",
      "description":
          "We are selling a plot in Utawala SDA in a well controlled residential development.The plot is 40by60 with title deed.",
      "isFavorite": false,
    },

    {
      "title": "Prime 1/4 acre Plot available - Imaara Daima",
      "price": "KSH 55,000,000",
      "location": "Imara Daima, Nairobi",
      "images": [
        "assets/images/image40.webp",
        "assets/images/image40_1.webp",
        "assets/images/image40_2.webp",
        "assets/images/image40_3.webp",
        "assets/images/image40_4.webp",
        "assets/images/image40_5.webp"
      ],
      "bedrooms": 0,
      "bathrooms": 0,
      "area": "2500",
      "type": "Plot",
      "listingType": "Buy",
      "description":
          "We are selling a plot in Imara Daima in a well controlled residential development.The plot is 1/4 acre plot with title deed.",
      "isFavorite": false,
    },

    {
      "title": "Prime plot on sale 40 by 80 - AP, Utawala",
      "price": "KSH 6,000,000",
      "location": "Utawala, Embakasi",
      "images": [
        "assets/images/image41.webp",
        "assets/images/image41_1.webp",
        "assets/images/image41_2.webp",
        "assets/images/image41_3.webp",
        "assets/images/image41_4.webp",
        "assets/images/image41_5.webp"
      ],
      "bedrooms": 0,
      "bathrooms": 0,
      "area": "3200",
      "type": "Plot",
      "listingType": "Buy",
      "description":
          "We are selling a plot in Utawala AP in a well controlled residential development.The plot is 40 by 80 with title deed.",
      "isFavorite": false,
    },

    {
      "title": "Prime 1/2 acre Plot available - Safari Park",
      "price": "KSH 40,500,000",
      "location": "Safari Park, Thika rd",
      "images": [
        "assets/images/image42.webp",
        "assets/images/image42_1.webp",
        "assets/images/image42_2.webp",
        "assets/images/image42_3.webp",
        "assets/images/image42_4.webp",
        "assets/images/image42_5.webp"
      ],
      "bedrooms": 0,
      "bathrooms": 0,
      "area": "5000",
      "type": "Plot",
      "listingType": "Buy",
      "description":
          "We are selling a prime plot along Thika road near Safari Park Hotel in a well controlled residential development.The plot is 1/2 acre plot with title deed.",
      "isFavorite": false,
    },
    // ... (rest of the property list from property_listing_screen.dart) ...
  ];

  List<Map<String, dynamic>> _searchResults = [];
  late List<Map<String, dynamic>> _popularPropertiesList;
  late List<Map<String, dynamic>> _hottestPropertiesList;
  late List<Map<String, dynamic>> _newPropertiesList; // New list for 'New Properties'

  @override
  void initState() {
    super.initState();
    _featuredScrollController = ScrollController();
    _trendingScrollController = ScrollController();
    _recommendedScrollController = ScrollController();

    // Initialize state properties, these will be updated by the listener
    // This is redundant as ValueListenableBuilder directly reads from currentUserNotifier now.
    // _currentUser = widget.authService.getCurrentUser();
    // _isLoggedIn = _currentUser != null;

    // The listener below ensures that _isLoggedIn and _currentUser are always up-to-date
    // The previous implementation used _onAuthStateChanged to setState. This is now
    // replaced by direct use of ValueListenableBuilder.

    _searchResults.addAll(allProperties);

    final List<Map<String, dynamic>> shuffledAllProperties = List<Map<String, dynamic>>.from(allProperties)..shuffle();
    final List<Map<String, dynamic>> buyProps = shuffledAllProperties.where((p) => p['listingType'] == 'Buy').toList().cast<Map<String, dynamic>>();
    final List<Map<String, dynamic>> rentProps = shuffledAllProperties.where((p) => p['listingType'] == 'Rent').toList().cast<Map<String, dynamic>>();
    final List<Map<String, dynamic>> leaseProps = shuffledAllProperties.where((p) => p['listingType'] == 'Lease').toList().cast<Map<String, dynamic>>();

    _popularPropertiesList = [];
    _popularPropertiesList.addAll(buyProps.take(4));
    _popularPropertiesList.addAll(rentProps.take(3));
    _popularPropertiesList.addAll(leaseProps.take(3));
    _popularPropertiesList.shuffle();

    final List<Map<String, dynamic>> remainingForHottest = List<Map<String, dynamic>>.from(shuffledAllProperties)
        .where((p) => !_popularPropertiesList.contains(p))
        .toList()
        .cast<Map<String, dynamic>>();

    _hottestPropertiesList = [];
    final int hottestCount = 10;
    for (int i = 0; i < hottestCount && i < remainingForHottest.length; i++) {
      _hottestPropertiesList.add(remainingForHottest[i]);
    }
    _hottestPropertiesList.shuffle();

    if (_hottestPropertiesList.length < hottestCount) {
      final int needed = hottestCount - _hottestPropertiesList.length;
      final List<Map<String, dynamic>> fillInHottest = List<Map<String, dynamic>>.from(allProperties)
          .where((p) => !_popularPropertiesList.contains(p) && !_hottestPropertiesList.contains(p))
          .toList()
          .cast<Map<String, dynamic>>();
      fillInHottest.shuffle();
      for (int i = 0; i < needed && i < fillInHottest.length; i++) {
        _hottestPropertiesList.add(fillInHottest[i]);
      }
    }

    final List<Map<String, dynamic>> remainingForNew = List<Map<String, dynamic>>.from(shuffledAllProperties)
        .where((p) => !_popularPropertiesList.contains(p) && !_hottestPropertiesList.contains(p))
        .toList()
        .cast<Map<String, dynamic>>();

    _newPropertiesList = [];
    final int newCount = 10;
    for (int i = 0; i < newCount && i < remainingForNew.length; i++) {
      _newPropertiesList.add(remainingForNew[i]);
    }
    _newPropertiesList.shuffle();

    if (_newPropertiesList.length < newCount) {
      final int needed = newCount - _newPropertiesList.length;
      final List<Map<String, dynamic>> fillInNew = List<Map<String, dynamic>>.from(allProperties)
          .where((p) => !_popularPropertiesList.contains(p) && !_hottestPropertiesList.contains(p) && !_newPropertiesList.contains(p))
          .toList()
          .cast<Map<String, dynamic>>();
      fillInNew.shuffle();
      for (int i = 0; i < needed && i < fillInNew.length; i++) {
        _newPropertiesList.add(fillInNew[i]);
      }
    }
  }

  // No longer needed if ValueListenableBuilder is used directly for UI updates
  // void _onAuthStateChanged() {
  //   setState(() {
  //     _currentUser = widget.authService.getCurrentUser();
  //     _isLoggedIn = _currentUser != null;
  //   });
  // }

  @override
  void dispose() {
    // widget.authService.currentUserNotifier.removeListener(_onAuthStateChanged); // No longer needed
    _featuredScrollController.dispose();
    _trendingScrollController.dispose();
    _recommendedScrollController.dispose();
    _searchController.dispose();
    _newsletterEmailController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = allProperties.where((property) {
          return _currentListingTypeFilter.isEmpty || property['listingType'] == _currentListingTypeFilter;
        }).toList();
      } else {
        _searchResults = allProperties.where((property) {
          final titleLower = property['title'].toLowerCase();
          final locationLower = property['location'].toLowerCase();
          final queryLower = query.toLowerCase();
          final typeLower = property['type'].toLowerCase();
          final listingTypeLower = property['listingType'].toLowerCase();

          bool matchesSearchQuery = titleLower.contains(queryLower) ||
              locationLower.contains(queryLower) ||
              typeLower.contains(queryLower) ||
              listingTypeLower.contains(queryLower);

          bool matchesListingType = _currentListingTypeFilter.isEmpty || property['listingType'] == _currentListingTypeFilter;

          return matchesSearchQuery && matchesListingType;
        }).toList();
      }
    });
  }

  void _filterPropertiesByListingType(String type) {
    setState(() {
      _currentListingTypeFilter = type;
      _searchController.clear();
      _performSearch(_searchController.text);
    }
    );
  }

  Widget _buildPropertyCarousel(String title, List<Map<String, dynamic>> properties, ScrollController controller) {
    final filteredProperties = properties.where((p) {
      bool inSearchResults = _searchResults.contains(p);
      return inSearchResults;
    }).toList().cast<Map<String, dynamic>>();

    if (filteredProperties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E90FF),
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              SizedBox(
                height: 350,
                child: ListView.builder(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredProperties.length,
                  itemBuilder: (context, index) {
                    return PropertyCardWithCarousel(
                        property: filteredProperties[index],
                        onFavoriteToggle: (property) {
                          setState(() {
                            final index = allProperties.indexWhere((p) => p['title'] == property['title']);
                            if (index != -1) {
                              allProperties[index]['isFavorite'] = !allProperties[index]['isFavorite'];
                            }
                          });
                        },
                        // Pass isLoggedIn directly from AuthService notifier
                        isLoggedIn: widget.authService.currentUserNotifier.value != null,
                        showLoginPrompt: _showLoginSignupDialog,
                    );
                  },
                ),
              ),
              if (kIsWeb) ...[
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildScrollButton(
                      controller,
                      isLeft: true,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildScrollButton(
                      controller,
                      isLeft: false,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

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
                Navigator.pushNamed(context, '/signup'); // Navigate to signup screen
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
                Navigator.pushNamed(context, '/signin'); // Navigate to signin screen
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildScrollButton(ScrollController controller, {required bool isLeft}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(isLeft ? Icons.arrow_back_ios : Icons.arrow_forward_ios),
        color: const Color(0xFF1E90FF),
        onPressed: () {
          controller.animateTo(
            controller.offset + (isLeft ? -300 : 300),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }

  // This method now handles only the sign-out action without navigating.
  // The UI will update automatically via ValueListenableBuilder.
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
                  // This navigation logic should ideally go to a route that resolves auth state
                  // or simply rebuilds the home screen. Current setup is fine as /home is
                  // the initial route for web.
                  // For a fresh start, could use Navigator.pushReplacementNamed(context, '/home');
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/sora_logo.png',
                      height: 45,
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
                        SizedBox(
                          width: 250,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            ),
                            onChanged: _performSearch,
                          ),
                        ),
                        const SizedBox(width: 20),
                        _buildAppBarButton('Sell', () {
                          // Logic for AppBar 'Sell' button
                          // Use ValueListenableBuilder to check auth state
                          if (widget.authService.currentUserNotifier.value == null) {
                            _showLoginSignupDialog();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Redirecting to sell property page (coming soon)!')),
                            );
                          }
                        }, isFilled: true),
                        const SizedBox(width: 20),
                        // Conditionally render Profile Icon/Logout or Login button using ValueListenableBuilder
                        ValueListenableBuilder<User?>(
                          valueListenable: widget.authService.currentUserNotifier,
                          builder: (context, user, child) {
                            if (user != null) {
                              // User is logged in, show profile icon with logout option
                              return PopupMenuButton<int>(
                                icon: CircleAvatar(
                                  backgroundColor: const Color(0xFF0A66C2), // Primary blue color
                                  radius: 20, // Adjust size as needed
                                  child: (user.email != null && user.email!.isNotEmpty)
                                      ? Text(
                                          user.email![0].toUpperCase(), // Display first letter of email
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        )
                                      : const Icon(Icons.person, color: Colors.white), // Fallback to person icon
                                ),
                                onSelected: (item) {
                                  if (item == 0) {
                                    // View Profile
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Viewing profile for ${user.email ?? "User"}')),
                                    );
                                    // TODO: Navigate to user profile screen
                                  } else if (item == 1) {
                                    _handleSignOut(); // Call the refactored sign out method
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
                              // User is not logged in, show login button
                              return _buildAppBarButton('Login', () {
                                Navigator.pushNamed(context, '/signin'); // Navigate to Sign In screen
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
                    // Logic for Drawer 'Sell' link
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
            // Conditionally render Login/Logout button in drawer
            ValueListenableBuilder<User?>(
              valueListenable: widget.authService.currentUserNotifier,
              builder: (context, user, child) {
                if (user != null) {
                  return ListTile(
                    leading: CircleAvatar( // Adding CircleAvatar for the icon
                      backgroundColor: const Color(0xFF0A66C2), // Match app bar color
                      child: (user.email != null && user.email!.isNotEmpty)
                          ? Text(
                              user.email![0].toUpperCase(), // Display first letter of email
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            )
                          : const Icon(Icons.person, color: Colors.white), // Fallback to person icon
                    ),
                    title: const Text('Logout'),
                    onTap: () async {
                      Navigator.of(context).pop(); // Close drawer
                      _handleSignOut(); // Call the refactored sign out method
                    },
                  );
                } else {
                  return ListTile(
                    leading: const Icon(Icons.login), // Add a login icon
                    title: const Text('Login'),
                    onTap: () {
                      Navigator.of(context).pop(); // Close drawer
                      Navigator.pushNamed(context, '/signin'); // Navigate to Sign In screen
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
            // --- Hero Section ---
            SizedBox(
              width: double.infinity,
              height: isLargeScreen ? 500 : (isMediumScreen ? 400 : 350),
              child: Stack(
                children: [
                  if (kIsWeb)
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/real_estate_hero.webp',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF1E90FF),
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.white, size: 80),
                            ),
                          );
                        },
                      ),
                    ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            const Color(0xFF1E90FF).withOpacity(0.2),
                            Colors.purple.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your Dream Home Awaits',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isLargeScreen ? 56 : (isMediumScreen ? 48 : 40),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 20.0,
                                  color: Colors.black.withOpacity(0.7),
                                  offset: const Offset(3.0, 3.0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          BlinkingGradientText(
                            text: 'Explore millions of properties across Africa.',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 22 : (isMediumScreen ? 20 : 18),
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  blurRadius: 15.0,
                                  color: Colors.black.withOpacity(0.6),
                                  offset: const Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                            colors: const [
                              Colors.white,
                              Color(0xFF4B0082),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Popular Properties Section ---
            Padding(
              padding: EdgeInsets.only(
                top: 40.0,
                left: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                right: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                bottom: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Popular Properties',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A66C2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.star,
                          size: isLargeScreen ? 36 : (isMediumScreen ? 32 : 28),
                          color: Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _RecommendedPropertiesCarousel(
                      propertiesToDisplay: _popularPropertiesList,
                      isLargeScreen: isLargeScreen,
                      isMediumScreen: isMediumScreen,
                      buildPropertyCard: (property) => PropertyCardWithCarousel(
                        property: property,
                        onFavoriteToggle: (p) {
                          setState(() {
                            final index = allProperties.indexWhere((prop) => prop['title'] == p['title']);
                            if (index != -1) {
                              allProperties[index]['isFavorite'] = !allProperties[index]['isFavorite'];
                            }
                          });
                        },
                        isLoggedIn: widget.authService.currentUserNotifier.value != null,
                        showLoginPrompt: _showLoginSignupDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- New: Hottest in Sora Section ---
            Padding(
              padding: EdgeInsets.only(
                top: 40.0,
                left: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                right: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                bottom: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hottest in Sora',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A66C2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.local_fire_department,
                          size: isLargeScreen ? 36 : (isMediumScreen ? 32 : 28),
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _RecommendedPropertiesCarousel(
                      propertiesToDisplay: _hottestPropertiesList,
                      isLargeScreen: isLargeScreen,
                      isMediumScreen: isMediumScreen,
                      buildPropertyCard: (property) => PropertyCardWithCarousel(
                        property: property,
                        onFavoriteToggle: (p) {
                          setState(() {
                            final index = allProperties.indexWhere((prop) => prop['title'] == p['title']);
                            if (index != -1) {
                              allProperties[index]['isFavorite'] = !allProperties[index]['isFavorite'];
                            }
                          });
                        },
                        isLoggedIn: widget.authService.currentUserNotifier.value != null,
                        showLoginPrompt: _showLoginSignupDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- New: New Properties Section ---
            Padding(
              padding: EdgeInsets.only(
                top: 40.0,
                left: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                right: isLargeScreen ? 24.0 : (isMediumScreen ? 16.0 : 8.0),
                bottom: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'New Properties',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A66C2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.fiber_new,
                          size: isLargeScreen ? 36 : (isMediumScreen ? 32 : 28),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- New: Why Choose SORA? Section ---
            Container(
              width: double.infinity,
              color: Colors.grey[50],
              padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isLargeScreen ? 900 : (isMediumScreen ? 600 : double.infinity)),
                child: Column(
                  children: [
                    Text(
                      'Why Choose SORA?',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A66C2),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 30.0,
                      runSpacing: 30.0,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildValueCard(
                          icon: Icons.lightbulb_outline,
                          title: 'Innovation',
                          description: 'Leveraging cutting-edge tech for smarter property searches.',
                        ),
                        _buildValueCard(
                          icon: Icons.security,
                          title: 'Trust & Transparency',
                          description: 'Honest dealings and clear information, always.',
                        ),
                        _buildValueCard(
                          icon: Icons.people_alt_outlined,
                          title: 'Client-Centric',
                          description: 'Your needs are our priority, with personalized support.',
                        ),
                        _buildValueCard(
                          icon: Icons.verified_outlined,
                          title: 'Verified Listings',
                          description: 'Access to genuine properties, thoroughly vetted for quality.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- New: How It Works Section ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isLargeScreen ? 900 : (isMediumScreen ? 700 : double.infinity)),
                child: Column(
                  children: [
                    Text(
                      'How It Works',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A66C2),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        _buildProcessStep(
                          stepNumber: 1,
                          icon: Icons.search,
                          title: 'Explore Listings',
                          description: 'Browse millions of properties with detailed photos and virtual tours. Use our powerful search filters to narrow down your options.',
                          isLargeScreen: isLargeScreen,
                        ),
                        _buildProcessStep(
                          stepNumber: 2,
                          icon: Icons.connect_without_contact,
                          title: 'Connect with Experts',
                          description: 'Get in touch with qualified real estate agents and brokers who can guide you through the process and answer your questions.',
                          isLargeScreen: isLargeScreen,
                        ),
                        _buildProcessStep(
                          stepNumber: 3,
                          icon: Icons.home_work_outlined,
                          title: 'Secure Your Dream Property',
                          description: 'From offers to closing, we\'ll support you every step to make your property acquisition smooth and successful.',
                          isLargeScreen: isLargeScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- New: Sell Your Property Section ---
            _buildSellSection(isLargeScreen: isLargeScreen || isMediumScreen),
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
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$linkText functionality coming soon!')),
                              );
                            }
                          },
                        ),
                        _buildFooterColumn('Resources', ['Buy', 'Rent', 'Lease', 'FAQs', 'Support', 'Terms'], // 'Sell' removed, 'Rent' added
                          onLinkTapped: (linkText) {
                            if (linkText == 'Buy') {
                              Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Buy'});
                            } else if (linkText == 'Rent') { // Modified from 'Sell' to 'Rent'
                              Navigator.pushNamed(context, '/property_listings', arguments: {'listingType': 'Rent'}); // Added navigation for Rent
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 300,
      height: 320,
      padding: const EdgeInsets.all(20.0),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF0A66C2)),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A66C2),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A66C2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: const Color(0xFF1E90FF)),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep({
    required int stepNumber,
    required IconData icon,
    required String title,
    required String description,
    required bool isLargeScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: isLargeScreen
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1E90FF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E90FF).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 30, color: const Color(0xFF0A66C2)),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A66C2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          )
        ],
      )
          : Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1E90FF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E90FF).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Icon(icon, size: 35, color: const Color(0xFF0A66C2)),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard({
    required String quote,
    required String author,
    required String avatarAsset,
  }) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(25.0),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage(avatarAsset),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 20),
          Text(
            quote,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '- $author',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A66C2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellSection({required bool isLargeScreen}) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE3F2FD),
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isLargeScreen ? 800 : double.infinity),
        child: Column(
          children: [
            Text(
              'Ready to List Your Property?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLargeScreen ? 40 : 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A66C2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'List your property with SORA to sell, let, or lease it. Our platform makes listing easy, efficient, and rewarding, reaching millions of potential clients.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLargeScreen ? 18 : 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Logic for 'List Your Property' button
                if (widget.authService.currentUserNotifier.value == null) {
                  _showLoginSignupDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Redirecting to list property page (coming soon)!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A66C2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('List Your Property'),
            ),
          ],
        ),
      ),
    );
  }

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
        // Filter out 'Sell' from the links list before mapping
        ...links.where((link) => link != 'Sell').map((link) => Padding( // 'Sell' link is now removed from here
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () {
              if (onLinkTapped != null) {
                onLinkTapped(link);
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

class PropertyCardWithCarousel extends StatefulWidget {
  final Map<String, dynamic> property;
  final ValueChanged<Map<String, dynamic>> onFavoriteToggle;
  final bool isLoggedIn;
  final VoidCallback showLoginPrompt;

  const PropertyCardWithCarousel({
    super.key,
    required this.property,
    required this.onFavoriteToggle,
    required this.isLoggedIn,
    required this.showLoginPrompt,
  });

  @override
  State<PropertyCardWithCarousel> createState() => _PropertyCardWithCarouselState();
}

class _PropertyCardWithCarouselState extends State<PropertyCardWithCarousel> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  bool _showImageNavButtons = false;
  bool _isFavoriteHovered = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(property: widget.property),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16.0),
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
            MouseRegion(
              onEnter: (_) {
                if (kIsWeb) setState(() => _showImageNavButtons = true);
              },
              onExit: (_) {
                if (kIsWeb) setState(() => _showImageNavButtons = false);
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                    child: SizedBox(
                      height: 170,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.property['images'].length,
                        itemBuilder: (context, index) {
                          return Image.asset(
                            widget.property['images'][index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  if (widget.property['images'].length > 1 && (kIsWeb ? _showImageNavButtons : true)) ...[
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _buildImageNavButton(Icons.arrow_back_ios, () {
                          _pageController.previousPage(
                              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                        }),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _buildImageNavButton(Icons.arrow_forward_ios, () {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                        }),
                      ),
                    ),
                  ],
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.property['images'].length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 8.0,
                          width: _currentPageIndex == index ? 20.0 : 8.0,
                          decoration: BoxDecoration(
                            color: _currentPageIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A66C2).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        widget.property['listingType'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: MouseRegion(
                      onEnter: (_) {
                        if (kIsWeb) setState(() => _isFavoriteHovered = true);
                      },
                      onExit: (_) {
                        if (kIsWeb) setState(() => _isFavoriteHovered = false);
                      },
                      child: IconButton(
                        icon: Icon(
                          widget.property['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                          color: widget.property['isFavorite']
                              ? Colors.red
                              : (_isFavoriteHovered ? Colors.redAccent : Colors.white.withOpacity(0.7)),
                          size: 28,
                        ),
                        onPressed: () {
                          if (widget.isLoggedIn) {
                            widget.onFavoriteToggle(widget.property);
                          } else {
                            widget.showLoginPrompt();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property['price'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.property['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${widget.property['type']} - ${widget.property['listingType']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.property['location'],
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageNavButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}


class _RecommendedPropertiesCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> propertiesToDisplay;
  final bool isLargeScreen;
  final bool isMediumScreen;
  final Widget Function(Map<String, dynamic> property) buildPropertyCard;

  const _RecommendedPropertiesCarousel({
    required this.propertiesToDisplay,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.buildPropertyCard,
  });

  @override
  State<_RecommendedPropertiesCarousel> createState() => _RecommendedPropertiesCarouselState();
}

class _RecommendedPropertiesCarouselState extends State<_RecommendedPropertiesCarousel> {
  final ScrollController _scrollController = ScrollController();
  bool _showNavButtons = false;
  bool _canScrollLeft = false;
  bool _canScrollRight = true;
  bool _isFindMoreHovered = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateNavButtonState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateNavButtonState());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateNavButtonState);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateNavButtonState() {
    final maxScroll = _scrollController.position.hasContentDimensions ? _scrollController.position.maxScrollExtent : 0;
    setState(() {
      _canScrollLeft = _scrollController.offset > 0;
      _canScrollRight = _scrollController.offset < maxScroll;
    });
  }

  void _scrollLeft() {
    if (_canScrollLeft) {
      _scrollController.animateTo(
        (_scrollController.offset - 320).clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollRight() {
    if (_canScrollRight) {
      _scrollController.animateTo(
        (_scrollController.offset + 320).clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed, bool disabled) {
    return Material(
      color: Colors.white.withOpacity(disabled ? 0.5 : 0.85),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: disabled ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: disabled ? Colors.grey : const Color(0xFF0A66C2), size: 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = widget.isLargeScreen ? 320 : (widget.isMediumScreen ? 260 : 200);
    double carouselHeight = widget.isLargeScreen ? 400 : (widget.isMediumScreen ? 360 : 320);
    double horizontalPadding = widget.isLargeScreen ? 24.0 : (widget.isMediumScreen ? 16.0 : 8.0);

    return MouseRegion(
      onHover: (_) {
        if (kIsWeb) {
          setState(() {
            _showNavButtons = true;
          });
        }
      },
      onExit: (_) {
        if (kIsWeb) {
          setState(() {
            _showNavButtons = false;
          });
        }
      },
      child: Stack(
        children: [
          SizedBox(
            height: carouselHeight,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20.0),
              itemCount: widget.propertiesToDisplay.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                if (index < widget.propertiesToDisplay.length) {
                  return SizedBox(
                    width: cardWidth,
                    child: widget.buildPropertyCard(widget.propertiesToDisplay[index]),
                  );
                } else {
                  return MouseRegion(
                    onEnter: (_) => setState(() => _isFindMoreHovered = true),
                    onExit: (_) => setState(() => _isFindMoreHovered = false),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/property_listings');
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: cardWidth * 0.6,
                        height: 120.0,
                        child: CustomPaint(
                          painter: _TriangleButtonPainter(
                            isHovered: _isFindMoreHovered,
                            borderColor: const Color(0xFF0A66C2),
                            borderWidth: 2.0,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Find More',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: _isFindMoreHovered ? const Color(0xFF0A66C2) : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FaIcon(
                                    Icons.arrow_forward_ios,
                                    size: 28,
                                    color: _isFindMoreHovered ? const Color(0xFF0A66C2) : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          if (kIsWeb && _showNavButtons) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavButton(Icons.arrow_back_ios, _scrollLeft, !_canScrollLeft),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavButton(Icons.arrow_forward_ios, _scrollRight, !_canScrollRight),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TriangleButtonPainter extends CustomPainter {
  final bool isHovered;
  final Color borderColor;
  final double borderWidth;

  _TriangleButtonPainter({
    required this.isHovered,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height / 2);
    path.close();

    final Paint fillPaint = Paint();
    if (isHovered) {
      fillPaint.color = Colors.white;
    } else {
      fillPaint.shader = LinearGradient(
        colors: [
          const Color(0xFF1E90FF),
          const Color(0xFF0A66C2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    canvas.drawPath(path, fillPaint);

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _TriangleButtonPainter &&
        (oldDelegate.isHovered != isHovered ||
            oldDelegate.borderColor != borderColor ||
            oldDelegate.borderWidth != borderWidth);
  }
}

class GradientTextWidget extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;

  const GradientTextWidget({
    super.key,
    required this.text,
    required this.style,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

class BlinkingGradientText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;

  const BlinkingGradientText({
    super.key,
    required this.text,
    required this.style,
    required this.colors,
  });

  @override
  State<BlinkingGradientText> createState() => _BlinkingGradientTextState();
}

class _BlinkingGradientTextState extends State<BlinkingGradientText> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkPurple = Color(0xFF4B0082);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final Color interpolatedColor = Color.lerp(Colors.white, darkPurple, _animation.value)!;

        return GradientTextWidget(
          text: widget.text,
          style: widget.style,
          colors: [interpolatedColor, interpolatedColor],
        );
      },
    );
  }
}
