import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../core/domain/artwork.dart';

/// Элемент галереи: одиночная работа или книга (многостраничный импорт).
sealed class GalleryItem extends Equatable {
  const GalleryItem();
}

/// Одиночная работа (bookId == null).
class SingleArtworkItem extends GalleryItem {
  const SingleArtworkItem(this.artwork);

  final Artwork artwork;

  @override
  List<Object?> get props => [artwork];
}

/// Книга: агрегат по её страницам.
class BookItem extends GalleryItem {
  const BookItem({
    required this.id,
    required this.title,
    required this.pageCount,
    required this.progress,
    this.cover,
  });

  final int id;
  final String title;
  final int pageCount;

  /// Средний прогресс по страницам (0..1).
  final double progress;

  /// Превью первой страницы.
  final Uint8List? cover;

  ArtworkStatus get status => progress >= 1
      ? ArtworkStatus.done
      : progress > 0
          ? ArtworkStatus.inProgress
          : ArtworkStatus.fresh;

  @override
  List<Object?> get props => [id, title, pageCount, progress, cover];
}
