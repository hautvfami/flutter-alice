import 'package:flutter/material.dart';

/// Semantic color palette for Alice HTTP Inspector.
class AliceColors {
  AliceColors._();

  // Primary brand colors
  static const Color primary = Color(0xff05c46b);
  static const Color primaryDark = Color(0xff048a4b);
  static const Color primaryLight = Color(0xffe8f8f0);

  // HTTP status & indicator colors
  static const Color success = Color(0xff05c46b);
  static const Color green = Color(0xff05c46b);
  static const Color error = Color(0xffff3f34);
  static const Color red = Color(0xffff3f34);
  static const Color lightRed = Color(0xffff5e57);
  static const Color warning = Color(0xffffa801);
  static const Color orange = Color(0xffffa801);
  static const Color info = Color(0xff0fbcf9);
  static const Color grey = Color(0xff808e9b);

  // Background & surface colors
  static const Color background = Color(0xfff8f9fa);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xff2d3436);
  static const Color card = Colors.white;
  static const Color divider = Color(0x14000000);
  static const Color darkConsoleBg = Colors.black;

  // Text colors
  static const Color textPrimary = Color(0xff1e272e);
  static const Color textSecondary = Color(0xff808e9b);
  static const Color textLight = Colors.white;
  static const Color textLightSecondary = Colors.white70;

  /// Returns subtle translucent background for status badges (like Chrome DevTools)
  static Color statusBadgeBg(Color color) => color.withAlpha(28);
}
