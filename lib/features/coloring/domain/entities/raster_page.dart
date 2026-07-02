import 'dart:typed_data';

/// Растеризованная страница PDF — вход CV-пайплайна.
///
/// Пиксели в формате **BGRA8888** (как отдаёт pdfrx). Пайплайн сам переводит
/// их в grayscale, так что порядок каналов важен только для конверсии цвета.
class RasterPage {
  const RasterPage({
    required this.bgra,
    required this.width,
    required this.height,
    this.isBgra = true,
  });

  /// Сырые пиксели RGBA/BGRA (4 канала). Порядок каналов — в [isBgra].
  final Uint8List bgra;
  final int width;
  final int height;

  /// true — BGRA (pdfrx), false — RGBA (декодированное изображение).
  final bool isBgra;
}
