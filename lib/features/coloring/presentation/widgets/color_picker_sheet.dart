import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Шит выбора цвета: цвета из легенды раскраски + общая палитра + пипетка.
/// Возвращает выбранный цвет через Navigator.pop.
class ColorPickerSheet extends StatelessWidget {
  const ColorPickerSheet({super.key, this.selected});

  final Color? selected;

  /// Цвета «из легенды» (пронумерованные области текущей раскраски).
  /// На этапе 3 приходят из результата CV-разметки.
  static const _legend = <Color>[
    Color(0xFFE8B4B8),
    Color(0xFFEBC79E),
    Color(0xFFA9BEDC),
    Color(0xFFB9CDA6),
    Color(0xFFC7B6D6),
    Color(0xFFA8C6C9),
  ];

  static Future<Color?> show(BuildContext context, {Color? selected}) {
    return showModalBottomSheet<Color>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x52232A34),
      builder: (_) => ColorPickerSheet(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Row(
            children: [
              const Text(
                'Выбор цвета',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 22,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionLabel('Из легенды раскраски'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < _legend.length; i++)
                _legendChip(context, _legend[i], i + 1),
            ],
          ),
          const SizedBox(height: 24),
          _sectionLabel('Палитра'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            children: [
              for (final c in AppColors.palette)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(c),
                  child: Container(
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _eyedropperRow(context),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        color: AppColors.muted,
      ),
    );
  }

  Widget _legendChip(BuildContext context, Color color, int number) {
    final isSelected = selected == color;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(color),
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2.5)
              : null,
        ),
        child: Text(
          '$number',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 16,
            color: _readableOn(color),
          ),
        ),
      ),
    );
  }

  Widget _eyedropperRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.colorize, color: AppColors.primary),
                SizedBox(width: 10),
                Text(
                  'Пипетка',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(selected),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.check, color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Контрастный цвет текста поверх пастельной заливки.
  static Color _readableOn(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.5
        ? const Color(0xFF3A3A3A)
        : Colors.white;
  }
}
