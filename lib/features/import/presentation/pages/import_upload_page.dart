import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/pdf_source.dart';

/// 1a — Загрузка PDF: выбор файла с устройства (или встроенный образец).
class ImportUploadPage extends StatelessWidget {
  const ImportUploadPage({super.key});

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final file = result?.files.singleOrNull;
    if (file?.path == null || !context.mounted) return;
    context.push(
      AppRoutes.importPages,
      extra: PdfFileSource(file!.path!, name: file.name),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    final file = result?.files.singleOrNull;
    if (file?.path == null || !context.mounted) return;
    // У изображения одна «страница» — сразу на обработку.
    context.push(
      AppRoutes.importProcessing,
      extra: (ImageFileSource(file!.path!, name: file.name), 0),
    );
  }

  void _openSample(BuildContext context) {
    context.push(
      AppRoutes.importPages,
      extra: const PdfAssetSource('assets/sample/coloring_sample.pdf'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Импорт'),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Expanded(child: DottedZone(onPick: () => _pickFile(context))),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _pickFile(context),
                    icon: const Icon(Icons.folder_open, size: 22),
                    label: const Text('Выбрать PDF'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(context),
                    icon: const Icon(Icons.photo_library_outlined, size: 22),
                    label: const Text('Из фото'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _openSample(context),
                    child: const Text('Открыть образец'),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: AppColors.muted),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Обработка локально, без интернета',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Пунктирная зона «перетащите файл сюда».
class DottedZone extends StatelessWidget {
  const DottedZone({super.key, this.onPick});

  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFC3CCDA), width: 2),
        ),
        child: Center(
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
                  Icons.picture_as_pdf,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Добавьте PDF-раскраску',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Выберите PDF на устройстве',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
