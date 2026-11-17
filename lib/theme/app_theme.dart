import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// ThemeData oscuro de Sebasgova Edición.
class AppTheme {
  AppTheme._();

  static const radius = 12.0;
  static const radiusLg = 14.0;

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.blue,
      onPrimary: AppColors.bg,
      secondary: AppColors.gold,
      onSecondary: AppColors.bg,
      surface: AppColors.panel,
      onSurface: AppColors.text,
      error: AppColors.red,
      surfaceTint: Colors.transparent,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.line),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
      fontFamilyFallback: AppTextStyles.fontFallback,
      textTheme: AppTextStyles.textTheme,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.raised,
      dividerColor: AppColors.line,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.title,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panel2,
        labelStyle: AppTextStyles.bodyDim,
        hintStyle: AppTextStyles.caption,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.bg,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.lineStrong),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textDim,
          textStyle: AppTextStyles.button,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.panel2,
        side: const BorderSide(color: AppColors.line),
        labelStyle: AppTextStyles.bodyDim,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.panel3,
        contentTextStyle: AppTextStyles.body,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.panel2,
        textStyle: AppTextStyles.body,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.lineStrong, width: 1.5),
      ),
    );
  }
}
