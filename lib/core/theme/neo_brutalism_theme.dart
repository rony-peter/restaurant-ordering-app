import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeoBrutalism {
  // Core Color Palette
  static const Color primary = Color(0xFFFF5722); // Punchy Orange
  static const Color secondary = Color(0xFFFFC107); // Bright Gold/Yellow
  static const Color background = Color(0xFFFAF8F5); // Off-white cream
  static const Color surface = Colors.white;
  static const Color border = Colors.black;
  static const Color success = Color(0xFF00E676); // Mint Green
  static const Color alert = Color(0xFFFF3D00); // Sharp Red

  // Border & Shadow Specs
  static const double borderWidth = 2.5;
  static const double borderRadius = 8.0; // Slightly rounded geometric corners

  static List<BoxShadow> shadow([Offset offset = const Offset(4, 4)]) => [
    BoxShadow(
      color: Colors.black,
      offset: offset,
      blurRadius: 0, // Hard shadow, no blur!
    ),
  ];

  // Global Flutter ThemeData
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        outline: border, // <-- Fixed: replaced 'border' with 'outline'
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}
