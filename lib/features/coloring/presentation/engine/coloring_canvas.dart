import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/brush_stroke.dart';
import '../../domain/entities/coloring_document.dart';
import '../cubit/coloring_cubit.dart';
import '../cubit/coloring_state.dart';
import 'coloring_painter.dart';
import 'region_mask_cache.dart';
import 'stroke_compositor.dart';

/// Интерактивный холст раскрашивания: рисование кистью с клиппингом по маске
/// региона (инструмент «Кисть») и свободная трансформация холста — сдвиг, зум
/// и поворот двумя пальцами (инструмент «Рука»). Тяжёлые ui.Image-буферы и
/// маски живут здесь; логическое состояние — в [ColoringCubit].
class ColoringCanvas extends StatefulWidget {
  const ColoringCanvas({super.key, required this.document, this.resetSignal});

  final ColoringDocument document;

  /// Сигнал «вписать в экран»: при изменении сбрасывает трансформацию.
  final Listenable? resetSignal;

  @override
  State<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<ColoringCanvas> {
  late final RegionMaskCache _maskCache;
  late final ui.Size _imageSize;

  /// Запечённый слой: line-art + все зафиксированные мазки.
  ui.Image? _baked;
  int _bakedCount = 0;

  /// Текущий незавершённый мазок (драйвит перерисовку без setState).
  final ValueNotifier<BrushStroke?> _live = ValueNotifier(null);

  /// Трансформация холста (сдвиг/зум/поворот) для инструмента «Рука».
  Matrix4 _matrix = Matrix4.identity();
  final ValueNotifier<double> _zoom = ValueNotifier(1);

  // Инкрементальные данные жеста трансформации.
  Offset _lastFocal = Offset.zero;
  double _lastScale = 1;
  double _lastRotation = 0;

  final List<ui.Offset> _points = [];
  int _currentRegion = 0;
  ui.Image? _liveMask;

  CanvasFit _fit = const CanvasFit(1, Offset.zero);

  /// Один раз запекаем сохранённый прогресс при открытии.
  bool _didInitialBake = false;

  /// Оригинал страницы (без обработок) — декодируется лениво при первом
  /// включении режима «показать оригинал».
  ui.Image? _original;
  bool _decodingOriginal = false;

  /// Троттлинг превью: PNG-снапшот дорогой, поэтому кодируем не каждый мазок,
  /// а последнее состояние холста после паузы в рисовании.
  Timer? _thumbTimer;

  static const double _minScale = 1;
  static const double _maxScale = 12;

  @override
  void initState() {
    super.initState();
    final doc = widget.document;
    _imageSize = ui.Size(doc.width.toDouble(), doc.height.toDouble());
    _baked = doc.lineArt;
    // Ленивый кеш с небольшим LRU: маски строятся по мере рисования и не
    // держатся все сразу — иначе на сложных раскрасках (сотни областей)
    // память улетает за лимит устройства.
    _maskCache = RegionMaskCache(
      labelMap: doc.labelMap,
      width: doc.width,
      height: doc.height,
      capacity: 6,
    );
    widget.resetSignal?.addListener(_resetView);
  }

  void _resetView() {
    setState(() => _matrix = Matrix4.identity());
    _zoom.value = 1;
  }

  /// id «региона» для режима «рисовать где угодно» (маска не нужна).
  static const int _freeRegion = -1;

  /// Маска для запекания мазка: null для свободного мазка (regionId <= 0).
  Future<ui.Image?> _maskForStroke(BrushStroke stroke) async {
    if (stroke.regionId <= 0) return null;
    return _maskCache.peek(stroke.regionId) ??
        await _maskCache.maskFor(stroke.regionId);
  }

  /// Ленивая декодировка оригинала (PNG из документа) для режима просмотра.
  Future<void> _ensureOriginal() async {
    if (_original != null || _decodingOriginal) return;
    final png = widget.document.originalPng;
    if (png == null) return;
    _decodingOriginal = true;
    final codec = await ui.instantiateImageCodec(png);
    final frame = await codec.getNextFrame();
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() => _original = frame.image);
  }

