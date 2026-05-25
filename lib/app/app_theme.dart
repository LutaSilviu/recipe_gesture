import 'package:flutter/material.dart';

import 'app_constants.dart';

/// Dark theme with warm cooking-friendly colours.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppConstants.darkBackground,
      primaryColor: AppConstants.primaryOrange,
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryOrange,
        secondary: AppConstants.accentGold,
        surface: AppConstants.cardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppConstants.textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppConstants.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppConstants.surfaceDark,
        contentTextStyle: TextStyle(color: AppConstants.textLight),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
