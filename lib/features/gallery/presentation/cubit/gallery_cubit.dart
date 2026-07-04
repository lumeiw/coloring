import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/domain/artwork.dart';
import '../../../coloring/data/coloring_storage.dart';
import '../../domain/gallery_item.dart';

class GalleryState extends Equatable {
  const GalleryState({this.loading = true, this.items = const []});

  final bool loading;
  final List<GalleryItem> items;

  @override
  List<Object?> get props => [loading, items];
}

/// Список галереи (одиночные работы + книги), живущий поверх потоков drift.
@injectable
class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit(this._storage) : super(const GalleryState()) {
    _artSub = _storage.watchArtworks().listen((rows) {
      _artworks = rows;
      _emit();
    });
    _bookSub = _storage.watchBooks().listen((rows) {
      _books = rows;
      _booksLoaded = true;
      _emit();
    });
  }

  final ColoringStorage _storage;
  StreamSubscription<List<ArtworkRow>>? _artSub;
  StreamSubscription<List<BookRow>>? _bookSub;

  List<ArtworkRow>? _artworks;
  List<BookRow> _books = const [];
  bool _booksLoaded = false;

  void _emit() {
    final artworks = _artworks;
    if (artworks == null || !_booksLoaded) return; // ждём оба потока

    // Страницы книг группируем, одиночные работы идут как есть.
    final byBook = <int, List<ArtworkRow>>{};
    final singles = <ArtworkRow>[];
    for (final row in artworks) {
      final bookId = row.bookId;
      if (bookId == null) {
        singles.add(row);
      } else {
        byBook.putIfAbsent(bookId, () => []).add(row);
      }
    }

    final items = <GalleryItem>[
      for (final book in _books)
        _toBookItem(book, byBook[book.id] ?? const []),
      for (final row in singles) SingleArtworkItem(_toArtwork(row)),
    ];
    emit(GalleryState(loading: false, items: items));
  }

  Future<void> removeArtwork(int id) => _storage.deleteArtwork(id);

  Future<void> removeBook(int id) => _storage.deleteBook(id);

  Future<void> renameArtwork(int id, String title) =>
      _storage.renameArtwork(id, title);

  Future<void> renameBook(int id, String title) =>
      _storage.renameBook(id, title);

  static BookItem _toBookItem(BookRow book, List<ArtworkRow> pages) {
    final sorted = [...pages]..sort((a, b) => a.pageIndex.compareTo(b.pageIndex));
    final progress = sorted.isEmpty
        ? 0.0
        : sorted.fold<double>(0, (sum, p) => sum + p.progress) / sorted.length;
    return BookItem(
      id: book.id,
      title: book.title,
      pageCount: sorted.length,
      progress: progress.clamp(0.0, 1.0),
      // Обложка книги; у книг, созданных до v3, её нет — берём превью
      // первой страницы.
      cover: book.cover ?? (sorted.isEmpty ? null : sorted.first.thumbnail),
    );
  }

  static Artwork _toArtwork(ArtworkRow r) {
    return Artwork(
      id: r.id,
      title: r.title,
      progress: r.progress,
      status: ArtworkStatus.values[r.status.clamp(0, 2)],
      thumbnail: r.thumbnail,
    );
  }

  @override
  Future<void> close() {
    _artSub?.cancel();
    _bookSub?.cancel();
    return super.close();
  }
}