  @override
  void dispose() {
    widget.resetSignal?.removeListener(_resetView);
    _thumbTimer?.cancel();
    final baked = _baked;
    if (baked != null && baked != widget.document.lineArt) baked.dispose();
    _original?.dispose();
    _maskCache.dispose();
    _live.dispose();
    _zoom.dispose();
    super.dispose();
  }

  ColoringCubit get _cubit => context.read<ColoringCubit>();

  // ————— Реакция на изменения лога мазков —————
  void _onStrokes(List<BrushStroke> strokes) {
    if (strokes.length == _bakedCount) return;
    if (strokes.length == _bakedCount + 1) {
      _bakeAppend(strokes.last);
    } else {
      _rebakeAll(strokes);
    }
  }

  Future<void> _bakeAppend(BrushStroke stroke) async {
    final base = _baked ?? widget.document.lineArt;
    final mask = await _maskForStroke(stroke);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImage(base, ui.Offset.zero, ui.Paint());
    StrokeCompositor.compose(canvas, _imageSize, stroke, mask);
    final image = await recorder
        .endRecording()
        .toImage(widget.document.width, widget.document.height);

    if (!mounted) {
      image.dispose();
      return;
    }
    final old = _baked;
    setState(() {
      _baked = image;
      _bakedCount += 1;
    });
    if (old != null && old != widget.document.lineArt) old.dispose();
    _scheduleThumbnail();
  }

  Future<void> _rebakeAll(List<BrushStroke> strokes) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImage(widget.document.lineArt, ui.Offset.zero, ui.Paint());
    for (final s in strokes) {
      StrokeCompositor.compose(canvas, _imageSize, s, await _maskForStroke(s));
    }
    final image = await recorder
        .endRecording()
        .toImage(widget.document.width, widget.document.height);

