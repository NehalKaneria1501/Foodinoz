import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography according to Stitch Design Tokens:
/// Headlines, Labels & Pouch identifiers use Space Grotesk (technical, brutalist).
/// Body text, ingredients & instructions use Hanken Grotesk (clean readability).
class AppTypography {
  AppTypography._();

  // Space Grotesk - Headlines & Badges (Clean, modern culinary display)
  static TextStyle displayXl = GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
  );

  static TextStyle displayLg = GoogleFonts.spaceGrotesk(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.015,
  );

  static TextStyle headlineLg = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
  );

  static TextStyle headlineMd = GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headlineSm = GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  /// Legible from 3 feet away on the kitchen counter!
  static TextStyle labelPouch = GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.05,
    color: Colors.white,
  );

  static TextStyle labelButton = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.08,
  );

  static TextStyle labelMd = GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.04,
  );

  // Hanken Grotesk - Body & UI content (Appetizing, highly readable)
  static TextStyle bodyLg = GoogleFonts.hankenGrotesk(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodyMd = GoogleFonts.hankenGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle bodySm = GoogleFonts.hankenGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static TextStyle metadata = GoogleFonts.hankenGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.04,
  );

  static TextStyle numericData = GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}
