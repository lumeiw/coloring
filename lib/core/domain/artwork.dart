import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'artwork.freezed.dart';

/// Статус работы в галерее.
enum ArtworkStatus {
  /// Ещё не начата (0% прогресса).
  fresh,

  /// В работе.
  inProgress,

  /// Завершена (100%).
  done,
}

/// Доменная модель работы пользователя. Общая для галереи и раскрашивания.
@freezed
abstract class Artwork with _$Artwork {
  const factory Artwork({
    required int id,
    required String title,
    @Default(0) double progress,
    @Default(ArtworkStatus.fresh) ArtworkStatus status,

    /// PNG-превью для карточки галереи.
    Uint8List? thumbnail,
    String? sourcePdfPath,
    @Default(0) int pageIndex,
  }) = _Artwork;
}
