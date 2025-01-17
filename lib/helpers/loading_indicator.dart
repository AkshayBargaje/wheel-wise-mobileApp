import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wheelwise/utils/const.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _bgColorIndex = 0;
  int _messageIndex = 0;
  double _progress = 0.1;

  // Array of text messages
  final List<String> loadingMessages = [
    "Check form once before submitting it...",
    "Click stable & clear photos of vehicle...",
    "Try to complete your daily task on time.",
    "Wish you a good day, inspector! See you..."
  ];

  // Colors for background
  final List<Color> bgColors = [
    AppColors.primaryColor,
    AppColors.secondaryColor,
  ];

  @override
  void initState() {
    super.initState();

    // Animation controller for rotating the logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // 4 steps = 4 seconds
    )..repeat();

    // Timer to alternate background colors and update the text message
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _bgColorIndex = (_bgColorIndex + 1) % bgColors.length;
        _messageIndex = (_messageIndex + 1) % loadingMessages.length;
        _progress += 0.25; // Update progress
        if (_progress > 1.0) {
          _progress = 0.0; // Reset progress when it reaches full
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedContainer(
        height: size.height,
        width: size.width,
        duration: const Duration(seconds: 1),
        color: bgColors[_bgColorIndex],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.4), // Dynamic spacing for top alignment

            // Rotating Logo
            RotationTransition(
              turns: _controller,
              child: Image.asset(
                AppAssets.logoSvg,
                width: size.width * 0.45, // Logo width as 40% of screen width
                height: size.width * 0.45, // Logo height as 40% of screen width
              ),
            ),

            SizedBox(height: size.height * 0.1), // Dynamic spacing below the logo

            // Loading Message and Progress Bar
            Column(
              children: [
                Text(
                  loadingMessages[_messageIndex],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.045, // Dynamic font size (4.5% of width)
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.04), // Spacing below the message

                // Progress Bar
                Container(
                  width: size.width * 0.6, // Progress bar width as 60% of screen width
                  height: size.height * 0.01, // Progress bar height as 1.5% of screen height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size.height * 0.0075), // Dynamic border radius
                  ),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        width: (size.width * 0.6) * _progress, // Responsive width based on progress
                        height: size.height * 0.01,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(size.height * 0.0075),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
