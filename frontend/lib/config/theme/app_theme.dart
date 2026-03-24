import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: AppTextStyles.fontFamily,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.light( 
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    ),

    textTheme: const TextTheme(
      headlineLarge: AppTextStyles.title,
      titleMedium: AppTextStyles.subtitle,
      bodyMedium: AppTextStyles.body,
    ),

      elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary, 
        foregroundColor: AppColors.textLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
  );
}