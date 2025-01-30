// uploading files to cloudinary
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:http/http.dart" as http;

import 'package:image_picker/image_picker.dart';

Future<String?> uploadToCloudinary(XFile? xFile) async {
  if (xFile == null) {
    print("No file selected!");
    return null;
  }

  // Get the Cloudinary cloud name from environment variables
  String cloudName = dotenv.env['CLOUDINARY-CLOUD_NAME'] ?? '';

  // Create a MultipartRequest to upload the file
  var uri =
      Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
  var request = http.MultipartRequest("POST", uri);

  // Read the file content as bytes using xFile.bytes() if it's an XFile
  var fileBytes = await xFile.readAsBytes();

  var multipartFile = http.MultipartFile.fromBytes(
    'file', // The form field name for the file
    fileBytes,
    filename: xFile.name, // Use the name of the XFile
  );

  // Add the file part to the request
  request.files.add(multipartFile);

  // Add other form fields like 'upload_preset' and 'resource_type'
  request.fields['upload_preset'] = "Preset for shopping application";
  request.fields['resource_type'] = "image";

  // Send the request and await the response
  var response = await request.send();

  // Get the response as text
  var responseBody = await response.stream.bytesToString();

  // Print the response
  print(responseBody);

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(responseBody);
    // Print the secure URL of the uploaded file
    print("Upload successful!");
    return jsonResponse["secure_url"];
  } else {
    print("Upload failed with status: ${response.statusCode}");
    return null;
  }
}
