import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/coloring_storage.dart';
import '../../domain/entities/brush_stroke.dart';
import '../../domain/repositories/coloring_repository.dart';
import 'coloring_state.dart';

/// Управляет логическим состоянием экрана раскрашивания: документ, лог мазков,
/// undo/redo и параметры кисти. Прогресс и лог сохраняются в drift, поэтому
/// повторное открытие работы восстанавливает раскраску.
@injectable
class ColoringCubit extends Cubit<ColoringState> {
  ColoringCubit(this._repository, this._storage) : super(const ColoringState());

  final ColoringRepository _repository;
  final ColoringStorage _storage;

  int _artworkId = 0;

  /// Дебаунс записи лога: замыкаем частые мазки в одну запись вместо O(N²)
  /// перезаписей на каждый штрих.
  Timer? _persistTimer;

  Future<void> load(int artworkId) async {
    _artworkId = artworkId;
    emit(state.copyWith(loading: true));
    final document = await _repository.loadDocument(artworkId);
    final strokes = await _storage.loadStrokes(artworkId);
    emit(
      state.copyWith(
        loading: false,
        document: document,
        strokes: strokes,
        redoStack: const [],
      ),
    );
  }

  void selectColor(Color color) => emit(state.copyWith(color: color));

  void selectTool(ColoringTool tool) => emit(state.copyWith(tool: tool));

  /// Переключить режим: только внутри контуров ↔ рисовать где угодно.
  void toggleClip() =>
      emit(state.copyWith(clipToRegion: !state.clipToRegion));

  /// Переключить показ оригинала (без обработок и мазков).
  void toggleOriginal() =>
      emit(state.copyWith(showOriginal: !state.showOriginal));

  void setBrushSize(double size) => emit(state.copyWith(brushSize: size));

  void setOpacity(double opacity) => emit(state.copyWith(opacity: opacity));

  void setActiveRegion(int regionId) {
    if (regionId == state.activeRegionId) return;
    emit(state.copyWith(activeRegionId: regionId));
  }

  void commitStroke(BrushStroke stroke) {
    if (stroke.points.isEmpty || stroke.regionId == 0) return;
    emit(state.copyWith(strokes: [...state.strokes, stroke], redoStack: const []));
    _persist();
  }

  void undo() {
    if (!state.canUndo) return;
    final strokes = [...state.strokes];
    final last = strokes.removeLast();
    emit(
      state.copyWith(strokes: strokes, redoStack: [...state.redoStack, last]),
    );
    _persist();
  }

  void redo() {
    if (!state.canRedo) return;
    final redo = [...state.redoStack];
    final restored = redo.removeLast();
    emit(
      state.copyWith(strokes: [...state.strokes, restored], redoStack: redo),
    );
    _persist();
  }

  /// Планирует сохранение лога и прогресса (дебаунс). Реальная запись — в
  /// [_flushPersist] после паузы в рисовании либо при закрытии экрана.
  void _persist() {
    if (_artworkId == 0) return;
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 400), _flushPersist);
  }

  /// Немедленно пишет актуальный лог мазков и прогресс (fire-and-forget).
  void _flushPersist() {
    _persistTimer?.cancel();
    _persistTimer = null;
    final id = _artworkId;
    if (id == 0) return;
    _storage.replaceStrokes(id, state.strokes);
    _storage.updateProgress(id, progress: state.progress);
  }

  /// Сохраняет PNG-снапшот холста как превью работы для галереи.
  Future<void> saveThumbnail(Uint8List png) async {
    if (_artworkId == 0) return;
    await _storage.updateProgress(
      _artworkId,
      progress: state.progress,
      thumbnail: png,
    );
  }

  @override
  Future<void> close() {
    _flushPersist(); // не теряем последние мазки при выходе с экрана
    return super.close();
  }
}
