import 'dart:typed_data';

import 'region.dart';

/// Результат CV-разметки страницы: то, что кешируется в drift и из чего
/// собирается ColoringDocument.
class CvResult {
  const CvResult({
    required this.enhancedPng,
    required this.originalPng,
    required this.width,
    required this.height,
    required this.labelMap,
    required this.regions,
  });

  /// Улучшенный line-art (display-версия) в PNG — фон холста.
  final Uint8List enhancedPng;

  /// Оригинал страницы (без обработок, тот же размер, что display) в PNG —
  /// для режима «показать оригинал».
  final Uint8List originalPng;

  final int width;
  final int height;

  /// Карта регионов: id региона на каждый пиксель (0 == фон/контур).
  final Int32List labelMap;

  final List<Region> regions;
}