    if (!mounted) {
      image.dispose();
      return;
    }
    final old = _baked;
    setState(() {
      _baked = image;
      _bakedCount = strokes.length;
    });
    if (old != null && old != widget.document.lineArt) old.dispose();
    _scheduleThumbnail();
  }

  /// Планирует сохранение превью после паузы (троттлинг): при частых мазках
  /// кодируется только последнее состояние холста, а не каждый штрих.
  void _scheduleThumbnail() {
    if (_thumbTimer?.isActive ?? false) return;
    _thumbTimer = Timer(const Duration(milliseconds: 1200), () {
      final img = _baked;
      if (img != null && mounted) _saveThumbnail(img);
    });
  }

  /// Кодирует уменьшенный снапшот холста в PNG и отдаёт его в cubit как превью.
  Future<void> _saveThumbnail(ui.Image full) async {
    // Достаточно крупно, чтобы карточка галереи на Retina не мылилась,
    // но без апскейла маленьких картинок.
    final tw = full.width < 720 ? full.width.toDouble() : 720.0;
    final scale = tw / full.width;
    final th = (full.height * scale).round();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      full,
      Rect.fromLTWH(0, 0, full.width.toDouble(), full.height.toDouble()),
      Rect.fromLTWH(0, 0, tw, th.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
    final scaled = await recorder.endRecording().toImage(tw.round(), th);
    final data = await scaled.toByteData(format: ui.ImageByteFormat.png);
    scaled.dispose();
    if (data != null && mounted) {
      context.read<ColoringCubit>().saveThumbnail(data.buffer.asUint8List());
    }
  }

  // ————— Рисование (инструмент «Кисть») —————
  void _onPointerDown(PointerDownEvent e) {
    final state = _cubit.state;
    final imgPoint = _fit.toImage(e.localPosition);

    // Пипетка работает и в режиме «оригинал» — берёт цвет с исходника.
    if (state.tool == ColoringTool.eyedropper) {
      _pickColorAt(imgPoint);
      return;
    }
    // В режиме «оригинал» рисование выключено (доступны «рука» и пипетка).
    if (state.showOriginal) return;
    if (state.tool != ColoringTool.brush) return;

    if (!state.clipToRegion) {
      // Режим «где угодно»: рисуем без привязки к региону и без маски.
      _currentRegion = _freeRegion;
      _liveMask = null;
      _points
        ..clear()
        ..add(imgPoint);
      _live.value = _buildStroke();
      return;
    }

    final region = widget.document.regionIdAt(imgPoint);
    if (region == 0) {
      _currentRegion = 0;
      return;
    }
    _currentRegion = region;
    _liveMask = _maskCache.peek(region);
    _ensureLiveMask(region); // достроить маску, если её ещё нет
    _points
      ..clear()
      ..add(imgPoint);
    _cubit.setActiveRegion(region);
    _live.value = _buildStroke();
  }

  /// Ленивая догрузка маски региона для показа живого мазка (клип-режим).
  Future<void> _ensureLiveMask(int region) async {
    if (_liveMask != null) return;
    final mask = await _maskCache.maskFor(region);
    if (mounted && _currentRegion == region) {
      setState(() => _liveMask = mask);
    }
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_currentRegion == 0) return;
    _points.add(_fit.toImage(e.localPosition));
    _live.value = _buildStroke();
  }

  void _onPointerUp(PointerUpEvent e) {
    if (_currentRegion == 0) return;
    final stroke = _buildStroke();
    _live.value = null;
    _currentRegion = 0;
    _liveMask = null;
    _cubit.setActiveRegion(0);
    if (stroke != null) _cubit.commitStroke(stroke);
  }

  BrushStroke? _buildStroke() {
    if (_currentRegion == 0 || _points.isEmpty) return null;
    final s = _cubit.state;
    return BrushStroke(
      regionId: _currentRegion,
      color: s.color,
      size: s.brushSize,
      opacity: s.opacity,
      points: List.of(_points),
    );
  }

  Future<void> _pickColorAt(ui.Offset imgPoint) async {
    // В режиме «оригинал» цвет берём с исходной картинки (если она уже
    // декодирована), иначе — с запечённого слоя раскраски.
    final original = _cubit.state.showOriginal ? _original : null;
    final src = original ?? _baked ?? widget.document.lineArt;
    final data = await src.toByteData();
    if (data == null) return;
    final x = imgPoint.dx.floor().clamp(0, src.width - 1);
    final y = imgPoint.dy.floor().clamp(0, src.height - 1);
    final o = (y * src.width + x) * 4;
    final color = ui.Color.fromARGB(
      255,
      data.getUint8(o),
      data.getUint8(o + 1),
      data.getUint8(o + 2),
    );
    _cubit
      ..selectColor(color)
      ..selectTool(ColoringTool.brush);
  }

  // ————— Трансформация (инструмент «Рука»): сдвиг + зум + поворот —————
  void _onScaleStart(ScaleStartDetails d) {
    _lastFocal = d.localFocalPoint;
    _lastScale = 1;
    _lastRotation = 0;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final focal = d.localFocalPoint;
    final translationDelta = focal - _lastFocal;
    final rotationDelta = d.rotation - _lastRotation;
    var scaleDelta = _lastScale == 0 ? 1.0 : d.scale / _lastScale;

    // Ограничиваем итоговый зум диапазоном [_minScale, _maxScale].
    final current = _matrix.getMaxScaleOnAxis();
    final target = current * scaleDelta;
    if (target < _minScale) scaleDelta = _minScale / current;
    if (target > _maxScale) scaleDelta = _maxScale / current;

    _lastFocal = focal;
    _lastScale = d.scale;
    _lastRotation = d.rotation;

    // Инкремент вокруг фокуса жеста (в координатах бокса) + сдвиг.
    final delta = Matrix4.identity()
      ..translateByDouble(focal.dx, focal.dy, 0, 1)
      ..rotateZ(rotationDelta)
      ..scaleByDouble(scaleDelta, scaleDelta, 1, 1)
      ..translateByDouble(-focal.dx, -focal.dy, 0, 1);
    final pan = Matrix4.identity()
      ..translateByDouble(translationDelta.dx, translationDelta.dy, 0, 1);

    setState(() => _matrix = pan * delta * _matrix);
    _zoom.value = _matrix.getMaxScaleOnAxis();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ColoringCubit, ColoringState>(
      listenWhen: (a, b) => a.strokes != b.strokes,
      listener: (_, state) => _onStrokes(state.strokes),
      buildWhen: (a, b) =>
          a.tool != b.tool ||
          a.color != b.color ||
          a.brushSize != b.brushSize ||
          a.opacity != b.opacity ||
          a.activeRegionId != b.activeRegionId ||
          a.clipToRegion != b.clipToRegion ||
          a.showOriginal != b.showOriginal,
      builder: (context, state) {
        // Первое включение «оригинала» — декодируем PNG в фоне.
        if (state.showOriginal && _original == null) _ensureOriginal();
        // Запекаем восстановленный из drift прогресс один раз при открытии.
        if (!_didInitialBake) {
          _didInitialBake = true;
          if (state.strokes.isNotEmpty) {
            final initial = state.strokes;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _onStrokes(initial);
            });
          }
        }

        final highlightMask = state.activeRegionId == 0
            ? null
            : _maskCache.peek(state.activeRegionId);

        return LayoutBuilder(
          builder: (context, constraints) {
            _fit = CanvasFit.compute(_imageSize, constraints.biggest);

            final content = Transform(
              transform: _matrix,
              child: SizedBox.expand(
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _onPointerDown,
                  onPointerMove: _onPointerMove,
                  onPointerUp: _onPointerUp,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: ColoringPainter(
                      baked: _baked ?? widget.document.lineArt,
                      imageSize: _imageSize,
                      live: _live,
                      liveMask: _liveMask,
                      clipLive: state.clipToRegion,
                      highlightMask: highlightMask,
                      highlightColor: state.color,
                      // Пока PNG декодируется, показываем раскраску.
                      original: state.showOriginal ? _original : null,
                    ),
                  ),
                ),
              ),
            );

            return Stack(
              children: [
                Positioned.fill(
                  // ClipRect не даёт трансформированному («рукой») холсту
                  // наезжать на верхнюю/нижнюю панели.
                  child: ClipRect(
                    // В режиме «оригинал» жесты трансформации доступны всегда.
                    child:
                        state.tool == ColoringTool.hand || state.showOriginal
                        ? GestureDetector(
                            onScaleStart: _onScaleStart,
                            onScaleUpdate: _onScaleUpdate,
                            child: content,
                          )
                        : content,
                  ),
                ),
                _zoomChip(),
                if (widget.document.originalPng != null)
                  _originalToggle(state.showOriginal),
              ],
            );
          },
        );
      },
    );
  }

  /// Переключатель «показать оригинал» — правый верхний угол, на уровне зума.
  Widget _originalToggle(bool active) {
    return Positioned(
      top: 14,
      right: 16,
      child: GestureDetector(
        onTap: () => _cubit.toggleOriginal(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                active ? Icons.image : Icons.image_outlined,
                size: 16,
                color: active ? Colors.white : const Color(0xFF5C6672),
              ),
              const SizedBox(width: 6),
              Text(
                'Оригинал',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : const Color(0xFF5C6672),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zoomChip() {
    return Positioned(
      top: 14,
      left: 16,
      child: ValueListenableBuilder<double>(
        valueListenable: _zoom,
        builder: (context, zoom, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.zoom_in, size: 16, color: Color(0xFF5C6672)),
                const SizedBox(width: 6),
                Text(
                  '${(zoom * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5C6672),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
