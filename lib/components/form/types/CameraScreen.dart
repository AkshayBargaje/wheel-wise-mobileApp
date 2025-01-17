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
import 'package:wheelwise/components/form/SucessScreen.dart';
import 'package:wheelwise/helpers/loading_indicator.dart';
import 'package:wheelwise/utils/const.dart';
import '../../model/formData.dart';
import '../../model/uploadformresponses.dart';
import 'helpers/PreviewScreen.dart';

class CameraScreen extends StatefulWidget {
  final String formId;

  const CameraScreen({super.key, required this.formId});
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  String? currentAddress;
  bool showOverlay = true;
  List<File> capturedMedia = [];
  bool isRecording = false;
  bool _isLoading = false;
  bool _diablebutton = false;

  bool _showBlink = false;
  bool _capturedImage = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
  }

  Future<void> _saveMedia() async {
setState(() {
      _diablebutton = true;

});    try {
      // Get the directory for app-specific documents
      final directory = await getApplicationDocumentsDirectory();
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
                  "vehicalmedia": {"images": [], "videos": []}
                },
              },
            };

// Prepare the new media data for images and videos
      final newImageData = capturedMedia.where(_isValidImage).map((file) {
        return file.path;
      }).toList();

      final newVideoData = capturedMedia.where(_isVideo).map((file) {
        return file.path;
      }).toList();

// Override the existing media data in vehicalmedia
      formData['content']['media']["vehicalmedia"]['images'] = newImageData;
      formData['content']['media']["vehicalmedia"]['videos'] = newVideoData;

// Save the updated form data back to SharedPreferences
      await storage.setString(widget.formId, jsonEncode(formData));

// Provide feedback and navigate to the next screen
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Media saved successfully."),
      //   ),
      // );
      var resp = await uploadMediaToAPI(formData, widget.formId);
      
      if(resp==true){
              setState(() {
        _diablebutton = false;
      });

              Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:  (context) => SuccessScreen(
          ),
        ),
      );
      }
    } catch (e) {
      print("Error saving media: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save media. $e"),
        ),
      );
setState(() {
        _diablebutton = false;
      });

    }
  }

  Future<void> _initializeCamera() async {
    final storage = await SharedPreferences.getInstance();

// Retrieve existing form data from SharedPreferences
    String? existingFormData = storage.getString(widget.formId);

// If no existing data, initialize default data
    FormData formData = existingFormData != null
        ? FormData.fromJson(jsonDecode(existingFormData))
        : FormData(
            content: Content(
              // formResponses: [],
              media: Media(
                  sectionImages: [],
                  vehicleMedia: VehicleMedia(
                      images: [], videos: [])), // Initialize with empty data
            ),
          );

// Extract vehicle media section
    var vehicleData = formData.content.media.vehicleMedia;

// Convert vehicle images and videos to List<File>
    List<File> capturedMedia = [];

// If `vehicleData.images` contains file paths (strings), convert to `File` objects
    capturedMedia
        .addAll(vehicleData.images.map((imagePath) => File(imagePath)));

// If `vehicleData.videos` contains file paths (strings), convert to `File` objects
    capturedMedia
        .addAll(vehicleData.videos.map((videoPath) => File(videoPath)));

// Now `capturedMedia` is a List<File> containing all the media (images + videos)
    print(capturedMedia);

// Initialize the camera
    cameras = await availableCameras();
    _cameraController = CameraController(cameras![0], ResolutionPreset.high);
    await _cameraController?.initialize();

    setState(() {
      // Update the state with the loaded media
      this.capturedMedia = capturedMedia;
      _isLoading = false;
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

  Future<void> _captureVideo() async {
    if (isRecording) {
      // Stop recording
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        isRecording = false;
        capturedMedia.add(File(videoFile.path));
      });
    } else {
      // Start recording
      await _cameraController!.startVideoRecording();
      setState(() {
        isRecording = true;
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

      final XFile file = await _cameraController!.takePicture();
      final imageFile = File(file.path);

      // Read the captured image bytes
      final imageBytes = await imageFile.readAsBytes();
      final image = await decodeImageFromList(imageBytes);


      setState(() {
        _capturedImage = true;
      });
      setState(() {
        _showBlink = false;
        _capturedImage = true;
      });
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
          const overlaySize = 50.0; // Set a fixed size for the overlay image
          final scaleX = overlaySize / overlayImage.width;
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

        setState(() {
          capturedMedia
              .add(newImageFile); // Add the saved file to captured media
        });
      }
    } catch (e) {
      print("Error capturing photo: $e");
    }
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

  void deleteVehicleMedia(String mediaPath, String mediaType) async {

    setState(() {
    capturedMedia.removeWhere((file) => file.path == mediaPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "${mediaType == 'images' ? 'Image' : 'Video'} deleted successfully."),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            top: kToolbarHeight + 10,
            left: 16,
            right: 16,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Camera"),
        backgroundColor: Colors.white,
        actions: [
          // You can call _toggleTextOverlay() here or use the switch as before
          Switch(
            value: showOverlay,
            onChanged: (val) => _toggleTextOverlay(),
            activeColor: AppColors.greyColor,
          ),
        ],
      ),
      body: 
      _diablebutton ? LoadingScreen():
      Column(
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
                final file = capturedMedia[index];

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
                                      onTap: () => {
                                        deleteVehicleMedia(file.path, "videos")
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ))
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
                                          onTap: () => {
                                            deleteVehicleMedia(
                                                file.path, "images")
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ))
                                  ],
                                )
                              : Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.red,
                                      child: Icon(Icons.error,
                                          color: Colors.white),
                                    )
                                  ],
                                ))),
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
                        color: AppColors.black),
                    child: Text(
                      "Capture Photo",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              GestureDetector(
                onTap: _captureVideo,
                child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.3,
                    padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white),
                        color: AppColors.black),
                    child: Text(
                      isRecording ? "Stop Recording" : "Record Video",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              GestureDetector(
                onTap: ()=>{
              _diablebutton ?null:_saveMedia()
                },
                child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.3,
                    padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white),
                        color: AppColors.black),
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
