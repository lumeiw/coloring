/// Имена и пути маршрутов приложения в одном месте.
abstract final class AppRoutes {
  static const gallery = '/';
  static const galleryName = 'gallery';

  static const importUpload = '/import';
  static const importUploadName = 'import';

  static const importPages = '/import/pages';
  static const importPagesName = 'import-pages';

  static const importProcessing = '/import/processing';
  static const importProcessingName = 'import-processing';

  /// Экран раскрашивания конкретной работы: /coloring/:id
  static const coloring = '/coloring/:id';
  static const coloringName = 'coloring';

  static String coloringPath(int artworkId) => '/coloring/$artworkId';

  /// Страницы книги: /book/:id
  static const book = '/book/:id';
  static const bookName = 'book';

  static String bookPath(int bookId) => '/book/$bookId';
}
