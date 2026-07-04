import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/brush_stroke.dart';
import '../domain/entities/cv_result.dart';
import '../domain/entities/region.dart';

/// Локальное хранилище работ, CV-кеша и лога мазков (drift/SQLite).
/// Единая точка сериализации между доменом и БД.
@lazySingleton
class ColoringStorage {
  ColoringStorage(this._db);

  final AppDatabase _db;

  // ————— Работы —————
  Future<int> createArtwork({
    required String title,
    String? sourcePdfPath,
    int pageIndex = 0,
    int? bookId,
  }) {
    return _db
        .into(_db.artworks)
        .insert(
          ArtworksCompanion.insert(
            title: title,
            sourcePdfPath: Value(sourcePdfPath),
            pageIndex: Value(pageIndex),
            bookId: Value(bookId),
          ),
        );
  }

  Stream<List<ArtworkRow>> watchArtworks() {
    return (_db.select(_db.artworks)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Страницы книги в порядке следования в PDF.
  Stream<List<ArtworkRow>> watchBookArtworks(int bookId) {
    return (_db.select(_db.artworks)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm.asc(t.pageIndex)]))
        .watch();
  }

  Future<void> renameArtwork(int id, String title) {
    return (_db.update(_db.artworks)..where((t) => t.id.equals(id))).write(
      ArtworksCompanion(title: Value(title), updatedAt: Value(DateTime.now())),
    );
  }

