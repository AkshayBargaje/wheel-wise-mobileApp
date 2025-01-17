import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewScreen extends StatefulWidget {
  final File file;
  final bool isVideo;

  const PreviewScreen({
    Key? key,
    required this.file,
    required this.isVideo,
  }) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    // Initialize video player if the file is a video
    if (widget.isVideo) {
      _videoController = VideoPlayerController.file(widget.file)
        ..initialize().then((_) {
          setState(() {}); // Refresh to show the video player
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isVideo ? "Video Preview" : "Photo Preview"),
      ),
      body: Center(
        child: widget.isVideo
            ? (_videoController != null && _videoController!.value.isInitialized
                ? Column(
                    children: [
                      AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _videoController!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                } else {
                                  _videoController!.play();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                : CircularProgressIndicator())
            : Image.file(widget.file), // Display the photo
      ),
    );
  }
}
