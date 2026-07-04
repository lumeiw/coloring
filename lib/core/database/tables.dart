import 'package:drift/drift.dart';

/// Книга — многостраничный импорт PDF. Страницы книги лежат в [Artworks]
/// со ссылкой bookId; одиночные работы книги не имеют (bookId == null).
@DataClassName('BookRow')
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  /// Путь к исходному PDF книги.
  TextColumn get sourcePdfPath => text().nullable()();

  /// PNG-обложка (первая выбранная страница; она НЕ обрабатывается CV и
  /// не входит в страницы книги — только превью для карточки галереи).
  BlobColumn get cover => blob().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Работы пользователя (то, что показывается в галерее).
@DataClassName('ArtworkRow')
class Artworks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  /// Книга, к которой относится страница (null — одиночная работа).
  IntColumn get bookId =>
      integer().nullable().references(Books, #id, onDelete: KeyAction.cascade)();

  /// Индекс значения enum ArtworkStatus (new / inProgress / done).
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Прогресс раскрашивания 0.0..1.0.
  RealColumn get progress => real().withDefault(const Constant(0))();

  /// PNG-превью для карточки галереи (снапшот холста).
  BlobColumn get thumbnail => blob().nullable()();

  /// Путь к исходному PDF (для повторной растеризации при необходимости).
  TextColumn get sourcePdfPath => text().nullable()();

  /// Индекс выбранной страницы в исходном PDF.
  IntColumn get pageIndex => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Кеш результата CV-пайплайна, чтобы повторное открытие было моментальным.
class CvCacheEntries extends Table {
  IntColumn get artworkId =>
      integer().references(Artworks, #id, onDelete: KeyAction.cascade)();

  IntColumn get width => integer()();

  IntColumn get height => integer()();

  /// Label-map: сырые байты Int32List длиной width*height.
  BlobColumn get labelMap => blob()();

  /// Улучшенный line-art (display-версия) в виде PNG.
  BlobColumn get enhancedImage => blob()();

  /// Оригинал страницы (PNG без обработок, тот же размер, что display) —
  /// для режима «показать оригинал» на экране рисования.
  BlobColumn get originalImage => blob().nullable()();

  /// JSON-список регионов (id, площадь, bbox, центроид номера).
  TextColumn get regionsJson => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {artworkId};
}

/// Лог мазков для реплея undo/redo и восстановления прогресса.
class Strokes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get artworkId =>
      integer().references(Artworks, #id, onDelete: KeyAction.cascade)();

  /// Порядковый номер мазка (для реплея и undo/redo).
  IntColumn get seq => integer()();

  /// Регион, по маске которого клиппился мазок.
  IntColumn get regionId => integer()();

  /// Цвет мазка (ARGB int).
  IntColumn get color => integer()();

  RealColumn get opacity => real().withDefault(const Constant(1))();

  RealColumn get brushSize => real().withDefault(const Constant(24))();

  /// Упакованные координаты точек мазка (Float32List: x0,y0,x1,y1,…).
  BlobColumn get points => blob()();
}
