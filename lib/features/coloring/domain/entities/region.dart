import 'dart:ui';

/// Описание одной области раскраски (региона), полученной из CV-разметки.
class Region {
  const Region({
    required this.id,
    required this.bounds,
    required this.labelNumber,
    this.numberAnchor,
    this.suggestedColor,
  });

  /// Идентификатор региона == значение в label-map.
  final int id;

  /// Ограничивающий прямоугольник в координатах картинки (пиксели).
  final Rect bounds;

  /// Номер, подписанный внутри области (для «раскраски по номерам»).
  final int labelNumber;

  /// Точка внутри области, где нарисован номер (координаты картинки).
  final Offset? numberAnchor;

  /// Рекомендованный цвет из легенды (если известен).
  final Color? suggestedColor;
}
