import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_palette.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorPalette.background,
    colorScheme: const ColorScheme.dark(
      primary: ColorPalette.purple,
      secondary: ColorPalette.cyan,
      surface: ColorPalette.surface,
      error: ColorPalette.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: ColorPalette.textWhite,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: ColorPalette.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      iconTheme: IconThemeData(color: ColorPalette.textWhite),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: ColorPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ColorPalette.surface,
      contentTextStyle: const TextStyle(color: ColorPalette.textWhite),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorPalette.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorPalette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorPalette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorPalette.purple, width: 1.5),
      ),
      hintStyle: const TextStyle(color: ColorPalette.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: ColorPalette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        color: ColorPalette.textWhite,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: ColorPalette.textDim,
        fontSize: 14,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x0FFFFFFF),
      thickness: 1,
      space: 1,
    ),
  );
}
