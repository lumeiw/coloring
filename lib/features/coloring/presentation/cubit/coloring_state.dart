import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/brush_stroke.dart';
import '../../domain/entities/coloring_document.dart';

/// Активный инструмент нижней панели.
enum ColoringTool { brush, hand, eyedropper }

/// Границы параметров кисти (в пикселях картинки / доля непрозрачности).
abstract final class BrushLimits {
  static const double minSize = 3;
  static const double maxSize = 48;
  static const double minOpacity = 0.35;
  static const double maxOpacity = 1;
}

class ColoringState extends Equatable {
  const ColoringState({
    this.loading = true,
    this.document,
    this.strokes = const [],
    this.redoStack = const [],
    this.color = _defaultColor,
    this.tool = ColoringTool.brush,
    this.brushSize = 12,
    this.opacity = 1,
    this.activeRegionId = 0,
    this.clipToRegion = true,
    this.showOriginal = false,
  });

  static const _defaultColor = Color(0xFFB9CDA6); // Sage из палитры

  final bool loading;
  final ColoringDocument? document;

  /// Зафиксированные мазки (лог для undo/redo и сохранения прогресса).
  final List<BrushStroke> strokes;
  final List<BrushStroke> redoStack;

  final Color color;
  final ColoringTool tool;

  /// Толщина кисти в пикселях картинки.
  final double brushSize;

  /// Непрозрачность мазка (0..1).
  final double opacity;

  /// Регион под пальцем (для подсветки); 0 — нет.
  final int activeRegionId;

  /// true — красить только внутри контуров; false — где угодно на рисунке.
  final bool clipToRegion;

  /// true — показывать оригинал (без обработок и мазков); рисование выключено.
  final bool showOriginal;

  bool get canUndo => strokes.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  /// Индекс выбранного цвета в палитре (или -1, если цвет не из палитры).
  int get paletteIndex => AppColors.palette.indexOf(color);

  /// Доля закрашенных областей (хотя бы одним мазком) — для прогресса галереи.
  double get progress {
    final doc = document;
    if (doc == null || doc.regions.isEmpty) return 0;
    final painted = strokes.map((s) => s.regionId).toSet()
      ..removeWhere((id) => id <= 0);
    return (painted.length / doc.regions.length).clamp(0.0, 1.0);
  }

  ColoringState copyWith({
    bool? loading,
    ColoringDocument? document,
    List<BrushStroke>? strokes,
    List<BrushStroke>? redoStack,
    Color? color,
    ColoringTool? tool,
    double? brushSize,
    double? opacity,
    int? activeRegionId,
    bool? clipToRegion,
    bool? showOriginal,
  }) {
    return ColoringState(
      loading: loading ?? this.loading,
      document: document ?? this.document,
      strokes: strokes ?? this.strokes,
      redoStack: redoStack ?? this.redoStack,
      color: color ?? this.color,
      tool: tool ?? this.tool,
      brushSize: brushSize ?? this.brushSize,
      opacity: opacity ?? this.opacity,
      activeRegionId: activeRegionId ?? this.activeRegionId,
      clipToRegion: clipToRegion ?? this.clipToRegion,
      showOriginal: showOriginal ?? this.showOriginal,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    document,
    strokes,
    redoStack,
    color,
    tool,
    brushSize,
    opacity,
    activeRegionId,
    clipToRegion,
    showOriginal,
  ];
}
