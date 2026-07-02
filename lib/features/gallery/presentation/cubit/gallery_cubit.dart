import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/domain/artwork.dart';
import '../../../coloring/data/coloring_storage.dart';

class GalleryState extends Equatable {
  const GalleryState({this.loading = true, this.artworks = const []});

  final bool loading;
  final List<Artwork> artworks;

  @override
  List<Object?> get props => [loading, artworks];
}

/// Список работ галереи, живущий поверх потока drift.
@injectable
class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit(this._storage) : super(const GalleryState()) {
    _sub = _storage.watchArtworks().listen(_onRows);
  }

  final ColoringStorage _storage;
  StreamSubscription<List<ArtworkRow>>? _sub;

  void _onRows(List<ArtworkRow> rows) {
    emit(
      GalleryState(
        loading: false,
        artworks: [for (final r in rows) _toArtwork(r)],
      ),
    );
  }

  Future<void> remove(int id) => _storage.deleteArtwork(id);

  static Artwork _toArtwork(ArtworkRow r) {
    return Artwork(
      id: r.id,
      title: r.title,
      progress: r.progress,
      status: ArtworkStatus.values[r.status.clamp(0, 2)],
      thumbnail: r.thumbnail,
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