  Future<ArtworkRow?> artworkById(int id) {
    return (_db.select(_db.artworks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateProgress(
    int artworkId, {
    required double progress,
    Uint8List? thumbnail,
  }) {
    final status = progress >= 1
        ? 2
        : progress > 0
        ? 1
        : 0;
    return (_db.update(_db.artworks)..where((t) => t.id.equals(artworkId)))
        .write(
          ArtworksCompanion(
            progress: Value(progress),
            status: Value(status),
            thumbnail: thumbnail == null
                ? const Value.absent()
                : Value(thumbnail),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  /// Удаляет работу вместе с CV-кешем и мазками (не полагаемся на PRAGMA
  /// foreign_keys — чистим явно, так надёжнее для старых установок).
  Future<void> deleteArtwork(int id) {
    return _db.transaction(() async {
      await (_db.delete(_db.strokes)..where((t) => t.artworkId.equals(id))).go();
      await (_db.delete(_db.cvCacheEntries)
            ..where((t) => t.artworkId.equals(id)))
          .go();
      await (_db.delete(_db.artworks)..where((t) => t.id.equals(id))).go();
    });
  }

  // ————— Книги —————
  Future<int> createBook({
    required String title,
    String? sourcePdfPath,
    Uint8List? cover,
  }) {
    return _db
        .into(_db.books)
        .insert(
          BooksCompanion.insert(
            title: title,
            sourcePdfPath: Value(sourcePdfPath),
            cover: Value(cover),
          ),
        );
  }

  Stream<List<BookRow>> watchBooks() {
    return (_db.select(_db.books)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<BookRow?> bookById(int id) {
    return (_db.select(_db.books)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> renameBook(int id, String title) {
    return (_db.update(_db.books)..where((t) => t.id.equals(id))).write(
      BooksCompanion(title: Value(title), updatedAt: Value(DateTime.now())),
    );
  }

  /// Удаляет книгу со всеми страницами (и их кешем/мазками).
  Future<void> deleteBook(int id) {
    return _db.transaction(() async {
      final pages = await (_db.select(_db.artworks)
            ..where((t) => t.bookId.equals(id)))
          .get();
      for (final page in pages) {
        await deleteArtwork(page.id);
      }
      await (_db.delete(_db.books)..where((t) => t.id.equals(id))).go();
    });
  }

  // ————— CV-кеш —————
  Future<void> saveCvCache(int artworkId, CvResult result) {
    return _db
        .into(_db.cvCacheEntries)
        .insertOnConflictUpdate(
          CvCacheEntriesCompanion.insert(
            artworkId: Value(artworkId),
            width: result.width,
            height: result.height,
            labelMap: _int32ToBytes(result.labelMap),
            enhancedImage: result.enhancedPng,
            originalImage: Value(result.originalPng),
            regionsJson: _encodeRegions(result.regions),
          ),
        );
  }

  Future<CvCacheEntry?> loadCvCache(int artworkId) {
    return (_db.select(_db.cvCacheEntries)
          ..where((t) => t.artworkId.equals(artworkId)))
        .getSingleOrNull();
  }

  // ————— Лог мазков —————
  /// Полностью переписывает лог (после undo/redo проще сохранять целиком).
  Future<void> replaceStrokes(int artworkId, List<BrushStroke> strokes) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.strokes,
      )..where((t) => t.artworkId.equals(artworkId))).go();
      for (var i = 0; i < strokes.length; i++) {
        await _insertStroke(artworkId, strokes[i], i);
      }
    });
  }

  Future<List<BrushStroke>> loadStrokes(int artworkId) async {
    final rows =
        await (_db.select(_db.strokes)
              ..where((t) => t.artworkId.equals(artworkId))
              ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
            .get();
    return [for (final row in rows) _decodeStroke(row)];
  }

  Future<int> _insertStroke(int artworkId, BrushStroke stroke, int seq) {
    return _db
        .into(_db.strokes)
        .insert(
          StrokesCompanion.insert(
            artworkId: artworkId,
            seq: seq,
            regionId: stroke.regionId,
            color: stroke.color.toARGB32(),
            opacity: Value(stroke.opacity),
            brushSize: Value(stroke.size),
            points: _pointsToBytes(stroke.points),
          ),
        );
  }

  // ————— Сериализация —————
  static Uint8List _int32ToBytes(Int32List data) =>
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  /// Возвращает самостоятельную копию label-map из блоба.
  static Int32List labelMapFromBytes(Uint8List bytes) =>
      Int32List.fromList(bytes.buffer.asInt32List(bytes.offsetInBytes, bytes.lengthInBytes ~/ 4));

  static Uint8List _pointsToBytes(List<Offset> points) {
    final f = Float32List(points.length * 2);
    for (var i = 0; i < points.length; i++) {
      f[i * 2] = points[i].dx;
      f[i * 2 + 1] = points[i].dy;
    }
    return f.buffer.asUint8List(f.offsetInBytes, f.lengthInBytes);
  }

  static List<Offset> _pointsFromBytes(Uint8List bytes) {
    final f = bytes.buffer.asFloat32List(bytes.offsetInBytes, bytes.lengthInBytes ~/ 4);
    return [for (var i = 0; i < f.length; i += 2) Offset(f[i], f[i + 1])];
  }

  static String _encodeRegions(List<Region> regions) {
    return jsonEncode([
      for (final r in regions)
        {
          'id': r.id,
          'n': r.labelNumber,
          'l': r.bounds.left,
          't': r.bounds.top,
          'w': r.bounds.width,
          'h': r.bounds.height,
          'cx': r.numberAnchor?.dx,
          'cy': r.numberAnchor?.dy,
          'c': r.suggestedColor?.toARGB32(),
        },
    ]);
  }

  static List<Region> decodeRegions(String json) {
    final list = (jsonDecode(json) as List).cast<Map<String, dynamic>>();
    return [
      for (final m in list)
        Region(
          id: m['id'] as int,
          labelNumber: m['n'] as int,
          bounds: Rect.fromLTWH(
            (m['l'] as num).toDouble(),
            (m['t'] as num).toDouble(),
            (m['w'] as num).toDouble(),
            (m['h'] as num).toDouble(),
          ),
          numberAnchor: m['cx'] == null
              ? null
              : Offset((m['cx'] as num).toDouble(), (m['cy'] as num).toDouble()),
          suggestedColor: m['c'] == null ? null : Color(m['c'] as int),
        ),
    ];
  }

  static BrushStroke _decodeStroke(Stroke row) {
    return BrushStroke(
      regionId: row.regionId,
      color: Color(row.color),
      size: row.brushSize,
      opacity: row.opacity,
      points: _pointsFromBytes(row.points),
    );
  }
}
