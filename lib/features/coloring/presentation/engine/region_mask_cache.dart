import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Кеш alpha-масок регионов.
///
/// Из label-map по id региона строит [ui.Image], где пиксели региона
/// непрозрачны (белые), остальные — прозрачны. Такая маска накладывается на
/// мазок через [ui.BlendMode.dstIn], чтобы краска не выходила за контур и не
/// попадала на цифры. Работает с произвольными пиксельными регионами, поэтому
/// подходит и для мока (этап 2), и для реального CV (этап 3).
class RegionMaskCache {
  RegionMaskCache({
    required this.labelMap,
    required this.width,
    required this.height,
    this.capacity = 8,
  });

  final Int32List labelMap;
  final int width;
  final int height;

  /// Сколько масок держать в памяти (LRU) — маски крупные (w*h*4 байт).
  final int capacity;

  final LinkedHashMap<int, ui.Image> _cache = LinkedHashMap();
  final Map<int, Future<ui.Image>> _pending = {};

  /// Возвращает маску региона, строя её при необходимости.
  Future<ui.Image> maskFor(int regionId) {
    final cached = _cache.remove(regionId);
    if (cached != null) {
      _cache[regionId] = cached; // обновляем позицию в LRU
      return Future.value(cached);
    }
    return _pending[regionId] ??= _build(regionId);
  }

  /// Синхронно отдаёт уже готовую маску (или null, если ещё не построена).
  ui.Image? peek(int regionId) => _cache[regionId];

  Future<ui.Image> _build(int regionId) async {
    final pixels = Uint8List(width * height * 4);
    for (var i = 0; i < labelMap.length; i++) {
      if (labelMap[i] == regionId) {
        final o = i * 4;
        pixels[o] = 255;
        pixels[o + 1] = 255;
        pixels[o + 2] = 255;
        pixels[o + 3] = 255;
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final image = await completer.future;

    _pending.remove(regionId);
    _put(regionId, image);
    return image;
  }

  void _put(int regionId, ui.Image image) {
    _cache[regionId] = image;
    while (_cache.length > capacity) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey)?.dispose();
    }
  }

  void dispose() {
    for (final img in _cache.values) {
      img.dispose();
    }
    _cache.clear();
    _pending.clear();
  }
}
