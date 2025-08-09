// lib/services/cloudinary_service.dart

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

// Conditional import for non-web platforms
import 'dart:io' if (dart.library.html) 'dart:html';

class CloudinaryService {
  final String _cloudName = 'dvagjmalj';
  final String _uploadPreset = 'journal_app_uploads';

  Future<String?> uploadImage(XFile imageFile) async {
    final String uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['upload_preset'] = _uploadPreset;

      if (kIsWeb) {
        // Handle image upload for web
        final imageData = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          imageData,
          filename: imageFile.name,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        // Handle image upload for mobile/desktop
        // Corrected to use fromPath for non-web platforms.
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(responseBody);
        return data['secure_url'];
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Cloudinary upload failed with status ${response.statusCode}: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<List<String>> uploadMultipleImages(List<XFile> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      final url = await uploadImage(image);
      if (url != null) {
        imageUrls.add(url);
      }
    }
    return imageUrls;
  }
}