import 'dart:typed_data';

import 'region.dart';

/// Результат CV-разметки страницы: то, что кешируется в drift и из чего
/// собирается ColoringDocument.
class CvResult {
  const CvResult({
    required this.enhancedPng,
    required this.width,
    required this.height,
    required this.labelMap,
    required this.regions,
  });

  /// Улучшенный line-art (display-версия) в PNG — фон холста.
  final Uint8List enhancedPng;

  final int width;
  final int height;

  /// Карта регионов: id региона на каждый пиксель (0 == фон/контур).
  final Int32List labelMap;

  final List<Region> regions;
}
