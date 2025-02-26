import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static Future<String?> uploadFile(dynamic file) async {
    try {
      String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
      
      // Handle different file types
      File? uploadFile;
      String? filename;
      
      if (file is XFile) {
        uploadFile = File(file.path);
        filename = file.name;
      } else if (file is FilePickerResult) {
        if (file.files.isEmpty) return null;
        uploadFile = File(file.files.single.path!);
        filename = file.files.single.name;
      } else {
        throw Exception('Unsupported file type');
      }

      var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      var request = http.MultipartRequest('POST', uri);

      // Read file bytes
      var fileBytes = await uploadFile.readAsBytes();

      // Create multipart file
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      );

      // Add file to request
      request.files.add(multipartFile);
      
      // Add upload preset
      request.fields['upload_preset'] = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var parsedResponse = json.decode(responseData);
        return parsedResponse['secure_url'];
      } else {
        print('Upload failed: ${response.statusCode}');
        print('Response: $responseData');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }
}