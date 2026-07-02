import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../../coloring/data/coloring_storage.dart';
import '../../coloring/domain/repositories/cv_repository.dart';
import '../domain/import_repository.dart';
import '../domain/pdf_source.dart';
import 'pdf_rasterizer.dart';

/// Реализация импорта: pdfrx → CV → drift. Всё офлайн.
@LazySingleton(as: ImportRepository)
class ImportRepositoryImpl implements ImportRepository {
  ImportRepositoryImpl(this._rasterizer, this._cv, this._storage);

  final PdfRasterizer _rasterizer;
  final CvRepository _cv;
  final ColoringStorage _storage;

  @override
  Future<int> pageCount(ImportSource source) => _rasterizer.pageCount(source);

  @override
  Future<Uint8List> pageThumbnail(ImportSource source, int pageIndex) =>
      _rasterizer.thumbnail(source, pageIndex);

  @override
  Future<int> importPage(ImportSource source, int pageIndex) async {
    final page = await _rasterizer.rasterize(source, pageIndex);
    final result = await _cv.process(page);

    final artworkId = await _storage.createArtwork(
      title: _titleFor(source, pageIndex),
      sourcePdfPath: switch (source) {
        PdfFileSource(:final path) => path,
        ImageFileSource(:final path) => path,
        PdfAssetSource() => null,
      },
      pageIndex: pageIndex,
    );
    await _storage.saveCvCache(artworkId, result);
    // Сразу кладём line-art как превью, чтобы новая работа не была пустой.
    await _storage.updateProgress(
      artworkId,
      progress: 0,
      thumbnail: result.enhancedPng,
    );
    return artworkId;
  }

  String _titleFor(ImportSource source, int pageIndex) {
    final base = source.displayName.replaceAll(
      RegExp(r'\.(pdf|png|jpe?g|heic|webp)$', caseSensitive: false),
      '',
    );
    return pageIndex == 0 ? base : '$base · стр. ${pageIndex + 1}';
  }
}
