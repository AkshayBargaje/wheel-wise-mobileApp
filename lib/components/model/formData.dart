import 'dart:convert';
import 'dart:io';

class FormData {
  Content content;

  FormData({required this.content});

  factory FormData.fromJson(Map<String, dynamic> json) {
    print(json);
    return FormData(
      content: Content.fromJson(json["content"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.toJson(),
    };
  }
}

class Content {
  // List<FormResponse> formResponses;
  Media media;
   // Added vehicleMedia

  Content({required this.media});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      // formResponses: (json['form-responses'] as List)
      //     .map((item) => FormResponse.fromJson(item))
      //     .toList(),
      media: Media.fromJson(json['media']), // Parsing vehicleMedia
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'form-responses': formResponses.map((item) => item.toJson()).toList(),
      'media': media.toJson(),
    };
  }
}

// class FormResponse {
//   String? sectionName; // Section name like 'section1', 'section2'
//   String? whatToCheck;
//   String? description;
//   String? condition;
//   String? rating;

//   FormResponse({
//     this.sectionName,
//     this.whatToCheck,
//     this.description,
//     this.condition,
//     this.rating,
//   });

//   // Factory constructor to parse JSON data into FormResponse object
//   factory FormResponse.fromJson(Map<String, dynamic> json) {
//     List<FormResponse> responses = [];
    
//     // Iterate through sections in the JSON and map data
//     json.forEach((section, data) {
//       if (data is List) {
//         // Handle multiple responses in an array for sections like 'section1'
//         for (var item in data) {
//           responses.add(FormResponse(
//             sectionName: section,
//             whatToCheck: item["What to Check"],
//             description: item["Description"],
//             condition: item["response"]["condition"],
//             rating: item["response"]["rating"],
//           ));
//         }
//       } else if (data is Map) {
//         // Handle single response for sections like 'section2'
//         responses.add(FormResponse(
//           sectionName: section,
//           whatToCheck: data["What to Check"],
//           description: data["Description"],
//           condition: data["response"]["condition"],
//           rating: data["response"]["rating"],
//         ));
//       }
//     });

//     return response;
//   }

//   // Convert FormResponse to JSON format
//   Map<String, dynamic> toJson() {
//     return {
//       'sectionName': sectionName,
//       'What to Check': whatToCheck,
//       'Description': description,
//       'response': {
//         'condition': condition,
//         'rating': rating,
//       },
//     };
//   }
// }

class Media {
  List<SectionImage> sectionImages;
  VehicleMedia vehicleMedia;

  Media({required this.sectionImages,required this.vehicleMedia});

  factory Media.fromJson(Map<String, dynamic> json) {
    print(VehicleMedia.fromJson(json['vehicalmedia']));
    print(json);
    return Media(
      sectionImages: (json['sectionImages'] as List)
          .map((item) => SectionImage.fromJson(item))
          .toList(),
      vehicleMedia: VehicleMedia.fromJson(json['vehicalmedia'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionImages': sectionImages.map((item) => item.toJson()).toList(),
    };
  }
}

class VehicleMedia {
  List<String> images; // List of image URLs
  List<String> videos; // List of video URLs

  VehicleMedia({required this.images, required this.videos});

  factory VehicleMedia.fromJson(Map<String, dynamic> json) {
    print(json);
    return VehicleMedia(
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'images': images,
      'videos': videos,
    };
  }
}

class SectionImage {
  String section;
  List<ImageItem> images;

  SectionImage({required this.section, required this.images});

  factory SectionImage.fromJson(Map<String, dynamic> json) {
    print("in section Image");
    return SectionImage(
      section: json['section'],
      images: (json['images'] as List)
          .map((item) => ImageItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section': section,
      'images': images.map((item) => item.toJson()).toList(),
    };
  }
}

class ImageItem {
  File url;
  String description;

  ImageItem({required this.url, required this.description});

  // Factory method to create an ImageItem from JSON
  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      url: File(json['url']), // Convert string to File
      description: json['description'],
    );
  }

  // Method to convert an ImageItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'url': url.path, // Convert File to string (path)
      'description': description,
    };
  }
}
