import 'dart:ui';

/// Один мазок кистью, привязанный к региону. Хранится в логе для undo/redo
/// и последующего сохранения прогресса (этап 3).
class BrushStroke {
  const BrushStroke({
    required this.regionId,
    required this.color,
    required this.size,
    required this.opacity,
    required this.points,
  });

  /// Регион, по маске которого клиппится мазок (краска не выходит за контур).
  final int regionId;

  final Color color;

  /// Толщина кисти в пикселях картинки.
  final double size;

  /// Непрозрачность мазка (0..1) — «маркерность».
  final double opacity;

  /// Точки мазка в координатах картинки.
  final List<Offset> points;

  BrushStroke copyWith({List<Offset>? points}) => BrushStroke(
    regionId: regionId,
    color: color,
    size: size,
    opacity: opacity,
    points: points ?? this.points,
  );
}
