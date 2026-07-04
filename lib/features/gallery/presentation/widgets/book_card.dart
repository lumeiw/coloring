import 'package:flutter/material.dart';

import '../../../../core/domain/artwork.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/gallery_item.dart';

/// Карточка книги в галерее: обложка (первая страница) со «стопкой» позади,
/// бейдж с числом страниц и общий прогресс.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onLongPress,
  });

  final BookItem book;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final done = book.status == ArtworkStatus.done;
    final fresh = book.status == ArtworkStatus.fresh;
    final accent = done ? AppColors.secondary : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                children: [
                  // «Стопка страниц» позади обложки.
                  Positioned.fill(
                    left: 10,
                    top: 10,
                    right: -2,
                    bottom: -2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outline),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    right: 6,
                    bottom: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          border: Border.all(color: AppColors.outline),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: book.cover != null
                                  ? Image.memory(book.cover!, fit: BoxFit.cover)
                                  : const ColoredBox(
                                      color: AppColors.surfaceContainerHigh,
                                    ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.menu_book,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${book.pageCount} стр.',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (done)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: book.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                fresh ? 'Новая' : '${(book.progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fresh ? AppColors.muted : accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
