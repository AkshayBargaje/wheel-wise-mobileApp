import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Check and request all required permissions
  static Future<bool> checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.camera,
      Permission.microphone,
    ].request();

    // Return true only if all permissions are granted
    return statuses.values.every((status) => status.isGranted);
  }

  static Future<bool> checkLocationPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
    ].request();

    // Return true only if all permissions are granted
    return statuses.values.every((status) => status.isGranted);
  }
  
}
