import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Тема приложения: Material 3, светлая, шрифт Nunito Sans.
///
/// Шрифт подключается локальными ассетами (см. pubspec: family «Nunito Sans»
/// и моноширинный «JetBrains Mono» для кодов цветов/номеров).
abstract final class AppTheme {
  static const _fontFamily = 'NunitoSans';

  /// Моноширинный шрифт для hex-кодов и номеров областей.
  static const monoFontFamily = 'JetBrainsMono';

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.primaryContainer,
      onSecondaryContainer: AppColors.onPrimaryContainer,
      error: Color(0xFFBA6B6B),
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      surfaceContainerHighest: AppColors.surfaceContainerHigh,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainer: AppColors.surfaceContainer,
      outline: AppColors.outline,
      outlineVariant: AppColors.outline,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: _fontFamily,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          // labelLarge из дизайн-системы: 15 / 800; высота Filled — 56.
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.onSurface,
        displayColor: AppColors.onSurface,
      ),
    );
  }
}
