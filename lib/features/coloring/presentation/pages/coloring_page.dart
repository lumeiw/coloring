import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/coloring_cubit.dart';
import '../cubit/coloring_state.dart';
import '../engine/coloring_canvas.dart';
import '../widgets/color_picker_sheet.dart';

/// 3 — Экран раскрашивания. Этап 2: рабочий движок поверх мок-документа
/// (клиппинг мазка по маске региона, кисть-маркер, пипетка, undo/redo).
class ColoringPage extends StatelessWidget {
  const ColoringPage({super.key, required this.artworkId});

  final int artworkId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ColoringCubit>(
      create: (_) => getIt<ColoringCubit>()..load(artworkId),
      child: const _ColoringView(),
    );
  }
}

class _ColoringView extends StatefulWidget {
  const _ColoringView();

  @override
  State<_ColoringView> createState() => _ColoringViewState();
}

class _ColoringViewState extends State<_ColoringView> {
  /// Триггер «вписать в экран» для холста.
  final ValueNotifier<int> _resetSignal = ValueNotifier(0);

  @override
  void dispose() {
    _resetSignal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        child: BlocBuilder<ColoringCubit, ColoringState>(
          builder: (context, state) {
            if (state.loading || state.document == null) {
              return const Center(child: CircularProgressIndicator());
            }
            // Верхняя панель — на всю ширину; холст и нижняя панель на широких
            // экранах (iPad) держим колонкой по центру.
            return Column(
              children: [
                _TopBar(resetSignal: _resetSignal),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        children: [
                          Expanded(
                            child: ColoringCanvas(
                              document: state.document!,
                              resetSignal: _resetSignal,
                            ),
                          ),
                          const _BottomPanel(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ————— Верхняя панель —————
class _TopBar extends StatelessWidget {
  const _TopBar({required this.resetSignal});

  final ValueNotifier<int> resetSignal;

  /// Уходим назад, если есть куда; иначе (после импорта стек заменён на
  /// раскраску) — на галерею.
  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.gallery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ColoringCubit>();
    final state = context.watch<ColoringCubit>().state;

    return Container(
      height: 60,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _leave(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.undo),
            color: state.canUndo ? AppColors.onSurface : AppColors.outline,
            onPressed: state.canUndo ? cubit.undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            color: state.canRedo ? AppColors.onSurface : AppColors.outline,
            onPressed: state.canRedo ? cubit.redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: () => resetSignal.value++,
          ),
          // Режим: замок = только внутри контуров, открытый = где угодно.
          IconButton(
            tooltip: state.clipToRegion
                ? 'Только внутри контуров'
                : 'Рисовать где угодно',
            icon: Icon(
              state.clipToRegion ? Icons.lock_outline : Icons.lock_open,
              // В клип-режиме — как соседние иконки; в «где угодно» — акцент.
              color: state.clipToRegion ? null : AppColors.primary,
            ),
            onPressed: cubit.toggleClip,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilledButton(
              onPressed: () => _leave(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Готово'),
            ),
          ),
        ],
      ),
    );
  }
}

// ————— Нижняя панель инструментов —————
class _BottomPanel extends StatelessWidget {
  const _BottomPanel();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ColoringCubit>();
    final state = context.watch<ColoringCubit>().state;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F2C333D),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _selectedColorRow(context, cubit, state),
          const SizedBox(height: 14),
          _swatchStrip(cubit, state),
          const SizedBox(height: 12),
          // Размер кисти (без подписи — только иконка-слайдер).
          _slider(
            context,
            Icons.line_weight,
            (state.brushSize - BrushLimits.minSize) /
                (BrushLimits.maxSize - BrushLimits.minSize),
            (v) => cubit.setBrushSize(
              BrushLimits.minSize +
                  v * (BrushLimits.maxSize - BrushLimits.minSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedColorRow(
    BuildContext context,
    ColoringCubit cubit,
    ColoringState state,
  ) {
    final index = state.paletteIndex;
    return Row(
      children: [
        // Тап по кружку открывает шит выбора цвета (легенда + палитра + пипетка).
        GestureDetector(
          onTap: () => _openSheet(context, cubit),
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: state.color,
              shape: BoxShape.circle,
              boxShadow: [
                const BoxShadow(color: Colors.white, spreadRadius: 3),
                BoxShadow(color: AppColors.primary, spreadRadius: 5.5),
              ],
            ),
            child: Text(
              index >= 0 ? '${index + 1}' : '',
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 15,
                color: Color(0xFF3D5340),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                index >= 0 ? 'Цвет ${index + 1}' : 'Свой цвет',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _hex(state.color),
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        // Пипетка — переключает инструмент, тап по холсту берёт цвет.
        _squareButton(
          Icons.colorize,
          active: state.tool == ColoringTool.eyedropper,
          onTap: () => cubit.selectTool(
            state.tool == ColoringTool.eyedropper
                ? ColoringTool.brush
                : ColoringTool.eyedropper,
          ),
        ),
        const SizedBox(width: 12),
        _toolToggle(cubit, state),
      ],
    );
  }

  Widget _squareButton(
    IconData icon, {
    bool active = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 22,
          color: active ? Colors.white : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _toolToggle(ColoringCubit cubit, ColoringState state) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _toolButton(cubit, Icons.brush, ColoringTool.brush, state.tool),
          const SizedBox(width: 4),
          _toolButton(cubit, Icons.back_hand, ColoringTool.hand, state.tool),
        ],
      ),
    );
  }

  Widget _toolButton(
    ColoringCubit cubit,
    IconData icon,
    ColoringTool tool,
    ColoringTool current,
  ) {
    final active = current == tool;
    return GestureDetector(
      onTap: () => cubit.selectTool(tool),
      child: Container(
        width: 40,
        height: 36,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? Colors.white : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _swatchStrip(ColoringCubit cubit, ColoringState state) {
    // Высота с запасом под кольцо выделения; clipBehavior.none и отступы, чтобы
    // обводка не срезалась ни сверху/снизу, ни у крайних цветов.
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemCount: AppColors.palette.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final color = AppColors.palette[i];
          final selected = state.color == color;
          return Center(
            child: GestureDetector(
              onTap: () => cubit.selectColor(color),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: selected
                      ? [
                          const BoxShadow(
                            color: Colors.white,
                            spreadRadius: 2.5,
                          ),
                          BoxShadow(
                            color: AppColors.primary,
                            spreadRadius: 4.5,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _slider(
    BuildContext context,
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceContainerHigh,
              thumbColor: Colors.white,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(value: value.clamp(0.0, 1.0), onChanged: onChanged),
          ),
        ),
      ],
    );
  }

  Future<void> _openSheet(BuildContext context, ColoringCubit cubit) async {
    final picked = await ColorPickerSheet.show(
      context,
      selected: cubit.state.color,
    );
    if (picked != null) cubit.selectColor(picked);
  }

  static String _hex(Color c) {
    final argb = c.toARGB32();
    return '#${(argb & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';
  }
}
