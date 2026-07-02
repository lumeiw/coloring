import 'dart:typed_data';

import 'pdf_source.dart';

/// Импорт раскраски: перечисление страниц PDF и обработка выбранной страницы
/// (растеризация → CV → сохранение работы) в локальное хранилище.
abstract interface class ImportRepository {
  Future<int> pageCount(ImportSource source);

  Future<Uint8List> pageThumbnail(ImportSource source, int pageIndex);

  /// Обрабатывает страницу и создаёт работу. Возвращает id новой работы.
  Future<int> importPage(ImportSource source, int pageIndex);
}
