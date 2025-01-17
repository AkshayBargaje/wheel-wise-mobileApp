import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class SecureStorageService {
  // Instance of FlutterSecureStorage
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Key for storing the JWT and login timestamp
  static const String _jwtKey = 'jwt_token';
  static const String _loginTimestampKey = 'login_timestamp';

  // Session timeout duration (e.g., 30 minutes)
  static const Duration _sessionTimeout = Duration(hours: 3);

  /// Save JWT to secure storage and login timestamp
  static Future<void> saveJwt(String jwt) async {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _secureStorage.write(key: _jwtKey, value: jwt);
    await _secureStorage.write(key: _loginTimestampKey, value: currentTimestamp);
  }

  /// Retrieve JWT from secure storage
  static Future<String?> getJwt() async {
    final jwt = await _secureStorage.read(key: _jwtKey);
    return jwt;
  }

  /// Check if the session is valid and navigate if not
  static Future<void> checkSessionAndNavigate(BuildContext context) async {
    final jwt = await getJwt();
    final timestampString = await _secureStorage.read(key: _loginTimestampKey);

    if (jwt == null || jwt.isEmpty || timestampString == null) {
      // No JWT or timestamp means the session is invalid, navigate to login
      _navigateToLogin(context);
      return;
    }

    final loginTimestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(timestampString));
    final sessionDuration = DateTime.now().difference(loginTimestamp);

    // Check if the session has expired
    if (sessionDuration > _sessionTimeout) {
      // Session expired, clear JWT and timestamp and navigate to login
      await clearSession();
      _navigateToLogin(context);
    }
  }


  static Future<bool> isSessionActive() async {
    final jwt = await getJwt();
    final timestampString = await _secureStorage.read(key: _loginTimestampKey);

    if (jwt == null || jwt.isEmpty || timestampString == null) {
      // No JWT or timestamp means the session is invalid, navigate to login
      return false;
    } 

  return true;
  }

  /// Delete JWT and timestamp to clear the session
  static Future<void> clearSession() async {
    await _secureStorage.delete(key: _jwtKey);
    await _secureStorage.delete(key: _loginTimestampKey);
  }

  /// Navigate to the login page
  static void _navigateToLogin(BuildContext context) {
    // Navigate to login screen (this assumes you have set up routes in your app)
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
  }
}
