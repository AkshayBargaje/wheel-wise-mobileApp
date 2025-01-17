import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wheelwise/components/form/SucessScreen.dart';
import 'package:wheelwise/splash_screen.dart';
import 'package:wheelwise/utils/const.dart';

Future<void> main()async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: AppFonts.nexaFont, // Apply Nexa font globally
        primaryColor: AppColors.primaryColor,
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.greyColor,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
        ),
      ),
      home: SplashScreen(),
    );
  }
}