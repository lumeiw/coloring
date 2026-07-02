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
@DriftDatabase(tables: [Artworks, CvCacheEntries, Strokes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Отдельный конструктор для тестов (in-memory или подменённый executor).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // sqlite3 3.x поставляет нативную библиотеку сам, доп. workaround не нужен.
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'coloring.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
