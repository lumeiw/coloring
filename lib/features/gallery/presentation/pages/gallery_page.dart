import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/domain/artwork.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/gallery_item.dart';
import '../cubit/gallery_cubit.dart';
import '../widgets/artwork_card.dart';
import '../widgets/book_card.dart';
import '../widgets/item_actions.dart';

/// Экран «Мои работы» (галерея) поверх реальных данных drift.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GalleryCubit>(
      create: (_) => getIt<GalleryCubit>(),
      child: const _GalleryView(),
    );
  }
}

enum _Filter { all, inProgress, done }

class _GalleryView extends StatefulWidget {
  const _GalleryView();

  @override
  State<_GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<_GalleryView> {
  _Filter _filter = _Filter.all;

  ArtworkStatus _statusOf(GalleryItem item) => switch (item) {
    SingleArtworkItem(:final artwork) => artwork.status,
    BookItem() => item.status,
  };

  List<GalleryItem> _visible(List<GalleryItem> all) => switch (_filter) {
    _Filter.all => all,
    _Filter.inProgress =>
      all.where((i) => _statusOf(i) == ArtworkStatus.inProgress).toList(),
    _Filter.done =>
      all.where((i) => _statusOf(i) == ArtworkStatus.done).toList(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<GalleryCubit, GalleryState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                _filters(),
                const SizedBox(height: 12),
                Expanded(child: _content(state)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.importUpload),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Импорт',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
    );
  }

  Widget _content(GalleryState state) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty) {
      return _emptyState();
    }
    final items = _visible(state.items);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 96),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.66,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _itemCard(items[i]),
    );
  }

  Widget _itemCard(GalleryItem item) {
    final cubit = context.read<GalleryCubit>();
    return switch (item) {
      SingleArtworkItem(:final artwork) => ArtworkCard(
        artwork: artwork,
        onTap: () => context.push(AppRoutes.coloringPath(artwork.id)),
        onLongPress: () => showItemActions(
          context,
          title: artwork.title,
          onRename: (t) => cubit.renameArtwork(artwork.id, t),
          onDelete: () => cubit.removeArtwork(artwork.id),
        ),
      ),
      BookItem() => BookCard(
        book: item,
        onTap: () => context.push(AppRoutes.bookPath(item.id)),
        onLongPress: () => showItemActions(
          context,
          title: item.title,
          deleteHint: 'Будут удалены все ${item.pageCount} стр. книги.',
          onRename: (t) => cubit.renameBook(item.id, t),
          onDelete: () => cubit.removeBook(item.id),
        ),
      ),
    };
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.palette_outlined,
                size: 46,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Пока нет работ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Импортируйте PDF-раскраску, чтобы начать',
              textAlign: TextAlign.center,
              // bodyLarge: 16 / 400.
              style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 12, 8),
      child: Row(
        children: [
          Text(
            'Мои работы',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _filters() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _chip('Все', _Filter.all),
          const SizedBox(width: 8),
          _chip('В работе', _Filter.inProgress),
          const SizedBox(width: 8),
          _chip('Готово', _Filter.done),
        ],
      ),
    );
  }

  Widget _chip(String label, _Filter value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            color: selected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
