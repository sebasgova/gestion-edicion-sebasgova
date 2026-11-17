import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tipografía centralizada. `AppTheme` la inyecta en el `TextTheme`,
/// de modo que los widgets usan `Theme.of(context).textTheme`.
class AppTextStyles {
  AppTextStyles._();

  static const fontFamily = 'Roboto';
  static const fontFallback = ['SF Pro Display', 'Segoe UI', 'Helvetica Neue', 'Arial'];

  static const display = TextStyle(
      fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text, letterSpacing: -0.4);
  static const headline = TextStyle(
      fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.text, letterSpacing: -0.3);
  static const title = TextStyle(
      fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text);
  static const subtitle = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text);
  static const body = TextStyle(fontSize: 14, color: AppColors.text, height: 1.4);
  static const bodyDim = TextStyle(fontSize: 13, color: AppColors.textDim, height: 1.4);
  static const caption = TextStyle(fontSize: 12, color: AppColors.textFaint);
  static const label = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textDim,
      letterSpacing: 0.8);
  static const kpi = TextStyle(
      fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text, letterSpacing: -0.5);
  static const button = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  static TextTheme get textTheme => const TextTheme(
        displayLarge: display,
        displayMedium: display,
        displaySmall: display,
        headlineLarge: headline,
        headlineMedium: headline,
        headlineSmall: title,
        titleLarge: title,
        titleMedium: subtitle,
        titleSmall: subtitle,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: button,
        labelMedium: label,
        labelSmall: label,
      );
}
