import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../splash_screen.dart';

class RequestPermissionWidget extends StatefulWidget {
  const RequestPermissionWidget({super.key});

  @override
  State<RequestPermissionWidget> createState() => _RequestPermissionWidgetState();
}

class _RequestPermissionWidgetState extends State<RequestPermissionWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions Required'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Permissions are required to use this app.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Open app settings for user to grant permissions
                await openAppSettings();
              },
              child: const Text('Open App Settings'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Retry permission check
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
