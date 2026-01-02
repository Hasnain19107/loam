import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        error: AppColors.destructive,
        onError: AppColors.destructiveForeground,
        surface: AppColors.background,
        onSurface: AppColors.foreground,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.lora().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lora(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
        displayMedium: GoogleFonts.lora(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
        displaySmall: GoogleFonts.lora(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
        headlineLarge: GoogleFonts.lora(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
        headlineMedium: GoogleFonts.lora(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
        headlineSmall: GoogleFonts.lora(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
        titleLarge: GoogleFonts.lora(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
        titleMedium: GoogleFonts.lora(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
        titleSmall: GoogleFonts.lora(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
        bodyLarge: GoogleFonts.lora(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.foreground,
        ),
        bodyMedium: GoogleFonts.lora(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.foreground,
        ),
        bodySmall: GoogleFonts.lora(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.mutedForeground,
        ),
        labelLarge: GoogleFonts.lora(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
        labelMedium: GoogleFonts.lora(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
        labelSmall: GoogleFonts.lora(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedForeground,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.popover,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withOpacity(0.08),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.popover,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.destructive, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.lora(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          side: BorderSide(color: AppColors.border, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.lora(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.lora(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.lora(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

