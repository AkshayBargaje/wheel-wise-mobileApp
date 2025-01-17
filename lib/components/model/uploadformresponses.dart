import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/jwt_storage.dart';

Future<bool> uploadMediaToAPI(
    Map<String, dynamic> savedData, String formId) async {
  var uri = Uri.parse(
      'http://${dotenv.env['HOST']}/api/inspections'); // Replace with your actual API endpoint

  var request = http.MultipartRequest('POST', uri);

  String? token = await SecureStorageService.getJwt();

  // Add Authorization header with Bearer token
  request.headers['Authorization'] = 'Bearer $token';

  // Construct the content object with the required structure
  Map<String, dynamic> content = {
    'formId': formId,
    'form-responses': savedData['content']
        ['form-responses'], // Existing form responses
  };

  // Attach the JSON body to the request
  request.fields['content'] = jsonEncode(content);


  // Add vehicalmedia images and videos
  List<String> vehicalImages =
      savedData['content']['media']['vehicalmedia']['images'] ?? [];
  print(vehicalImages);
  List<String> vehicalVideos =
      savedData['content']['media']['vehicalmedia']['videos'] ?? [];
  print(vehicalVideos);

  Map<String, List<String>> groupedImages = {};
  for (var sectionImage
      in savedData['content']['media']['sectionImages'] ?? []) {
    if (sectionImage['section'] != "string") {
      String sectionName = sectionImage['section'];
      List<String> images = (sectionImage['images'] ?? [])
          .map<String>((image) =>
              '${image['url'].toString()}:${image['description'].toString()}')
          .toList();
      groupedImages[sectionName] = images;
    }
  }

// Prepare multipart data for grouped images
  for (var entry in groupedImages.entries) {
    String section = entry.key;
    List<String> images = entry.value;

    // Loop over each image (which contains the URL and description as colon-separated)
    for (var imagePath in images) {
      var parts = imagePath.split(":");
      String imageUrl = parts[0]; // Image URL
      String description =
          parts.length > 1 ? parts[1] : ""; // Image description

      // Convert image URL to a file path for uploading
      var imageFile = File(imageUrl);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      // Prepare multipart file with both image and description
      request.files.add(http.MultipartFile(
        '$description:$section', // Section name as the field name
        stream,
        length,
        filename: basename(imageFile.path),
        contentType: MediaType.parse('image/jpeg'),
      ));
    }
  }

  // Add vehicalmedia images
  for (var imagePath in vehicalImages) {
    var imageFile = File(imagePath);
    var stream = http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();

    request.files.add(http.MultipartFile(
      'vehical_images',
      stream,
      length,
      filename: basename(imageFile.path),
      contentType: MediaType.parse('image/jpeg'),
    ));
  }

  // Add vehicalmedia videos
  for (var videoPath in vehicalVideos) {
    var videoFile = File(videoPath);
    var stream = http.ByteStream(videoFile.openRead());
    var length = await videoFile.length();

    request.files.add(http.MultipartFile(
      'vehical_videos',
      stream,
      length,
      filename: basename(videoFile.path),
      contentType: MediaType.parse('video/mp4'),
    ));
  }
  // Send the request

  var response = await request.send();
  if (response.statusCode == 200) {
    // Read response data if necessary
    var responseBody = await response.stream.bytesToString();
    var result = jsonDecode(responseBody);
    // print("Media uploaded successfully: $result");
    await deleteMedia(savedData);
    await clearFormData(savedData);

    return true;

  } else {
    print("Failed to upload media: ${response.statusCode}");
    var errorResponse = await response.stream.bytesToString();
    print("Error response: $errorResponse");
    return false;
  }
}

Future<void> deleteMedia(Map<String, dynamic> savedData) async {
  try {
    // Delete vehical images
    List<String> vehicalImages =
        savedData['content']['media']['vehicalmedia']['images'] ?? [];
    for (var imagePath in vehicalImages) {
      var file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print("Deleted file: $imagePath");
      }
    }

    // Delete vehical videos
    List<String> vehicalVideos =
        savedData['content']['media']['vehicalmedia']['videos'] ?? [];
    for (var videoPath in vehicalVideos) {
      var file = File(videoPath);
      if (await file.exists()) {
        await file.delete();
        print("Deleted file: $videoPath");
      }
    }

    // Delete section images
    for (var sectionImage
        in savedData['content']['media']['sectionImages'] ?? []) {
      for (var image in sectionImage['images'] ?? []) {
        String imagePath = image['url'];
        var file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          print("Deleted file: $imagePath");
        }
      }
    }
  } catch (e) {
    print("Error deleting media: $e");
  }
}

Future<void> clearFormData(Map<String, dynamic> savedData) async {
  try {
    savedData.clear();
    print("Form data cleared successfully.");

    // If using SharedPreferences to store form data, clear it as well
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("SharedPreferences cleared successfully.");
  } catch (e) {
    print("Error clearing form data: $e");
  }
}
