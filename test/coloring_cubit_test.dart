import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:coloring/core/database/app_database.dart';
import 'package:coloring/features/coloring/data/coloring_storage.dart';
import 'package:coloring/features/coloring/domain/entities/brush_stroke.dart';
import 'package:coloring/features/coloring/domain/entities/coloring_document.dart';
import 'package:coloring/features/coloring/domain/entities/region.dart';
import 'package:coloring/features/coloring/domain/repositories/coloring_repository.dart';
import 'package:coloring/features/coloring/presentation/cubit/coloring_cubit.dart';
import 'package:coloring/features/coloring/presentation/cubit/coloring_state.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Фейковый репозиторий: крошечный документ 2×2 с двумя регионами.
class _FakeRepo implements ColoringRepository {
  _FakeRepo(this._image);
  final ui.Image _image;

  @override
  Future<ColoringDocument> loadDocument(int artworkId) async {
    return ColoringDocument(
      lineArt: _image,
      width: 2,
      height: 2,
      labelMap: Int32List.fromList([1, 1, 2, 0]),
      regions: const [
        Region(id: 1, bounds: Rect.zero, labelNumber: 1),
        Region(id: 2, bounds: Rect.zero, labelNumber: 2),
      ],
    );
  }
}

Future<ui.Image> _dummyImage() {
  final c = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    Uint8List(4),
    1,
    1,
    ui.PixelFormat.rgba8888,
    c.complete,
  );
  return c.future;
}

BrushStroke _stroke(int region, Color color) => BrushStroke(
  regionId: region,
  color: color,
  size: 20,
  opacity: 1,
  points: const [Offset.zero],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ColoringStorage storage;
  late ColoringCubit cubit;
  late int artworkId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    storage = ColoringStorage(db);
    artworkId = await storage.createArtwork(title: 'Тест');
    cubit = ColoringCubit(_FakeRepo(await _dummyImage()), storage);
    await cubit.load(artworkId);
  });

  tearDown(() async {
    await cubit.close();
    // Даём фоновым (fire-and-forget) записям _persist завершиться до закрытия.
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await db.close();
  });

  test('стартовое состояние: нельзя undo/redo', () {
    expect(cubit.state.canUndo, isFalse);
    expect(cubit.state.canRedo, isFalse);
    expect(cubit.state.document, isNotNull);
  });

  test('выбор цвета и инструмента', () {
    cubit.selectColor(const Color(0xFFE8B4B8));
    cubit.selectTool(ColoringTool.eyedropper);
    expect(cubit.state.color, const Color(0xFFE8B4B8));
    expect(cubit.state.tool, ColoringTool.eyedropper);
  });

  test('commit → undo → redo восстанавливает мазок', () {
    cubit.commitStroke(_stroke(1, const Color(0xFFB9CDA6)));
    expect(cubit.state.strokes, hasLength(1));
    expect(cubit.state.canUndo, isTrue);

    cubit.undo();
    expect(cubit.state.strokes, isEmpty);
    expect(cubit.state.canRedo, isTrue);

    cubit.redo();
    expect(cubit.state.strokes, hasLength(1));
    expect(cubit.state.canRedo, isFalse);
  });

  test('прогресс = доля закрашенных областей', () {
    expect(cubit.state.progress, 0);
    cubit.commitStroke(_stroke(1, const Color(0xFFB9CDA6)));
    expect(cubit.state.progress, 0.5);
    cubit.commitStroke(_stroke(2, const Color(0xFFA8C6C9)));
    expect(cubit.state.progress, 1.0);
  });

  test('лог мазков сохраняется и перечитывается из хранилища', () async {
    cubit.commitStroke(_stroke(1, const Color(0xFFB9CDA6)));
    // Дать fire-and-forget записи завершиться.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final restored = await storage.loadStrokes(artworkId);
    expect(restored, hasLength(1));
    expect(restored.first.regionId, 1);
  });
}
