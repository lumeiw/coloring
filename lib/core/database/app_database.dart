import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Локальная БД приложения (SQLite через drift). Всё хранение — офлайн.
@lazySingleton
@DriftDatabase(tables: [Artworks, CvCacheEntries, Strokes, Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Отдельный конструктор для тестов (in-memory или подменённый executor).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // Каждый шаг идемпотентен (проверяем, не применён ли уже): ALTER TABLE
        // в SQLite не откатывается, и прерванная миграция иначе валила бы
        // повторный запуск ошибкой «duplicate column».
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: книги, привязка страниц к книге, оригинал страницы в кеше.
            if (!await _tableExists(books.actualTableName)) {
              await m.createTable(books);
            }
            if (!await _columnExists(artworks.actualTableName, 'book_id')) {
              await m.addColumn(artworks, artworks.bookId);
            }
            if (!await _columnExists(
              cvCacheEntries.actualTableName,
              'original_image',
            )) {
              await m.addColumn(cvCacheEntries, cvCacheEntries.originalImage);
            }
          }
          if (from < 3) {
            // v3: обложка книги (первая выбранная страница, без CV).
            if (!await _columnExists(books.actualTableName, 'cover')) {
              await m.addColumn(books, books.cover);
            }
          }
        },
        beforeOpen: (details) async {
          // Включаем каскадные удаления (книга → страницы → кеш/мазки).
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<bool> _tableExists(String table) async {
    final rows = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable<String>(table)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((r) => r.read<String>('name') == column);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // sqlite3 3.x поставляет нативную библиотеку сам, доп. workaround не нужен.
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'coloring.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
