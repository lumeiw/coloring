import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../domain/entities/brush_stroke.dart';
import 'stroke_compositor.dart';

/// Преобразование «вписать картинку в бокс» (letterbox) и обратно.
class CanvasFit {
  const CanvasFit(this.scale, this.offset);

  final double scale;
  final Offset offset;

  static CanvasFit compute(Size imageSize, Size box) {
    final scale = math.min(
      box.width / imageSize.width,
      box.height / imageSize.height,
    );
    final dw = imageSize.width * scale;
    final dh = imageSize.height * scale;
    return CanvasFit(scale, Offset((box.width - dw) / 2, (box.height - dh) / 2));
  }

  /// Точка бокса → точка картинки.
  Offset toImage(Offset boxPoint) => (boxPoint - offset) / scale;
}

/// Рисует холст раскрашивания:
/// 1) запечённый слой (line-art + все зафиксированные мазки),
/// 2) подсветку активного региона под пальцем,
/// 3) текущий незавершённый мазок (перерисовывается каждый кадр).
class ColoringPainter extends CustomPainter {
  ColoringPainter({
    required this.baked,
    required this.imageSize,
    required this.live,
    required this.liveMask,
    required this.clipLive,
    required this.highlightMask,
    required this.highlightColor,
  }) : super(repaint: live);

  final ui.Image baked;
  final Size imageSize;

  /// Текущий мазок (обновляется во время движения пальца).
  final ValueListenable<BrushStroke?> live;
  final ui.Image? liveMask;

  /// В режиме клиппинга живой мазок рисуем только когда маска готова (иначе
  /// он бы вылез за контур). В режиме «где угодно» рисуем без маски.
  final bool clipLive;

  final ui.Image? highlightMask;
  final ui.Color highlightColor;

  static final _imagePaint = ui.Paint()
    ..filterQuality = ui.FilterQuality.medium
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final fit = CanvasFit.compute(imageSize, size);
    canvas.save();
    canvas.translate(fit.offset.dx, fit.offset.dy);
    canvas.scale(fit.scale);
    // Ограничиваем всё рисование границами картинки, чтобы подсветка (drawColor)
    // и мазки не заливали поля-леттербокс вокруг изображения.
    canvas.clipRect(Offset.zero & imageSize);

    // 1) Запечённый фон со всеми мазками.
    canvas.drawImage(baked, Offset.zero, _imagePaint);

    // 2) Подсветка активного региона (мягкая заливка выбранным цветом).
    final hMask = highlightMask;
    if (hMask != null) {
      final bounds = Offset.zero & imageSize;
      canvas.saveLayer(bounds, ui.Paint());
      canvas.drawColor(
        highlightColor.withValues(alpha: 0.22),
        ui.BlendMode.srcOver,
      );
      canvas.drawImage(
        hMask,
        Offset.zero,
        ui.Paint()..blendMode = ui.BlendMode.dstIn,
      );
      canvas.restore();
    }

    // 3) Текущий мазок поверх. В режиме клиппинга ждём готовность маски,
    // в режиме «где угодно» рисуем без неё.
    final stroke = live.value;
    if (stroke != null && (liveMask != null || !clipLive)) {
      StrokeCompositor.compose(canvas, imageSize, stroke, liveMask);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(ColoringPainter old) {
    return old.baked != baked ||
        old.liveMask != liveMask ||
        old.clipLive != clipLive ||
        old.highlightMask != highlightMask ||
        old.highlightColor != highlightColor ||
        old.imageSize != imageSize;
  }
}
