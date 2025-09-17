import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1E88E5);
  static const secondary = Color(0xFF0D47A1);
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F5F5);
  static const error = Color(0xFFB00020);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onBackground = Color(0xFF000000);
  static const onSurface = Color(0xFF000000);
  static const onError = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const titleLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  
  static const titleMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  
  static const bodyLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    color: Colors.black,
  );
  
  static const bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    color: Colors.black,
  );
  
  static const bodySmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    color: Colors.grey,
  );
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 40.0;
}