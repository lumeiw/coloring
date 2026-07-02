import 'package:go_router/go_router.dart';

import '../../features/coloring/presentation/pages/coloring_page.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/import/domain/pdf_source.dart';
import '../../features/import/presentation/pages/import_processing_page.dart';
import '../../features/import/presentation/pages/import_upload_page.dart';
import '../../features/import/presentation/pages/page_picker_page.dart';
import 'app_routes.dart';

/// Конфигурация навигации приложения (go_router).
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.gallery,
    routes: [
      GoRoute(
        path: AppRoutes.gallery,
        name: AppRoutes.galleryName,
        builder: (context, state) => const GalleryPage(),
      ),
      GoRoute(
        path: AppRoutes.importUpload,
        name: AppRoutes.importUploadName,
        builder: (context, state) => const ImportUploadPage(),
      ),
      GoRoute(
        path: AppRoutes.importPages,
        name: AppRoutes.importPagesName,
        builder: (context, state) => PagePickerPage(
          source: state.extra as ImportSource? ??
              const PdfAssetSource('assets/sample/coloring_sample.pdf'),
        ),
      ),
      GoRoute(
        path: AppRoutes.importProcessing,
        name: AppRoutes.importProcessingName,
        builder: (context, state) {
          final args = state.extra as (ImportSource, int)?;
          return ImportProcessingPage(
            source: args?.$1 ??
                const PdfAssetSource('assets/sample/coloring_sample.pdf'),
            pageIndex: args?.$2 ?? 0,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.coloring,
        name: AppRoutes.coloringName,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ColoringPage(artworkId: id);
        },
      ),
    ],
  );
}
