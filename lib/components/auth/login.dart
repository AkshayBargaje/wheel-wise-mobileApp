import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wheelwise/components/main_app_screen.dart';
import 'package:wheelwise/helpers/request_permission.dart';
import 'package:wheelwise/services/permissions.dart';
import 'package:wheelwise/utils/const.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../services/jwt_storage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  
  Future<void> _login(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Check for location permission
      
    bool permissionsGranted = await PermissionService.checkLocationPermissions();
      if(!permissionsGranted){
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RequestPermissionWidget()),
      );
      _isLoading = false;
      return;
      }

      //app has location access
      // Get current location
      Position position = await Geolocator.getCurrentPosition();

      // Send data to the server
      final response = await http.post(
        Uri.parse('http://${dotenv.env['HOST']}/api/auth/login'), // Replace with your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          }
        }),
      );

      if(response.statusCode==400){
              ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid Credentials."),
        ),
      );

      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jwt = data['token'];
        if (jwt != null) {
          await SecureStorageService.saveJwt(jwt);
          setState(() {
            _isLoading = false;
          });
           Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainAppScreen()),
    ); // Navigate to the home screen
        } else {
          throw Exception('Invalid response from server.');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed.');
      }
    } catch (e) {
      
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Stack(
                children: [
                  Image.asset("lib/assets/app-icon/login-bg.png"),
                  // // Light-icon-middle rotated 45 degrees at bottom left
                  Positioned(
                    bottom: -5,
                    right: -35,
                    child: Transform.rotate(
                      angle:
                          135 * (3.14159 / 180), // Convert degrees to radians
                      child: SvgPicture.asset(
                        AppAssets.midSvg,
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                  // Logo and Welcome Text
                  Container(
                    padding: EdgeInsets.fromLTRB(32, 0, 32, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 0,
                        ),
                        Image.asset(
                          AppAssets.wheelwiseLogo,
                          height: 40,
                          width: 200,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Have a great day!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Section
            Container(
              padding: EdgeInsets.fromLTRB(32, 24,32, 0),
              height: MediaQuery.of(context).size.height * 0.65,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email Input Field
                  Text(
                    "Email",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyColor),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      // labelText: 'apurv@wheelwise.co.in',
                      hintText: 'apurv@wheelwise.co.in',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppConfig.defaultBorderRadius),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Input Field with Toggle
                  Text(
                    "Password",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyColor),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: '******',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppConfig.defaultBorderRadius),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Add Forgot Password functionality
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:_isLoading
                  ? null
                  : () {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      if (email.isEmpty || password.isEmpty) {
                        setState(() {
                          _errorMessage = 'Please enter email and password.';
                        });
                        return;
                      }
                      _login(email, password);
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConfig.defaultBorderRadius),
                        ),
                      ),
                      child: _isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    ):const Text(
                        'Log In',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Need Help Text
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.greyColor, // Adjust color as needed
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                AppColors.greyColor, // Adjust color as needed
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.greyColor, // Adjust color as needed
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tech Support and Admin Support Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Tech Support Button
                      GestureDetector(
                        onTap: () {
                          // TODO: Add Tech Support functionality
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.greyColor),
                            borderRadius: BorderRadius.circular(
                                AppConfig.defaultBorderRadius),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "lib/assets/app-icon/fi_globe.svg",
                                color: AppColors.primaryColor,
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Tech Support',
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),

                      // Admin Support Button
                      GestureDetector(
                        onTap: () {
                          // TODO: Add Admin Support functionality
                        },
                        child: Container(
                           padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.greyColor),
                            borderRadius: BorderRadius.circular(
                                AppConfig.defaultBorderRadius),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SvgPicture.asset(
                                "lib/assets/app-icon/admin-support-icon.svg",
                                color: AppColors.primaryColor,
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Admin Support',
                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        // label: const Text('Admin Support',style: TextStyle(color: AppColors.greyColor),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
