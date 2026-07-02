import 'dart:ui' as ui;

import '../../domain/entities/brush_stroke.dart';

/// Общая логика наложения мазка с клиппингом по маске региона.
///
/// Приём: мазок рисуется в отдельный слой (`saveLayer`), затем маска региона
/// накладывается через [ui.BlendMode.dstIn] — краска остаётся только внутри
/// области и не заходит на контур/цифры. Слой композитится вниз в режиме
/// [ui.BlendMode.srcOver] сплошным цветом: повторное рисование по уже
/// закрашенному месту не меняет тон (никакого «эффекта фломастера»).
abstract final class StrokeCompositor {
  /// Наносит [stroke] на [canvas] (в координатах картинки), ограничивая его
  /// alpha-маской [mask]. Рисование должно идти поверх белого/готового фона.
  /// [mask] == null → мазок не клиппится (режим «рисовать где угодно»).
  static void compose(
    ui.Canvas canvas,
    ui.Size imageSize,
    BrushStroke stroke,
    ui.Image? mask,
  ) {
    if (stroke.points.isEmpty) return;

    final bounds = ui.Offset.zero & imageSize;
    // Слой мазка; внутри слоя перекрытия сплющиваются, поэтому цвет ровный.
    canvas.saveLayer(bounds, ui.Paint());

    final paint = ui.Paint()
      ..color = stroke.color.withValues(alpha: stroke.opacity)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = stroke.size
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..isAntiAlias = true;

    if (stroke.points.length == 1) {
      // Одиночный тап — точка-кружок радиусом в половину толщины.
      canvas.drawCircle(
        stroke.points.first,
        stroke.size / 2,
        ui.Paint()
          ..color = paint.color
          ..isAntiAlias = true,
      );
    } else {
      final path = ui.Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // Клиппинг по маске региона (в режиме «где угодно» маски нет).
    if (mask != null) {
      canvas.drawImage(
        mask,
        ui.Offset.zero,
        ui.Paint()..blendMode = ui.BlendMode.dstIn,
      );
    }
    canvas.restore();
  }
}
