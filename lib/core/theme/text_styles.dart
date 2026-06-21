import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_palette.dart';

class AppTextStyles {
  static TextStyle get appTitle => GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: ColorPalette.textWhite,
        letterSpacing: -0.5,
      );

  static TextStyle get screenTitle => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: ColorPalette.textWhite,
      );

  static TextStyle get cardHeader => GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: ColorPalette.textWhite,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: ColorPalette.textDim,
      );

  static TextStyle get bodyWhite => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: ColorPalette.textWhite,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: ColorPalette.textWhite,
      );

  static TextStyle get timer => GoogleFonts.poppins(
        fontSize: 64,
        fontWeight: FontWeight.w100,
        color: ColorPalette.textWhite,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get countdown => GoogleFonts.poppins(
        fontSize: 120,
        fontWeight: FontWeight.w800,
        color: ColorPalette.textWhite,
      );

  static TextStyle get timerPill => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ColorPalette.textWhite,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: ColorPalette.textMuted,
        letterSpacing: 0.8,
      );

  static TextStyle get smallBody => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: ColorPalette.textDim,
      );

  static TextStyle get smallMuted => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: ColorPalette.textMuted,
      );

  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ColorPalette.textWhite,
      );

  static TextStyle get tagline => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: ColorPalette.textDim,
      );
}
