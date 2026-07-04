import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:injectable/injectable.dart';

import '../domain/entities/coloring_document.dart';
import '../domain/repositories/coloring_repository.dart';
import 'coloring_storage.dart';

/// Реальная загрузка документа раскраски из CV-кеша (drift).
///
/// Работа создаётся во время импорта: там же считается CV и кладётся в кеш,
/// поэтому открытие раскраски — это просто чтение готовых данных, без пересчёта.
@LazySingleton(as: ColoringRepository)
class ColoringRepositoryImpl implements ColoringRepository {
  ColoringRepositoryImpl(this._storage);

  final ColoringStorage _storage;

  @override
  Future<ColoringDocument> loadDocument(int artworkId) async {
    final cache = await _storage.loadCvCache(artworkId);
    if (cache == null) {
      throw StateError('Нет CV-кеша для работы $artworkId — сначала импорт.');
    }

    final lineArt = await _decodeImage(cache.enhancedImage);
    return ColoringDocument(
      lineArt: lineArt,
      width: cache.width,
      height: cache.height,
      labelMap: ColoringStorage.labelMapFromBytes(cache.labelMap),
      regions: ColoringStorage.decodeRegions(cache.regionsJson),
      originalPng: cache.originalImage,
    );
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
