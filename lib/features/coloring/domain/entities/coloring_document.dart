import 'dart:typed_data';
import 'dart:ui';

import 'region.dart';

/// Готовый к раскрашиванию документ: улучшенный line-art (display-версия),
/// карта регионов (label-map) и список областей. Движок раскрашивания работает
/// только с ней и ничего не знает про происхождение данных.
class ColoringDocument {
  ColoringDocument({
    required this.lineArt,
    required this.width,
    required this.height,
    required this.labelMap,
    required this.regions,
    this.originalPng,
  }) : assert(
         labelMap.length == width * height,
         'label-map должен иметь размер width*height',
       );

  /// Фоновое изображение с контурами и номерами (то, что видит пользователь).
  final Image lineArt;

  /// Оригинал страницы (PNG без обработок, тот же размер) — для режима
  /// «показать оригинал». null у работ, импортированных до появления фичи.
  final Uint8List? originalPng;

  final int width;
  final int height;

  /// Карта регионов: для каждого пикселя — id региона (0 == фон/контур/цифры).
  final Int32List labelMap;

  final List<Region> regions;

  /// id региона под точкой в координатах картинки (или 0, если вне регионов).
  int regionIdAt(Offset imagePoint) {
    final x = imagePoint.dx.floor();
    final y = imagePoint.dy.floor();
    if (x < 0 || y < 0 || x >= width || y >= height) return 0;
    return labelMap[y * width + x];
  }

  Region? regionById(int id) {
    for (final r in regions) {
      if (r.id == id) return r;
    }
    return null;
  }
}
