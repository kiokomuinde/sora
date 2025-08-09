// lib/services/web_image_uploader.dart
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service.dart';

class WebImageUploader implements ImageUploader {
  final String _cloudName = 'YOUR_CLOUD_NAME';
  final String _uploadPreset = 'YOUR_UPLOAD_PRESET';

  @override
  Future<String?> uploadImage(XFile imageFile) async {
    final String uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';
    
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            await imageFile.readAsBytes(),
            filename: imageFile.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseBody);
        return data['secure_url'];
      } else {
        print('Cloudinary upload failed: ${response.statusCode}');
        print('Response body: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  @override
  Future<List<String>> uploadMultipleImages(List<XFile> imageFiles) async {
    List<Future<String?>> uploadFutures = imageFiles.map((image) => uploadImage(image)).toList();
    List<String?> uploadedUrls = await Future.wait(uploadFutures);
    return uploadedUrls.where((url) => url != null).cast<String>().toList();
  }
}