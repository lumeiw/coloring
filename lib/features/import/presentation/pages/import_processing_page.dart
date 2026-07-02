import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/import_repository.dart';
import '../../domain/pdf_source.dart';

/// 1c — «Улучшаем изображение»: реально запускает CV-пайплайн по выбранной
/// странице и по завершении открывает экран раскрашивания.
class ImportProcessingPage extends StatefulWidget {
  const ImportProcessingPage({
    super.key,
    required this.source,
    required this.pageIndex,
  });

  final ImportSource source;
  final int pageIndex;

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

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // Псевдо-прогресс по шагам (реальный пайплайн атомарен в изоляте).
    _tickSteps();
    try {
      final id = await getIt<ImportRepository>().importPage(
        widget.source,
        widget.pageIndex,
      );
      if (mounted) context.go(AppRoutes.coloringPath(id));
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 148,
          height: 148,
          child: CircularProgressIndicator(
            strokeWidth: 12,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Улучшаем изображение…',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Готовим чистые контуры и области раскраски',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
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
