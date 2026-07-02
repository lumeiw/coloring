import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:coloring/features/coloring/domain/entities/brush_stroke.dart';
import 'package:coloring/features/coloring/presentation/engine/coloring_painter.dart';
import 'package:coloring/features/coloring/presentation/engine/region_mask_cache.dart';
import 'package:coloring/features/coloring/presentation/engine/stroke_compositor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ui.Image> _blankImage(int w, int h) {
  final c = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    Uint8List(w * h * 4),
    w,
    h,
    ui.PixelFormat.rgba8888,
    c.complete,
  );
  return c.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CanvasFit: letterbox и обратное преобразование координат', () {
    // Картинка 100×200 в бокс 100×100 → масштаб 0.5, вертикальные поля.
    final fit = CanvasFit.compute(const Size(100, 200), const Size(100, 100));
    expect(fit.scale, 0.5);
    // Центр бокса → центр картинки.
    final imgPoint = fit.toImage(const Offset(50, 50));
    expect(imgPoint.dx, closeTo(50, 0.001));
    expect(imgPoint.dy, closeTo(100, 0.001));
  });

  test('RegionMaskCache строит маску из label-map', () async {
    final labelMap = Int32List.fromList([1, 1, 0, 2]); // 2×2
    final cache = RegionMaskCache(labelMap: labelMap, width: 2, height: 2);
    addTearDown(cache.dispose);

    final mask = await cache.maskFor(1);
    final bytes = (await mask.toByteData())!;
    // Пиксели региона 1 — непрозрачны, остальные — прозрачны.
    expect(bytes.getUint8(3), 255); // (0,0) alpha
    expect(bytes.getUint8(7), 255); // (1,0) alpha
    expect(bytes.getUint8(11), 0); // (0,1) alpha
    expect(bytes.getUint8(15), 0); // (1,1) alpha
    // Повторный запрос отдаёт закешированный объект.
    expect(cache.peek(1), same(mask));
  });

  test('StrokeCompositor.compose не бросает и рисует в маску', () async {
    final mask = await _blankImage(50, 50);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawColor(const Color(0xFFFFFFFF), ui.BlendMode.src);

    StrokeCompositor.compose(
      canvas,
      const Size(50, 50),
      const BrushStroke(
        regionId: 1,
        color: Color(0xFFB9CDA6),
        size: 12,
        opacity: 0.8,
        points: [Offset(10, 10), Offset(40, 40)],
      ),
      mask,
    );
    final image = await recorder.endRecording().toImage(50, 50);
    expect(image.width, 50);
    image.dispose();
  });

  test('ColoringPainter.paint выполняет весь конвейер без исключений', () async {
    final baked = await _blankImage(60, 80);
    final mask = await _blankImage(60, 80);
    final live = ValueNotifier<BrushStroke?>(
      const BrushStroke(
        regionId: 1,
        color: Color(0xFFA9BEDC),
        size: 10,
        opacity: 1,
        points: [Offset(5, 5), Offset(20, 30)],
      ),
    );
    addTearDown(live.dispose);

    final painter = ColoringPainter(
      baked: baked,
      imageSize: const Size(60, 80),
      live: live,
      liveMask: mask,
      clipLive: true,
      highlightMask: mask,
      highlightColor: const Color(0xFFA9BEDC),
    );

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    painter.paint(canvas, const Size(240, 320));
    final image = await recorder.endRecording().toImage(240, 320);
    expect(image.width, 240);
    image.dispose();
  });
}
