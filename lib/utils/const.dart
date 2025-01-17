// colors
// #EC642C
// #EF8A32
// #595E5E

//font  -> nexa for the whole application

// use svg

import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFFEC642C); // Primary color
  static const Color secondaryColor = Color(0xFFEF8A32); // Secondary color
  static const Color greyColor = Color(0xFF595E5E); // Neutral grey
  static const Color black = Color(0xFF1D1D1D); // Neutral grey
}

class AppFonts {
  static const String nexaFont = 'Nexa'; // Use this font throughout the app
}

class AppAssets {
  static const String wheelwiseLogo =
      'lib/assets/app-icon/wheelwise-logo-white.png';
  static const String originalLogo = 'lib/assets/app-icon/original-logo.png';

  static const String logoSvg = 'lib/assets/app-icon/icon.png';
  static const String lightLogo = 'lib/assets/app-icon/light-icon.png';
  static const String midSvg = 'lib/assets/app-icon/icon-centre.svg';
  static const String lightMidSvg = 'lib/assets/app-icon/light-icon-centre.svg';
  static const String lightTopSvg = 'lib/assets/app-icon/light-icon-top.svg';
  static const String lightBottomSvg =
      'lib/assets/app-icon/light-icon-bottom.svg';
  static const String lightCircleSvg =
      'lib/assets/app-icon/light-icon-circle.svg';

  //home screen
  static const String total_inspection =
      'lib/assets/app-icon/total_inspection.svg';
  static const String inspection_inProgress =
      'lib/assets/app-icon/inspection_inProgress.svg';
  static const String declined_inspection =
      'lib/assets/app-icon/declined_inspection.svg';
  static const String completed_inspection =
      'lib/assets/app-icon/completed_inspection.svg';
  static const String search_icon = 'lib/assets/app-icon/search-icon.svg';
  static const String search_icon2 = 'lib/assets/app-icon/search-icon2.svg';
  static const String arrow = 'lib/assets/app-icon/arrow.svg';
}

class AppConfig {
  // App-wide configurations
  static const String appName = 'Wheelwise';
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
}

class FormsConfig {
  var forms = {
    "B2C": {
      "Accident & Body check": "lib/data/Accident_body _checkUp.json",
      "Engine & Transmission+Scanning": "lib/data/engine_and_transmission.json",
      "Interior & Electrical": "lib/data/Interior_and _electrical.json",
      "Steering suspension&Tyres brake":
          "lib/data/Steering_and _suspensionTyres.json",
      "85 points EV": "lib/data/85points.json",
      "128 points": "lib/data/128points.json"
    },
    "B2B": {
      "85 points EV":"lib/data/85points.json",
      "15 points": "lib/data/15points.json",
      "54 points": "lib/data/54points.json",
      "128 points": "lib/data/128points.json"
    }
  };
}
