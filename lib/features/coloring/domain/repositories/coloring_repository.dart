import '../entities/coloring_document.dart';

/// Контракт загрузки документа раскраски по id работы.
///
/// Этап 2 — мок-реализация (синтетические регионы).
/// Этап 3 — реализация поверх CvRepository + кеша drift. Domain при этом
/// не меняется: движок зависит только от этого интерфейса.
abstract interface class ColoringRepository {
  Future<ColoringDocument> loadDocument(int artworkId);
}
