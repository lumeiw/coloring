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
  Future<int> importPages(
    ImportSource source,
    List<int> pageIndexes, {
    required String title,
    void Function(int done, int total)? onPage,
  }) async {
    assert(pageIndexes.isNotEmpty, 'нужна хотя бы одна страница');
    final pages = [...pageIndexes]..sort();
    final sourcePath = switch (source) {
      PdfFileSource(:final path) => path,
      ImageFileSource(:final path) => path,
      PdfAssetSource() => null,
    };

    // Несколько страниц — книга. Первая выбранная страница — только обложка:
    // не обрабатывается CV и не становится страницей книги.
    final isBook = pages.length > 1;
    int? bookId;
    if (isBook) {
      final coverIndex = pages.removeAt(0);
      final cover = await _rasterizer.thumbnail(
        source,
        coverIndex,
        width: 720,
      );
      bookId = await _storage.createBook(
        title: title,
        sourcePdfPath: sourcePath,
        cover: cover,
      );
    }

    int? firstId;
    for (var i = 0; i < pages.length; i++) {
      onPage?.call(i, pages.length);
      final pageIndex = pages[i];
      final page = await _rasterizer.rasterize(source, pageIndex);
      final result = await _cv.process(page);

      final artworkId = await _storage.createArtwork(
        title: isBook ? 'Стр. ${pageIndex + 1}' : title,
        sourcePdfPath: sourcePath,
        pageIndex: pageIndex,
        bookId: bookId,
      );
      await _storage.saveCvCache(artworkId, result);
      // Сразу кладём line-art как превью, чтобы работа не была пустой.
      await _storage.updateProgress(
        artworkId,
        progress: 0,
        thumbnail: result.enhancedPng,
      );
      firstId ??= artworkId;
    }
    onPage?.call(pages.length, pages.length);
    return firstId!;
  }
}
