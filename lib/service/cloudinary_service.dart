
// Upload Cloudinary
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String?> uploadToCloudinary(FilePickerResult filePickerResult) async {
   String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

   if(filePickerResult.files.isEmpty) {
        print("Tidak ada file");
      return null;
   }

   File file = File(filePickerResult.files.single.path!);

   var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');
   var request = http.MultipartRequest("POST", uri);

   var fileBytes = await file.readAsBytes();

   var multipartFile = http.MultipartFile.fromBytes(
    'file', // Changed to 'file' as per Cloudinary API
    fileBytes,
    filename: file.path.split('/').last,
   );

   request.files.add(multipartFile);
   request.fields['upload_preset'] = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
   request.fields['resource_type'] = "image";

   var response = await request.send();
   var responseBody = await response.stream.bytesToString();

   if (response.statusCode == 200) {
     final jsonResponse = json.decode(responseBody);
     // Get secure URL from Cloudinary response
     String secureUrl = jsonResponse['secure_url'];
     return secureUrl; // This URL can be stored in Firestore ProfilePicture field
   } else {
     print('Upload Failed: ${response.statusCode}');
     return null;
   }
}