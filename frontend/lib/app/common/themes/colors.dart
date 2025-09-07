import 'package:flutter/material.dart';

class AppColors {
  // Modern gradient colors
  static const Color primary = Color(0xFF667eea); // Modern blue-purple
  static const Color primaryLight = Color(0xFF764ba2); // Purple accent
  static const Color secondary = Color(0xFFf093fb); // Pink gradient
  static const Color secondaryLight = Color(0xFFf5576c); // Coral pink
  
  // Accent colors
  static const Color accent = Color(0xFF4facfe); // Bright blue
  static const Color accentLight = Color(0xFF00f2fe); // Cyan
  
  // Background colors
  static const Color background = Color(0xFFf8fafc); // Light gray background
  static const Color backgroundDark = Color(0xFF1a202c); // Dark background
  static const Color surface = Color(0xFFFFFFFF); // White surface
  static const Color surfaceLight = Color(0xFFf7fafc); // Very light gray
  
  // Text colors
  static const Color text = Color(0xFF2d3748); // Dark gray text
  static const Color textLight = Color(0xFF718096); // Medium gray text
  static const Color textWhite = Color(0xFFFFFFFF); // White text
  
  // Status colors
  static const Color success = Color(0xFF48bb78); // Green
  static const Color warning = Color(0xFFed8936); // Orange
  static const Color error = Color(0xFFf56565); // Red
  static const Color info = Color(0xFF4299e1); // Blue
  
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, surfaceLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, surfaceLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
