import 'package:flutter/material.dart';

/// Цветовые токены дизайн-системы (Material 3 · светлая тема).
/// Значения взяты 1:1 из макета «Раскраска по номерам — UI-система».
abstract final class AppColors {
  // — Основные роли ColorScheme —
  static const primary = Color(0xFF6E8CAE);
  static const primaryContainer = Color(0xFFDDE8F3);
  static const onPrimaryContainer = Color(0xFF2B3E52);

  /// secondary используется как «успех/готово».
  static const secondary = Color(0xFF7FA98C);

  static const surface = Color(0xFFFBFBFD);
  static const surfaceContainer = Color(0xFFF1F4F8);
  static const surfaceContainerHigh = Color(0xFFE9EDF3);

  static const onSurface = Color(0xFF2C333D);
  static const onSurfaceVariant = Color(0xFF5C6672);
  static const outline = Color(0xFFD5DAE2);

  /// Приглушённый текст (подписи, плейсхолдеры).
  static const muted = Color(0xFF8A94A2);

  /// Фон «холста» под превью на экране раскрашивания.
  static const canvasBackground = Color(0xFFEFF1F5);

  /// Пастельная палитра раскраски (nuancier · 12 цветов).
  static const List<Color> palette = <Color>[
    Color(0xFFE8B4B8),
    Color(0xFFEBC79E),
    Color(0xFFE6D9A8),
    Color(0xFFB9CDA6),
    Color(0xFF9DB8A0),
    Color(0xFFA8C6C9),
    Color(0xFFA9BEDC),
    Color(0xFF8FA9C4),
    Color(0xFFC7B6D6),
    Color(0xFFD9AFC0),
    Color(0xFFC9B79C),
    Color(0xFFE0C3A0),
  ];
}
