import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/domain/artwork.dart';
import '../../../coloring/data/coloring_storage.dart';
import '../widgets/artwork_card.dart';
import '../widgets/item_actions.dart';

/// Страницы книги: сетка страниц, тап — раскраска, длинное нажатие — меню.
class BookPage extends StatefulWidget {
  const BookPage({super.key, required this.bookId});

  final int bookId;

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final _storage = getIt<ColoringStorage>();
  String _title = '';

  @override
  void initState() {
    super.initState();
    _loadTitle();
  }

  Future<void> _loadTitle() async {
    final book = await _storage.bookById(widget.bookId);
    if (mounted && book != null) setState(() => _title = book.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_title.isEmpty ? 'Книга' : _title),
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<List<ArtworkRow>>(
          stream: _storage.watchBookArtworks(widget.bookId),
          builder: (context, snapshot) {
            final rows = snapshot.data;
            if (rows == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (rows.isEmpty) {
              return const Center(child: Text('В книге нет страниц'));
            }
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                // Сетка карточек — шаг lg (16) из дизайн-системы.
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.66,
              ),
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final art = _toArtwork(rows[i]);
                return ArtworkCard(
                  artwork: art,
                  onTap: () => context.push(AppRoutes.coloringPath(art.id)),
                  onLongPress: () => showItemActions(
                    context,
                    title: art.title,
                    onRename: (t) => _storage.renameArtwork(art.id, t),
                    onDelete: () => _storage.deleteArtwork(art.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static Artwork _toArtwork(ArtworkRow r) {
    return Artwork(
      id: r.id,
      title: r.title,
      progress: r.progress,
      status: ArtworkStatus.values[r.status.clamp(0, 2)],
      thumbnail: r.thumbnail,
    );
  }
}
