import '../entities/cv_result.dart';
import '../entities/raster_page.dart';

/// Контракт компьютерного зрения: превращает растеризованную страницу в
/// разметку раскраски (улучшенный line-art + label-map + регионы).
///
/// Domain зависит только от этого интерфейса. Локальная реализация
/// [LocalCvDataSource] считает всё офлайн на устройстве; при необходимости
/// позже можно добавить RemoteCvDataSource, не трогая domain.
abstract interface class CvRepository {
  Future<CvResult> process(RasterPage page);
}
