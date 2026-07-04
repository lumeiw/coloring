import '../entities/coloring_document.dart';

/// Контракт загрузки документа раскраски по id работы. Реализация читает
/// CV-кеш из drift; движок зависит только от этого интерфейса.
abstract interface class ColoringRepository {
  Future<ColoringDocument> loadDocument(int artworkId);
}
