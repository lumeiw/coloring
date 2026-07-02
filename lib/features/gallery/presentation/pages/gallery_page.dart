import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/domain/artwork.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/gallery_cubit.dart';
import '../widgets/artwork_card.dart';

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

  List<Artwork> _visible(List<Artwork> all) => switch (_filter) {
    _Filter.all => all,
    _Filter.inProgress =>
      all.where((a) => a.status == ArtworkStatus.inProgress).toList(),
    _Filter.done => all.where((a) => a.status == ArtworkStatus.done).toList(),
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
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
    );
  }

  Widget _content(GalleryState state) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.artworks.isEmpty) {
      return _emptyState();
    }
    final items = _visible(state.artworks);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 96),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 0.66,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final art = items[i];
        return ArtworkCard(
          artwork: art,
          onTap: () => context.push(AppRoutes.coloringPath(art.id)),
        );
      },
    );
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
              style: TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant),
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
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _filters() {
    return SizedBox(
      height: 52,
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
          borderRadius: BorderRadius.circular(14),
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
