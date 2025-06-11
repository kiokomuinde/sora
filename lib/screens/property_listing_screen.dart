// /lib/screens/property_listing_screen.dart

import 'package:flutter/material.dart';
import 'package:sora_app/screens/property_detail_screen.dart'; // Make sure this file exists

class PropertyListingScreen extends StatefulWidget {
  const PropertyListingScreen({Key? key}) : super(key: key);

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  // Dummy property data - NOW USING YOUR NEW LIST
  final List<Map<String, dynamic>> _properties = [
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
      "area": "7000", // Area in sq ft or sq meters
      "type": "Mansion",
      "listingType": "Buy",
      "description":
          "A beautiful 3-bedroom mansion located in Olekasasi town. Comes with a spacious living room, modern kitchen, and a large compound.",
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
      "description":
          "Modern studio apartment located in Kilimani, Nairobi. Close to shops, schools, and transport hubs.",
      "isFavorite": true,
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
      "description":
          "Luxurious villa with top-notch finishes. Includes private pool, garage, and security system.",
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
      "area": "1 acre", // Example area in acres
      "type": "Mansion",
      "listingType": "Buy",
      "description":
          "Luxurious mansion with top-notch finishes. Includes private pool, garage, and security system.",
      "isFavorite": false,
    },
    {
      "title": "Office Space - Westlands",
      "price": "KSH 200,000/month",
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
      "description":
          "Spacious office space available for rent in Westlands, Nairobi. Ideal for businesses looking for central location.",
      "isFavorite": true,
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
      "description":
          "Spacious office space available for rent in Westlands, Nairobi. Ideal for businesses looking for central location.",
      "isFavorite": true,
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
      "description":
          "Luxurious villa with top-notch finishes. Includes private pool, garage, and security system.",
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
      "area": "5000", // Area in sq ft or sq meters
      "type": "Mansion",
      "listingType": "Buy",
      "description":
          "A beautiful 4-bedroom mansion located in Olekasasi town. Comes with a spacious living room, modern kitchen, and a large compound.",
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
      "isFavorite": true,
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
      "isFavorite": true,
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
      "isFavorite": true,
    },

    {
      "title": "Beautiful 4-Bedroom Villa - Diani, Mombasa",
      "price": "KSH 2,500,000/month",
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
      "isFavorite": true,
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
      "isFavorite": true,
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
      "isFavorite": true,
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
      "isFavorite": true,
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
      "isFavorite": true,
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
      "isFavorite": true,
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
      "isFavorite": true,
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
      "isFavorite": true,
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
    
  ];

  bool _showFilters = false;
  // Constants for the price mapping
  static const double _minKshPrice = 2000.0;
  static const double _firstBreakKshPrice = 100000.0; // 100K
  static const double _midKshPrice = 1000000.0; // 1M
  static const double _maxKshPrice = 250000000.0; // 250M

  static const double _sliderMin = 0.0;
  static const double _sliderMax = 100.0;
  static const double _sliderFirstQuarterPoint = _sliderMax / 4; // 25.0
  static const double _sliderHalfPoint = _sliderMax / 2; // 50.0

  // Initialize slider value to the new maximum (100.0)
  double _currentSliderValue = _sliderMax; 

  String? _selectedSortField = 'title'; // Default sort field (internal key)
  String _sortOrder = 'increasing'; // Default sort order

  // Map to store display names and their corresponding internal keys for sorting
  final List<Map<String, String>> _sortableFieldsMap = [
    {'display': 'Name', 'key': 'title'},
    {'display': 'Price', 'key': 'price'},
    {'display': 'Location', 'key': 'location'},
    {'display': 'Type', 'key': 'type'},
    {'display': 'Bedrooms', 'key': 'bedrooms'},
    {'display': 'Area', 'key': 'area'},
    {'display': 'Listing Type', 'key': 'listingType'},
  ];

  List<Map<String, dynamic>> _filteredAndSortedProperties = []; // The list actually displayed
  final TextEditingController _searchController = TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    // Initialize with a sorted and then filtered (if any default filter) version of _properties
    _filteredAndSortedProperties = List.from(_properties);
    // Apply initial filter (which will show all properties by default)
    _applyFilter();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFavorite(int index) {
    setState(() {
      // Find the property in the original list and update its favorite status
      final originalPropertyIndex = _properties.indexOf(_filteredAndSortedProperties[index]);
      if (originalPropertyIndex != -1) {
        _properties[originalPropertyIndex]['isFavorite'] = !_properties[originalPropertyIndex]['isFavorite'];
      }
      // Also update the displayed list's favorite status immediately
      _filteredAndSortedProperties[index]['isFavorite'] = !_filteredAndSortedProperties[index]['isFavorite'];
    });
  }

