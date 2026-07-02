import 'package:flutter/material.dart';

import '../../../../core/domain/artwork.dart';
import '../../../../core/theme/app_colors.dart';

/// Карточка работы в галерее: превью, название и полоса прогресса.
class ArtworkCard extends StatelessWidget {
  const ArtworkCard({super.key, required this.artwork, this.onTap});

  final Artwork artwork;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = artwork.status == ArtworkStatus.done;
    final fresh = artwork.status == ArtworkStatus.fresh;
    final accent = done ? AppColors.secondary : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: _Preview(artwork: artwork, done: done),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            artwork.title,
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
                    value: artwork.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                fresh ? 'Новая' : '${(artwork.progress * 100).round()}%',
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

/// Плейсхолдер превью (диагональная штриховка + цветные «залитые» области).
/// На этапе 3 заменяется реальным снапшотом холста из drift.
class _Preview extends StatelessWidget {
  const _Preview({required this.artwork, required this.done});

  final Artwork artwork;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          border: Border.all(color: AppColors.outline),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: artwork.thumbnail != null
                  ? Image.memory(artwork.thumbnail!, fit: BoxFit.cover)
                  : CustomPaint(painter: _HatchPainter()),
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
                  child: const Icon(Icons.check, size: 18, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Диагональная штриховка как заглушка контуров раскраски.
class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.outline.withValues(alpha: 0.5)
      ..strokeWidth = 7;
    for (double x = -size.height; x < size.width; x += 16) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => false;
}
