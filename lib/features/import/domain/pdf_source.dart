/// Источник для импорта: PDF-файл, встроенный образец или фото/изображение.
sealed class ImportSource {
  const ImportSource();

  /// Человекочитаемое имя для названия работы.
  String get displayName;
}

/// PDF-файл, выбранный пользователем.
class PdfFileSource extends ImportSource {
  const PdfFileSource(this.path, {String? name}) : _name = name;

  final String path;
  final String? _name;

  @override
  String get displayName => _name ?? path.split('/').last;
}

/// Встроенный образец из ассетов (демо).
class PdfAssetSource extends ImportSource {
  const PdfAssetSource(this.asset);

  final String asset;

  @override
  String get displayName => asset.split('/').last;
}

/// Фото/изображение раскраски (PNG/JPG), выбранное из фотоплёнки или файлов.
class ImageFileSource extends ImportSource {
  const ImageFileSource(this.path, {String? name}) : _name = name;

  final String path;
  final String? _name;

  @override
  String get displayName => _name ?? path.split('/').last;
}
