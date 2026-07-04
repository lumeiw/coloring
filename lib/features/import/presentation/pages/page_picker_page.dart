import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/import_repository.dart';
import '../../domain/pdf_source.dart';

/// Выбор страниц из PDF: мультивыбор (несколько страниц = книга)
/// и название будущей работы/книги.
class PagePickerPage extends StatefulWidget {
  const PagePickerPage({super.key, required this.source});

  final ImportSource source;

  @override
  State<PagePickerPage> createState() => _PagePickerPageState();
}

class _PagePickerPageState extends State<PagePickerPage> {
  final _repo = getIt<ImportRepository>();
  final Set<int> _selected = {0};
  int _pageCount = 0;
  final Map<int, Uint8List> _thumbs = {};
  bool _loading = true;
  late final TextEditingController _title;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: _defaultTitle());
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  /// Имя файла без расширения — стартовое название.
  String _defaultTitle() {
    return widget.source.displayName.replaceAll(
      RegExp(r'\.(pdf|png|jpe?g|heic|webp)$', caseSensitive: false),
      '',
    );
  }

  Future<void> _load() async {
    final count = await _repo.pageCount(widget.source);
    if (!mounted) return;
    setState(() => _pageCount = count);
    for (var i = 0; i < count; i++) {
      final thumb = await _repo.pageThumbnail(widget.source, i);
      if (!mounted) return;
      setState(() => _thumbs[i] = thumb);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _toggle(int index) {
    setState(() {
      if (!_selected.add(index)) _selected.remove(index);
    });
  }

  void _submit() {
    final pages = _selected.toList()..sort();
    final title = _title.text.trim();
    context.push(
      AppRoutes.importProcessing,
      extra: (
        widget.source,
        pages,
        title.isEmpty ? _defaultTitle() : title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = _selected.length;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Выберите страницы'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _titleField(),
            Expanded(
              child: _pageCount == 0 && _loading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 180,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 3 / 4,
                          ),
                      itemCount: _pageCount,
                      itemBuilder: (context, i) => _pageTile(i),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: FilledButton.icon(
                onPressed: _pageCount == 0 || n == 0 ? null : _submit,
                icon: Icon(
                  n > 1 ? Icons.menu_book : Icons.auto_fix_high,
                  size: 22,
                ),
                label: Text(
                  // Первая выбранная страница книги — обложка (без раскраски).
                  n > 1
                      ? 'Книга: обложка + ${n - 1} стр.'
                      : 'Улучшить и открыть',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Название работы/книги + счётчик страниц файла.
  Widget _titleField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.drive_file_rename_outline,
                color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _title,
                maxLength: 120,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  isDense: true,
                  hintText: 'Название',
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              _pageCount == 0 ? '…' : '$_pageCount стр.',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageTile(int index) {
    final selected = _selected.contains(index);
    // При мультивыборе первая (наименьшая) выбранная страница — обложка книги.
    final isCover = selected &&
        _selected.length > 1 &&
        index == _selected.reduce((a, b) => a < b ? a : b);
    final thumb = _thumbs[index];
    return GestureDetector(
      onTap: () => _toggle(index),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.outline,
                  width: selected ? 2.5 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: thumb == null
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Image.memory(thumb, fit: BoxFit.cover),
              ),
            ),
          ),
          if (selected)
            Positioned(
              top: 8,
              right: 8,
              child: isCover
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Text(
                        'Обложка',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
            ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Стр. ${index + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
