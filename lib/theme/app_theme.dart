import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colours ──────────────────────────────────────────────
  static const Color maroon      = Color(0xFF6B1A1A);
  static const Color gold        = Color(0xFFC4960A);
  static const Color cream       = Color(0xFFFAF0DC);
  static const Color lightGold   = Color(0xFFF5E0A0);
  static const Color darkBrown   = Color(0xFF3D2200);
  static const Color medBrown    = Color(0xFF8B5A00);
  static const Color paleGold    = Color(0xFFFDF6E3);
  static const Color goldBanner  = Color(0xFF8B6914);

  // ── Material Theme ─────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: cream,
        primaryColor: maroon,
        colorScheme: const ColorScheme.light(
          primary: maroon,
          secondary: gold,
          surface: cream,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: maroon,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: GoogleFonts.cinzel(
            color: lightGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          iconTheme: const IconThemeData(color: lightGold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: maroon,
            foregroundColor: lightGold,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cream,
          labelStyle: GoogleFonts.libreBaskerville(
            color: maroon,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: GoogleFonts.libreBaskerville(
            color: Colors.brown.shade300,
            fontSize: 13,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: gold, width: 1.5),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: maroon, width: 2),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(),
      );

  // ── Text Styles ────────────────────────────────────────────────
  static TextStyle get labelStyle => GoogleFonts.libreBaskerville(
        color: maroon,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyStyle => GoogleFonts.libreBaskerville(
        color: darkBrown,
        fontSize: 14,
      );

  static TextStyle get buttonStyle => GoogleFonts.cinzel(
        color: lightGold,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      );

  // ── Input Decoration helper ────────────────────────────────────
  static InputDecoration fieldDecoration({
    required String label,
    String? hint,
    Widget? suffix,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
        filled: true,
        fillColor: cream,
        labelStyle: labelStyle,
        hintStyle: GoogleFonts.libreBaskerville(
          color: Colors.brown.shade300,
          fontSize: 13,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: gold, width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: maroon, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      );
}
