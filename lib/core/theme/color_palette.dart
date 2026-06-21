import 'package:flutter/material.dart';

class ColorPalette {
  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF13131F);
  static const Color border = Color(0x17FFFFFF);

  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);
  static const Color cyan = Color(0xFF06B6D4);

  static const LinearGradient gradientA = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientB = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFF06B6D4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientC = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF1A0A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color textWhite = Color(0xFFF1F5F9);
  static const Color textDim = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF334155);

  static const Color error = Color(0xFFF43F5E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
}
