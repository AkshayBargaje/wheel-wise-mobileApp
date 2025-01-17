import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wheelwise/components/auth/login.dart';
import 'package:wheelwise/components/main_app_screen.dart'; 
import 'package:wheelwise/components/screens/home_screen.dart';
import 'package:wheelwise/helpers/loading_indicator.dart'; 
import 'package:wheelwise/services/jwt_storage.dart';
import 'package:wheelwise/services/permissions.dart';

import 'helpers/request_permission.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Step 1: Check permissions
    bool permissionsGranted = await PermissionService.checkPermissions();

    if (!permissionsGranted) {
      // Show permission request widget if not granted
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RequestPermissionWidget()),
      );
      return;
    }

    // Step 2: Check if the user is logged in----
    bool isLoggedIn = await SecureStorageService.isSessionActive();

    if (isLoggedIn) {
      // Navigate to HomePage if logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainAppScreen()),
      );
    } else {
      // Navigate to LoginPage if not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: LoadingScreen(), // Display a loading indicator while checking
      ),
    );
  }
}
