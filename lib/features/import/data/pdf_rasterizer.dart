import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:injectable/injectable.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../coloring/domain/entities/raster_page.dart';
import '../domain/pdf_source.dart';

/// Растеризация источника (PDF через pdfrx или фото/изображение) для CV.
@lazySingleton
class PdfRasterizer {
  static const String sampleAsset = 'assets/sample/coloring_sample.pdf';
  static const int _cvTargetWidth = 1200;

  Future<int> pageCount(ImportSource source) async {
    if (source is ImageFileSource) return 1; // изображение — одна «страница»
    final doc = await _openPdf(source);
    try {
      return doc.pages.length;
    } finally {
      await doc.dispose();
    }
  }

  /// PNG-миниатюра страницы/изображения для экрана выбора.
  Future<Uint8List> thumbnail(
    ImportSource source,
    int pageIndex, {
    int width = 320,
  }) async {
    if (source is ImageFileSource) {
      final image = await _decodeImageFile(source.path, targetWidth: width);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    }
    final doc = await _openPdf(source);
    try {
      return await _renderPdf(doc, pageIndex, width, asPng: true) as Uint8List;
    } finally {
      await doc.dispose();
    }
  }

  /// Растеризация страницы/изображения в пиксели для CV-пайплайна.
  Future<RasterPage> rasterize(ImportSource source, int pageIndex) async {
    if (source is ImageFileSource) {
      final image = await _decodeImageFile(
        source.path,
        targetWidth: _cvTargetWidth,
      );
      try {
        final data = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        return RasterPage(
          bgra: data!.buffer.asUint8List(),
          width: image.width,
          height: image.height,
          isBgra: false, // декодированное изображение — RGBA
        );
      } finally {
        image.dispose();
      }
    }
    final doc = await _openPdf(source);
    try {
      return await _renderPdf(doc, pageIndex, _cvTargetWidth, asPng: false)
          as RasterPage;
    } finally {
      await doc.dispose();
    }
  }

  // ————— PDF —————
  Future<PdfDocument> _openPdf(ImportSource source) => switch (source) {
    PdfFileSource(:final path) => PdfDocument.openFile(path),
    PdfAssetSource(:final asset) => PdfDocument.openAsset(asset),
    ImageFileSource() => throw StateError('изображение не открывается как PDF'),
  };

  Future<Object> _renderPdf(
    PdfDocument doc,
    int pageIndex,
    int targetWidth, {
    required bool asPng,
  }) async {
    final page = doc.pages[pageIndex];
    final targetHeight = (targetWidth * page.height / page.width).round();
    final image = await page.render(
      fullWidth: targetWidth.toDouble(),
      fullHeight: targetHeight.toDouble(),
      width: targetWidth,
      height: targetHeight,
      backgroundColor: 0xFFFFFFFF,
    );
    if (image == null) {
      throw StateError('Не удалось растеризовать страницу $pageIndex');
    }
    try {
      if (!asPng) {
        return RasterPage(
          bgra: Uint8List.fromList(image.pixels),
          width: image.width,
          height: image.height,
        );
      }
      return await _bgraToPng(image.pixels, image.width, image.height);
    } finally {
      image.dispose();
    }
  }

  // ————— Изображение —————
  Future<ui.Image> _decodeImageFile(
    String path, {
    required int targetWidth,
  }) async {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<Uint8List> _bgraToPng(Uint8List bgra, int width, int height) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bgra,
      width,
      height,
      ui.PixelFormat.bgra8888,
      completer.complete,
    );
    final image = await completer.future;
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}
