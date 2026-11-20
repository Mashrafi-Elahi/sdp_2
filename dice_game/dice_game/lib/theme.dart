import 'package:flutter/material.dart';

// GitHub Dark Theme Colors
class GHColors {
  static const bg = Color(0xFF0D1117);       // Main background
  static const card = Color(0xFF161B22);     // Card / surface
  static const border = Color(0xFF30363D);   // Borders
  static const accent = Color(0xFF58A6FF);   // Blue links
  static const green = Color(0xFF238636);    // Primary button
  static const greenHover = Color(0xFF2EA043);
  static const greenBorder = Color(0xFF238636);
  static const danger = Color(0xFFDA3633);   // Red
  static const text = Color(0xFFC9D1D9);     // Primary text
  static const textMuted = Color(0xFF8B949E); // Secondary text
  static const textBright = Color(0xFFF0F6FC); // Headings
}

// Global GitHub Theme for the whole app
ThemeData githubTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: GHColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: GHColors.green,
      secondary: GHColors.accent,
      surface: GHColors.card,
      error: GHColors.danger,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: GHColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: GHColors.card,
      foregroundColor: GHColors.text,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: GHColors.textBright,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GHColors.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: GHColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: GHColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: GHColors.accent, width: 2),
      ),
      labelStyle: const TextStyle(color: GHColors.textMuted),
      floatingLabelStyle: const TextStyle(color: GHColors.accent),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: GHColors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: GHColors.greenBorder),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: GHColors.accent,
      ),
    ),
  );
}