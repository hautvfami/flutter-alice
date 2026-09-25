import 'package:flutter/material.dart';
import 'package:flutter_alice/theme/alice_colors.dart';
import 'package:flutter_alice/theme/alice_text_styles.dart';

/// Complete Material 3 ThemeData configuration for Alice HTTP Inspector.
final ThemeData aliceTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AliceColors.primary,
    primary: AliceColors.primary,
    surface: AliceColors.background,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AliceColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AliceColors.primary,
    elevation: 2,
    centerTitle: true,
    foregroundColor: AliceColors.textLight,
    iconTheme: IconThemeData(color: AliceColors.textLight),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AliceColors.textLight,
    ),
  ),
  tabBarTheme: const TabBarThemeData(
    indicatorColor: AliceColors.textLight,
    labelColor: AliceColors.textLight,
    unselectedLabelColor: AliceColors.textLightSecondary,
    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    unselectedLabelStyle: TextStyle(fontSize: 14),
  ),
  dividerTheme: const DividerThemeData(
    color: AliceColors.divider,
    thickness: 1,
    space: 1,
  ),
  cardTheme: CardThemeData(
    color: AliceColors.card,
    elevation: 1,
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: AliceColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    titleTextStyle: AliceTextStyles.titleLarge,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AliceColors.primary,
      foregroundColor: AliceColors.textLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
);
