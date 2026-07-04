import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/import_repository.dart';
import '../../domain/pdf_source.dart';

/// «Улучшаем изображение»: запускает CV-пайплайн по выбранным страницам
/// (одна — работа, несколько — книга) и по завершении открывает раскраску
/// первой страницы.
class ImportProcessingPage extends StatefulWidget {
  const ImportProcessingPage({
    super.key,
    required this.source,
    required this.pageIndexes,
    required this.title,
  });

  final ImportSource source;
  final List<int> pageIndexes;
  final String title;

  @override
  State<ImportProcessingPage> createState() => _ImportProcessingPageState();
}

class _ImportProcessingPageState extends State<ImportProcessingPage> {
  /// Шаги пайплайна из макета (соответствуют реальным этапам CV).
  static const _steps = [
    'Распознавание контуров',
    'Очистка шума и сглаживание',
    'Разметка областей по номерам',
  ];

  int _activeStep = 0;
  String? _error;

  /// Прогресс по страницам книги (0-based done / total). У книги первая
  /// выбранная страница — обложка, CV по ней не считается.
  int _pagesDone = 0;

  bool get _isBook => widget.pageIndexes.length > 1;

  int get _pagesTotal =>
      _isBook ? widget.pageIndexes.length - 1 : widget.pageIndexes.length;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // Псевдо-прогресс по шагам (реальный пайплайн атомарен в изоляте).
    _tickSteps();
    try {
      final id = await getIt<ImportRepository>().importPages(
        widget.source,
        widget.pageIndexes,
        title: widget.title,
        onPage: (done, total) {
          if (mounted) setState(() => _pagesDone = done);
        },
      );
      if (!mounted) return;
      // Книга — на главную (галерею); одиночная работа — сразу в раскраску.
      if (_isBook) {
        context.go(AppRoutes.gallery);
      } else {
        context.go(AppRoutes.coloringPath(id));
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _tickSteps() async {
    for (var i = 1; i < _steps.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted || _error != null) return;
      setState(() => _activeStep = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обработка')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _error != null ? _errorView() : _progressView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _progressView() {
    final book = _isBook;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 148,
          height: 148,
          child: CircularProgressIndicator(
            strokeWidth: 12,
            // Для книги — реальный прогресс по страницам, иначе — крутилка.
            value: book ? _pagesDone / _pagesTotal : null,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          book
              ? 'Страница ${(_pagesDone + 1).clamp(1, _pagesTotal)} из $_pagesTotal…'
              : 'Улучшаем изображение…',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          book
              ? 'Готовим книгу «${widget.title}»'
              : 'Готовим чистые контуры и области раскраски',
          textAlign: TextAlign.center,
          // bodyLarge: 16 / 400.
          style: const TextStyle(
            fontSize: 16,
            height: 1.45,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        for (var i = 0; i < _steps.length; i++) _stepRow(_steps[i], i),
      ],
    );
  }

  Widget _errorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 56, color: AppColors.muted),
        const SizedBox(height: 16),
        const Text(
          'Не удалось обработать',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.pop(),
          child: const Text('Назад'),
        ),
      ],
    );
  }

  Widget _stepRow(String label, int index) {
    final IconData icon;
    final Color color;
    final active = index == _activeStep;
    if (index < _activeStep) {
      icon = Icons.check_circle;
      color = AppColors.secondary;
    } else if (active) {
      icon = Icons.autorenew;
      color = AppColors.primary;
    } else {
      icon = Icons.radio_button_unchecked;
      color = AppColors.outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: active ? FontWeight.w800 : FontWeight.w700,
              color: index <= _activeStep
                  ? AppColors.onSurface
                  : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
