import 'dart:typed_data';
import 'dart:ui';

import 'region.dart';

/// Готовый к раскрашиванию документ: улучшенный line-art (display-версия),
/// карта регионов (label-map) и список областей.
///
/// Это чистая доменная модель — она одинакова и для мок-источника (этап 2),
/// и для реального CV-пайплайна (этап 3). Движок раскрашивания работает
/// только с ней и ничего не знает про происхождение данных.
class ColoringDocument {
  ColoringDocument({
    required this.lineArt,
    required this.width,
    required this.height,
    required this.labelMap,
    required this.regions,
  }) : assert(
         labelMap.length == width * height,
         'label-map должен иметь размер width*height',
       );

  /// Фоновое изображение с контурами и номерами (то, что видит пользователь).
  final Image lineArt;

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
