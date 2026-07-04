import 'dart:typed_data';

import 'pdf_source.dart';

/// Импорт раскраски: перечисление страниц PDF и обработка выбранной страницы
/// (растеризация → CV → сохранение работы) в локальное хранилище.
abstract interface class ImportRepository {
  Future<int> pageCount(ImportSource source);

  Future<Uint8List> pageThumbnail(ImportSource source, int pageIndex);

  /// Обрабатывает выбранные страницы. Одна страница — одиночная работа,
  /// несколько — книга: первая выбранная страница становится ТОЛЬКО обложкой
  /// (без CV и без страницы в книге), остальные — страницами. Возвращает id
  /// первой созданной работы. [onPage] — прогресс: (обработано, всего CV-страниц).
  Future<int> importPages(
    ImportSource source,
    List<int> pageIndexes, {
    required String title,
    void Function(int done, int total)? onPage,
  });
}
