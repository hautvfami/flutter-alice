import 'package:flutter/material.dart';
import 'package:flutter_alice/theme/alice_colors.dart';

/// Typography definitions for Alice HTTP Inspector.
class AliceStyles {
  AliceStyles._();

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AliceColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AliceColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AliceColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AliceColors.textPrimary,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AliceColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AliceColors.textSecondary,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AliceColors.textPrimary,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    color: AliceColors.textPrimary,
  );

  static const TextStyle monoBold = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AliceColors.textPrimary,
  );
}

extension FontSizeExt on TextStyle {
  TextStyle get s11 => copyWith(fontSize: 11);
  TextStyle get s12 => copyWith(fontSize: 12);
  TextStyle get s14 => copyWith(fontSize: 14);
  TextStyle get s16 => copyWith(fontSize: 16);
  TextStyle get s18 => copyWith(fontSize: 18);
  TextStyle get s20 => copyWith(fontSize: 20);
  TextStyle get s22 => copyWith(fontSize: 22);
  TextStyle get s24 => copyWith(fontSize: 24);
  TextStyle get s26 => copyWith(fontSize: 26);
  TextStyle get s28 => copyWith(fontSize: 28);
  TextStyle get s30 => copyWith(fontSize: 30);
  TextStyle get s32 => copyWith(fontSize: 32);
  TextStyle get s34 => copyWith(fontSize: 34);
  TextStyle get s36 => copyWith(fontSize: 36);
  TextStyle get s38 => copyWith(fontSize: 38);
  TextStyle get s40 => copyWith(fontSize: 40);
  TextStyle get s42 => copyWith(fontSize: 42);
  TextStyle get s44 => copyWith(fontSize: 44);
  TextStyle get s46 => copyWith(fontSize: 46);
  TextStyle get s48 => copyWith(fontSize: 48);
  TextStyle get s50 => copyWith(fontSize: 50);
}

extension FontWeightExt on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get w600 => copyWith(fontWeight: FontWeight.w600);
  TextStyle get w500 => copyWith(fontWeight: FontWeight.w500);
  TextStyle get w400 => copyWith(fontWeight: FontWeight.w400);
  TextStyle get w300 => copyWith(fontWeight: FontWeight.w300);
  TextStyle get w200 => copyWith(fontWeight: FontWeight.w200);
  TextStyle get w100 => copyWith(fontWeight: FontWeight.w100);
}

extension FontColorExt on TextStyle {
  TextStyle get primary => copyWith(color: AliceColors.primary);
  TextStyle get secondary => copyWith(color: AliceColors.primaryDark);
  TextStyle get success => copyWith(color: AliceColors.success);
  TextStyle get warning => copyWith(color: AliceColors.warning);
  TextStyle get error => copyWith(color: AliceColors.error);
  TextStyle get primaryDark => copyWith(color: AliceColors.primaryDark);
  TextStyle get textPrimary => copyWith(color: AliceColors.textPrimary);
  TextStyle get textSecondary => copyWith(color: AliceColors.textSecondary);
  TextStyle get grey => copyWith(color: AliceColors.grey);
  TextStyle get white => copyWith(color: Colors.white);
}
