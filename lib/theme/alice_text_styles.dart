import 'package:flutter/material.dart';
import 'package:flutter_alice/theme/alice_colors.dart';

/// Typography definitions for Alice HTTP Inspector.
class AliceTextStyles {
  AliceTextStyles._();

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
