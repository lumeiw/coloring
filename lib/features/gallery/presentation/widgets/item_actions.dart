import 'package:flutter/material.dart';

import '../../../../core/widgets/app_dialogs.dart';

/// Нижнее меню действий над элементом галереи: переименовать / удалить.
/// Вызывается длинным нажатием по карточке (работы, книги или страницы книги).
Future<void> showItemActions(
  BuildContext context, {
  required String title,
  required Future<void> Function(String newTitle) onRename,
  required Future<void> Function() onDelete,
  String? deleteHint,
}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 6),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text('Переименовать'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final newTitle = await showTitleInputDialog(
                context,
                title: 'Переименовать',
                initial: title,
              );
              if (newTitle != null && newTitle != title) {
                await onRename(newTitle);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text(
              'Удалить',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final ok = await showDeleteConfirmDialog(
                context,
                title: title,
                hint: deleteHint,
              );
              if (ok == true) await onDelete();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
