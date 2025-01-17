import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheelwise/utils/const.dart';
import '../../model/formData.dart';
import 'helpers/PreviewScreen.dart';

class CameraSectionPage extends StatefulWidget {
  final String formId;
  final String sectionName;

  const CameraSectionPage(
      {super.key, required this.formId, required this.sectionName});
  @override
  _CameraSectionPageState createState() => _CameraSectionPageState();
}

class _CameraSectionPageState extends State<CameraSectionPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  String? currentAddress;
  bool showOverlay = true;
  List<ImageItem> capturedMedia = [];
  bool isRecording = false;
  bool _capturedImage = false;

  bool _isLoading = true;

  bool _showBlink = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
  }

  // getData() async {
  //   final storage = await SharedPreferences.getInstance();

  //   // Retrieve existing form data from SharedPreferences
  //   String? existingFormData = storage.getString(widget.formId);
  //   Map<String, dynamic> formData = existingFormData != null
  //       ? Map<String, dynamic>.from(jsonDecode(existingFormData))
  //       : {
  //           "content": {
  //             "form-responses": [],
  //             "media": {"sectionImages": [
  //               ]
  //             },
  //           },
  //         };

  //   // Extract section images and assign them to _capturedImages if they exist
  //   var sectionData = formData['content']['media']['sectionImages'].firstWhere(
  //       (section) => section['section'] == widget.sectionName,
  //       orElse: () => null);
  //   if (sectionData != null) {

  //     sectionData = sectionData["images"];
  //     List<File> media = [];
  //     sectionData.forEach((item) => {
  //       print(item),
  //       media.add(File(item["url"].toString()))});

  //     setState(() {
  //       this.capturedMedia = media;
  //     });
  //     print(capturedMedia);
  //   }
  // }

  Future<void> _saveMedia() async {
    try {
      // Get the directory for app-specific documents
      final storage = await SharedPreferences.getInstance();

      // Load existing data if the form data exists in SharedPreferences
      String? formDataString = storage.getString(widget.formId);

      // Parse existing form data or initialize a new structure if none exists
      Map<String, dynamic> formData = formDataString != null
          ? jsonDecode(formDataString)
          : {
              "content": {
                "form-responses": [],
                "media": {
                  "sectionImages": [],
                },
              },
            };

      // Retrieve or initialize the section data
      List<dynamic> sectionImages =
          formData['content']['media']['sectionImages'];
      Map<String, dynamic>? currentSection = sectionImages.firstWhere(
        (section) => section['section'] == widget.sectionName,
        orElse: () => null,
      );

      if (currentSection == null) {
        // If the section doesn't exist, create a new one
        currentSection = {
          "section": widget.sectionName,
          "images": [],
        };
        sectionImages.add(currentSection);
      }

      // Add the captured images to the current section
      List<dynamic> imageJsonList =
          capturedMedia.map((image) => image.toJson()).toList();

// Overwrite the `images` field in the current section
      currentSection['images'] = imageJsonList;

// Save the updated form data back to SharedPreferences
      formData['content']['media']['sectionImages'] = sectionImages;
      await storage.setString(widget.formId, jsonEncode(formData));

      // Provide feedback and navigate to the next screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Files saved."),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
              top: kToolbarHeight + 10,
              left: 16,
              right: 16), // Adjust for app bar height
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error saving media: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Issue while saving the media."),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
              top: kToolbarHeight + 10,
              left: 16,
              right: 16), // Adjust for app bar height
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _initializeCamera() async {
    final storage = await SharedPreferences.getInstance();
    FormData formData;
    // Retrieve existing form data from SharedPreferences
    String? existingFormData = storage.getString(widget.formId);
    if (existingFormData != null) {
      Map<String, dynamic> temp = jsonDecode(existingFormData);
      // print(temp);
      formData = FormData.fromJson(temp);
    } else {
      print("wdjnwkhnkecjrwhebefwrvfe ncsjwruhgkbvef");
      // If no existing data, initialize default data
      formData = FormData(
        content: Content(
          // formResponses: [],
          media: Media(
              sectionImages: [],
              vehicleMedia: VehicleMedia(images: [], videos: [])),
        ),
      );
    }

    // Extract section images and assign them to _capturedImages if they exist
    var sectionData = formData.content.media.sectionImages.firstWhere(
      (section) => section.section == widget.sectionName,
      orElse: () => SectionImage(section: widget.sectionName, images: []),
    );

    if (sectionData != null) {
      setState(() {
        capturedMedia = sectionData.images; 
      });
    } else {
      setState(() {
        capturedMedia = [];
      });
    }
    print(capturedMedia);
    // Initialize the camera
    cameras = await availableCameras();
    _cameraController = CameraController(cameras![0], ResolutionPreset.high);
    await _cameraController?.initialize();


    setState(() {
      // Update the state with the loaded media
      this.capturedMedia = capturedMedia;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          currentAddress = "Location permission denied";
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Fetch address using geocoding
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          currentAddress = "${place.street}, ${place.locality}, "
              "${place.administrativeArea}, ${place.country}";
          _isLoading = false;
        });
      } else {
        setState(() {
          currentAddress = "Address not found";
        });
      }
    } catch (e) {
      setState(() {
        currentAddress = "Error fetching location: $e";
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _showBlink = true;
      });

      // Wait for the blink effect to display
      await Future.delayed(Duration(milliseconds: 200));

      final XFile file = await _cameraController!.takePicture();
      final imageFile = File(file.path);
      setState(() {
        _capturedImage = true;
      });
      setState(() {
        _showBlink = false;
        _capturedImage = true;
      });

      // Read the captured image bytes
      final imageBytes = await imageFile.readAsBytes();
      final image = await decodeImageFromList(imageBytes);

      if (image != null) {
        final recorder = PictureRecorder();
        final canvas = Canvas(
            recorder,
            Rect.fromPoints(Offset(0, 0),
                Offset(image.width.toDouble(), image.height.toDouble())));

        // Draw the captured image onto the canvas
        canvas.drawImage(image, Offset(0, 0), Paint());

        // Draw the address text
        final textPainter = TextPainter(
          text: TextSpan(
            text: currentAddress ?? "Address not available",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: image.width.toDouble());

        textPainter.paint(
            canvas,
            Offset(10,
                image.height - 30)); // Position the address at the bottom left

        // Add timestamp text
        final timestamp = DateTime.now().toString();
        final timestampPainter = TextPainter(
          text: TextSpan(
            text: timestamp,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: image.width.toDouble());

        // Position timestamp above the address
        timestampPainter.paint(canvas, Offset(10, image.height - 60));

        // Load the overlay image (e.g., logo)
        final overlayImageBytes =
            await rootBundle.load('lib/assets/app-icon/original-logo.png');
        final overlayImage =
            await decodeImageFromList(overlayImageBytes.buffer.asUint8List());

        // Draw the overlay image at the bottom left corner
        if (overlayImage != null) {
          const overlaySize = 100.0; // Set a fixed size for the overlay image
          final scaleX = 300 / overlayImage.width;
          final scaleY = overlaySize / overlayImage.height;
          final scaledOverlay =
              Size(overlayImage.width * scaleX, overlayImage.height * scaleY);

          canvas.drawImageRect(
            overlayImage,
            Rect.fromLTWH(0, 0, overlayImage.width.toDouble(),
                overlayImage.height.toDouble()),
            Rect.fromLTWH(10, image.height - 30 - scaledOverlay.height - 10,
                scaledOverlay.width, scaledOverlay.height),
            Paint(),
          );
        }

        // Get the final image with address, timestamp, and overlay
        final picture = recorder.endRecording();
        final imgWithText = await picture.toImage(image.width, image.height);

        // Save the final image with overlay
        final byteData =
            await imgWithText.toByteData(format: ImageByteFormat.png);
        final newImageFile = File(
            '${(await getTemporaryDirectory()).path}/image_with_overlay_${DateTime.now().millisecondsSinceEpoch}.png');
        await newImageFile.writeAsBytes(byteData!.buffer.asUint8List());

        String? description = await _showDescriptionDialog();

        setState(() {
          capturedMedia.add(ImageItem(
              url: newImageFile,
              description: description
                  .toString())); // Add the saved file to captured media
        });
      }
    } catch (e) {
      print("Error capturing photo: $e");
    }
  }

  void deleteFile(File fileToDelete) {
    setState(() {
      capturedMedia.removeWhere((file) => file.url.path == fileToDelete.path);
      capturedMedia.forEach((item) => {
            print(item.url == fileToDelete.path),
            print(fileToDelete.path.toString()),
            print(item.url.path)
          });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("File deleted successfully."),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            top: kToolbarHeight + 10,
            left: 16,
            right: 16), // Adjust for app bar height
      ),
    );
  }

  Future<String?> _showDescriptionDialog() async {
    TextEditingController descriptionController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Description'),
          content: TextField(
            controller: descriptionController,
            decoration:
                InputDecoration(hintText: 'Enter a description for the image'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(descriptionController.text);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel without saving
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to toggle the overlay visibility
  void _toggleTextOverlay() {
    setState(() {
      showOverlay = !showOverlay;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  bool _isValidImage(File file) {
    final List<String> validImageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp'
    ];
    final extension = file.path.split('.').last.toLowerCase();
    return validImageExtensions.contains('.$extension');
  }

  bool _isVideo(File file) {
    final List<String> videoExtensions = [
      '.mp4',
      '.avi',
      '.mov',
      '.mkv',
      '.flv',
      '.wmv',
      '.temp'
    ];
    final extension = file.path.split('.').last.toLowerCase();
    return videoExtensions.contains('.$extension');
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
  appBar: AppBar(
    title: Text("Camera"),
    backgroundColor: Colors.white,
    actions: [
      Switch(
        value: showOverlay,
        onChanged: (val) => _toggleTextOverlay(),
        activeColor: Colors.grey,
      ),
    ],
  ),
  body: Column(
    children: [
      Expanded(
        child: Center(
          child: AspectRatio(
            aspectRatio: 4 / 3, // Set the aspect ratio to 4:3
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController!),
                if (_showBlink)
                  Container(
                    color: Colors.white.withOpacity(0.7), // Semi-transparent white overlay
                  ),
                if (showOverlay && currentAddress != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Text(
                      "$currentAddress\n${DateTime.now()}",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                if (showOverlay && currentAddress != null)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Image.asset(
                      "lib/assets/app-icon/original-logo.png",
                      height: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      Container(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: capturedMedia.length,
          itemBuilder: (_, index) {
            final file = capturedMedia[index].url;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviewScreen(
                        file: file,
                        isVideo: _isVideo(file),
                      ),
                    ),
                  );
                },
                child: _isVideo(file)
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            color: Colors.black,
                            child: Icon(Icons.play_arrow,
                                color: Colors.white, size: 40),
                          ),
                          Positioned(
                            top: -0,
                            right: -5,
                            child: GestureDetector(
                              onTap: () => {deleteFile(file)},
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      )
                    : (_isValidImage(file)
                        ? Stack(
                            children: [
                              Image.file(
                                file,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: -0,
                                right: -5,
                                child: GestureDetector(
                                  onTap: () => {deleteFile(file)},
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                color: Colors.red,
                                child: Icon(Icons.error, color: Colors.white),
                              )
                            ],
                          )),
              ),
            );
          },
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: _capturePhoto,
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.3,
              padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white),
                color: Colors.black,
              ),
              child: Text(
                "Capture Photo",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          GestureDetector(
            onTap: _saveMedia,
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.3,
              padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white),
                color: Colors.black,
              ),
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ],
  ),
);

  }
}
