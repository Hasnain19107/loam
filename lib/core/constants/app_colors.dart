import 'package:flutter/material.dart';

/// Loam App Colors - Matching the React app's color scheme
class AppColors {
  // Primary Colors (Coral)
  static const Color primary = Color(0xFFF43F5E); // hsl(355, 100%, 61%)
  static const Color primaryForeground = Colors.white;

  // Background Colors (Cream)
  static const Color background =  Color(0xFFFFF3EC);
// hsl(20, 100%, 97%)
  static const Color foreground = Colors.black;

  // Card Colors
  static const Color card = Color(0xFFFDF7F2);
  static const Color cardForeground = Colors.black;

  // Popover Colors
  static const Color popover = Colors.white;
  static const Color popoverForeground = Colors.black;

  // Secondary Colors
  static const Color secondary = Color(0xFFF5E8E0); // hsl(20, 30%, 94%)
  static const Color secondaryForeground = Color(0xFF333333); // hsl(0, 0%, 20%)

  // Muted Colors
  static const Color muted = Color(0xFFE8E0D8); // hsl(20, 20%, 90%)
  static const Color mutedForeground = Color(0xFF737373); // hsl(0, 0%, 45%)

  // Accent Colors
  static const Color accent = Color(0xFFF43F5E);
  static const Color accentForeground = Colors.white;

  // Destructive Colors
  static const Color destructive = Color(0xFFE63946); // hsl(0, 84%, 60%)
  static const Color destructiveForeground = Colors.white;

  // Border Colors
  static const Color border = Color(0xFFE0D8D0); // hsl(20, 20%, 88%)
  static const Color input = Color(0xFFE0D8D0);

  // Custom Loam Colors
  static const Color loamCream = Color(0xFFFDF7F2);
  static const Color loamCoral = Color(0xFFF43F5E);
  static const Color loamCoralLight = Color(0xFFFEF2F4); // hsl(355, 100%, 95%)
  static const Color loamText = Colors.black;
  static const Color loamTextMuted = Color(0xFF808080); // hsl(0, 0%, 50%)

  // Shadow
  static BoxShadow get loamCardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      );

  static BoxShadow get loamCardShadowLarge => BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 30,
        offset: const Offset(0, 8),
      );
}

