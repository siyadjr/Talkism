import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0F111A);
  static const Color surface = Color(0xFF1B1E2E);
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF818CF8);
  static const Color accent = Color(0xFFF43F5E); // Rose
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F111A),
      Color(0xFF090909),
    ],
  );
}