  // Helper to parse price string to a comparable double
  double _parsePrice(String priceString) {
    String cleanPrice = priceString
        .replaceAll('KSH', '')
        .replaceAll('/month', '')
        .replaceAll('/year', '') // Handles '/year'
        .replaceAll(',', '')
        .trim();
    if (cleanPrice.endsWith('M')) {
      return double.tryParse(cleanPrice.replaceAll('M', ''))! * 1000000;
    } else if (cleanPrice.endsWith('K')) { // Handle K for thousands
      return double.tryParse(cleanPrice.replaceAll('K', ''))! * 1000;
    }
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  // Helper to parse area (handles 'acre' conversion)
  double _parseArea(dynamic areaValue) {
    if (areaValue is num) {
      return areaValue.toDouble();
    } else if (areaValue is String) {
      String cleanArea = areaValue.toLowerCase().replaceAll(' ', '').trim();
      if (cleanArea.endsWith('acre')) {
        double? value = double.tryParse(cleanArea.replaceAll('acre', ''));
        return value != null ? value * 4046.86 : 0.0; // Convert acres to square meters
      }
      return double.tryParse(cleanArea) ?? 0.0;
    }
    return 0.0;
  }

  // This function is now responsible for sorting _filteredAndSortedProperties directly.
  // It is called by _applyFilter after filtering is done, and by the sort dialog.
  void _sortProperties(String field, String order) {
    _filteredAndSortedProperties.sort((a, b) {
      dynamic valA;
      dynamic valB;

      if (field == 'price') {
        valA = _parsePrice(a['price']);
        valB = _parsePrice(b['price']);
      } else if (field == 'bedrooms') {
        valA = (a['bedrooms'] as num).toDouble();
        valB = (b['bedrooms'] as num).toDouble();
      } else if (field == 'area') {
        valA = _parseArea(a['area']);
        valB = _parseArea(b['area']);
      } else {
        // Access the actual data field using the 'key' (e.g., 'title' for 'Name')
        valA = a[field].toString();
        valB = b[field].toString();
      }

      int comparison;
      if (valA is String && valB is String) {
        comparison = valA.compareTo(valB);
      } else if (valA is num && valB is num) {
        comparison = valA.compareTo(valB);
      } else {
        comparison = 0; // Should not happen with robust parsing
      }

      return order == 'increasing' ? comparison : -comparison;
    });
  }

  void _showSortingOptions() {
    String? tempSelectedField = _selectedSortField; // Use the internal key for selection
    String tempSortOrder = _sortOrder;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Sort Properties By"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sort Field:", style: TextStyle(fontWeight: FontWeight.bold)),
                    ..._sortableFieldsMap.map((fieldMap) {
                      return RadioListTile<String>(
                        title: Text(fieldMap['display']!), // Display the friendly name
                        value: fieldMap['key']!, // Use the internal key as the value
                        groupValue: tempSelectedField,
                        onChanged: (String? value) {
                          setDialogState(() {
                            tempSelectedField = value;
                          });
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    const Text("Sort Order:", style: TextStyle(fontWeight: FontWeight.bold)),
                    RadioListTile<String>(
                      title: const Text("Increasing"),
                      value: 'increasing',
                      groupValue: tempSortOrder,
                      onChanged: (String? value) {
                        setDialogState(() {
                          tempSortOrder = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text("Decreasing"),
                      value: 'decreasing',
                      groupValue: tempSortOrder,
                      onChanged: (String? value) {
                        setDialogState(() {
                          tempSortOrder = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text("Okay"),
                  onPressed: () {
                    setState(() {
                      _selectedSortField = tempSelectedField;
                      _sortOrder = tempSortOrder;
                    });
                    // Re-apply all filters and sorting after sort options change
                    _applyFilter(); 
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to get the actual KSH price from the slider's linear value (0-100)
  double _getKshPriceFromSliderValue(double sliderValue) {
    if (sliderValue <= _sliderFirstQuarterPoint) {
      // Map from [_sliderMin, _sliderFirstQuarterPoint] to [_minKshPrice, _firstBreakKshPrice]
      double normalizedSlider = (sliderValue - _sliderMin) / (_sliderFirstQuarterPoint - _sliderMin);
      return _minKshPrice + normalizedSlider * (_firstBreakKshPrice - _minKshPrice);
    } else if (sliderValue <= _sliderHalfPoint) {
      // Map from (_sliderFirstQuarterPoint, _sliderHalfPoint] to (_firstBreakKshPrice, _midKshPrice]
      double normalizedSlider = (sliderValue - _sliderFirstQuarterPoint) / (_sliderHalfPoint - _sliderFirstQuarterPoint);
      return _firstBreakKshPrice + normalizedSlider * (_midKshPrice - _firstBreakKshPrice); 
    } else {
      // Map from (_sliderHalfPoint, _sliderMax] to (_midKshPrice, _maxKshPrice]
      double normalizedSlider = (sliderValue - _sliderHalfPoint) / (_sliderMax - _sliderHalfPoint);
      return _midKshPrice + normalizedSlider * (_maxKshPrice - _midKshPrice);
    }
  }

  // Helper to format price for display on the slider label
  String _formatPriceLabel(double sliderValue) {
    double actualKshPrice = _getKshPriceFromSliderValue(sliderValue);
    if (actualKshPrice >= 1000000) {
      return "KSH ${(actualKshPrice / 1000000).toStringAsFixed(actualKshPrice % 1000000 == 0 ? 0 : 1)}M";
    } else if (actualKshPrice >= 1000) {
      return "KSH ${(actualKshPrice / 1000).toStringAsFixed(actualKshPrice % 1000 == 0 ? 0 : 1)}K";
    } else {
      return "KSH ${actualKshPrice.toInt()}";
    }
  }

  // Function to apply all filters (search, price) and then sort
  void _applyFilter() {
    setState(() {
      List<Map<String, dynamic>> tempFilteredList = List.from(_properties);
      String searchQuery = _searchController.text.toLowerCase();

      // 1. Apply Search Filter
      if (searchQuery.isNotEmpty) {
        tempFilteredList = tempFilteredList.where((property) {
          // Search by title (which is 'Name' to the user), price, location, or type
          return (property['title'] as String).toLowerCase().contains(searchQuery) ||
                 _parsePrice(property['price']).toString().contains(searchQuery) || 
                 (property['location'] as String).toLowerCase().contains(searchQuery) ||
                 (property['type'] as String).toLowerCase().contains(searchQuery);
        }).toList();
      }

      // 2. Apply Price Filter to the search-filtered list
      double maxFilterPrice = _getKshPriceFromSliderValue(_currentSliderValue);
      tempFilteredList = tempFilteredList.where((property) {
        double price = _parsePrice(property['price']);
        return price >= _minKshPrice && price <= maxFilterPrice;
      }).toList();

      // 3. Assign to the displayed list and apply Sorting
      _filteredAndSortedProperties = tempFilteredList;
      if (_selectedSortField != null) {
        _sortProperties(_selectedSortField!, _sortOrder);
      }

      // Hide filter section after applying (optional, but requested previously)
      _showFilters = false; 
    });
  }

  // Function to reset all filters
  void _resetFilters() {
    setState(() {
      _currentSliderValue = _sliderMax; // Reset slider to max slider value (100.0)
      _searchController.clear(); // Clear search query
      _applyFilter(); // Re-apply filter to show all properties within the new range
      _showFilters = false; // Hide the filter section after resetting
    });
  }

  // Helper to get the display name for the current sort field
  String _getCurrentSortDisplayName() {
    return _sortableFieldsMap.firstWhere(
      (element) => element['key'] == _selectedSortField,
      orElse: () => {'display': 'Name', 'key': 'title'}, // Default to 'Name' if not found
    )['display']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Properties"),
        actions: [
          // Sort Button - Now a pill-shaped button showing current sort property
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Adjusted padding for text
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0), // Pill shape for visual appeal
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2), // Subtle shadow for depth
                  ),
                ],
              ),
              child: InkWell( // Use InkWell for custom tap behavior and ripple effect
                onTap: _showSortingOptions,
                borderRadius: BorderRadius.circular(25.0), // Match container border for ripple
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Keep row compact
                  children: [
                    const Icon(
                      Icons.sort,
                      color: Color(0xFF1E90FF),
                      size: 20, // Slightly smaller icon to fit with text
                    ),
                    const SizedBox(width: 6), // Space between icon and text
                    Text(
                      'Sort: ${_getCurrentSortDisplayName()}', // Dynamically display the current sort field's friendly name
                      style: const TextStyle(
                        fontSize: 12, // Adjusted font size for visibility
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E90FF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Filter Button (remains as a circular icon button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // White background for visibility
                shape: BoxShape.circle, // Circular shape for a cool look
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2), // Subtle shadow for depth
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                color: const Color(0xFF1E90FF), // Icon color matching AppBar
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                tooltip: 'Filter Properties', // Added tooltip for accessibility
              ),
            ),
          ),
        ],
        backgroundColor: const Color(0xFF1E90FF),
      ),
      body: CustomScrollView( // Using CustomScrollView for more flexible layout
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by location, name, price, or type...", // Updated hint text
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => _applyFilter(), // Trigger filter on text change
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Filters section
          if (_showFilters)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverToBoxAdapter(
                child: Card(
                  elevation: 4, // Slightly increased elevation for filters card
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Filter by",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Price Range: KSH 2K to ${_formatPriceLabel(_currentSliderValue)}", // Updated label for min and max
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        Slider(
                          value: _currentSliderValue,
                          min: _sliderMin, // Slider min value (0.0)
                          max: _sliderMax, // Slider max value (100.0)
                          // Divisions to allow for granular steps on the 0-100 scale
                          divisions: (_sliderMax - _sliderMin).round(), // 100 divisions
                          label: _formatPriceLabel(_currentSliderValue), // Formatted label
                          onChanged: (double value) {
                            setState(() {
                              _currentSliderValue = value;
                            });
                            // Removed _applyFilter() here, so slider doesn't disappear on drag.
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _resetFilters, // Made functional and hides filter
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                              ),
                              child: const Text("Reset"),
                            ),
                            ElevatedButton(
                              onPressed: _applyFilter, // Made functional and hides filter
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E90FF),
                              ),
                              child: const Text("Apply"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid( // Using SliverGrid for responsive card layout
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 600.0, // Retained maximum width to ensure single card on smaller screens
                mainAxisSpacing: 16.0, // Spacing between rows
                crossAxisSpacing: 16.0, // Spacing between columns
                childAspectRatio: 1.2, // Further adjusted aspect ratio to reduce card height
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int i) {
                  final property = _filteredAndSortedProperties[i]; // Use the filtered and sorted list
                  return Card(
                    elevation: 8, // Increased elevation for a more prominent shadow
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded corners
                    clipBehavior: Clip.antiAlias, // Ensures content is clipped to the rounded corners
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailScreen(property: property),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), // Matched card border radius
                                child: (() {
                                  String imagePath = property['images'][0];
                                  bool isNetwork = imagePath.startsWith('http');

                                  if (isNetwork) {
                                    return Image.network(
                                      imagePath,
                                      height: 180, // Fixed height for image
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                                      ),
                                    );
                                  } else {
                                    return Image.asset(
                                      imagePath,
                                      height: 180, // Fixed height for image
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                                      ),
                                    );
                                  }
                                })(),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _toggleFavorite(i),
                                    child: Icon(
                                      property['isFavorite']
                                          ? Icons.favorite
                                          : Icons.favorite_outline,
                                      color: property['isFavorite'] ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0), // Reduced overall padding
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property['title'], // 'title' is the internal field name
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2), // Reduced spacing
                                // Display Type and Listing Type
                                Text(
                                  '${property['type']} - ${property['listingType']}', 
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4), // Reduced spacing
                                Text(
                                  property['price'],
                                  style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold), // Emphasized price
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4), // Reduced spacing
                                // Display Bedrooms and Area on the same line
                                Row(
                                  children: [
                                    Icon(Icons.king_bed, size: 16, color: Colors.grey[600]), 
                                    const SizedBox(width: 4),
                                    Text(
                                      '${property['bedrooms']} Br', // Changed 'Beds' to 'Br'
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 12), // Spacing between Br and Area
                                    Icon(Icons.square_foot, size: 16, color: Colors.grey[600]), 
                                    const SizedBox(width: 4),
                                    Expanded( // Use Expanded to ensure area text fits
                                      child: Text(
                                        property['area'].toString().contains('acre') 
                                            ? property['area'] 
                                            : '${property['area']} sq ft', 
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        overflow: TextOverflow.ellipsis, // Ensure overflow handling
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4), // Reduced spacing
                                // Existing location
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        property['location'],
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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
                },
                childCount: _filteredAndSortedProperties.length, // Use the filtered and sorted list count
              ),
            ),
          ),
        ],
      ),
    );
  }
}