import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:injectable/injectable.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../../../core/theme/app_colors.dart';
import '../domain/entities/cv_result.dart';
import '../domain/entities/raster_page.dart';
import '../domain/entities/region.dart';
import '../domain/repositories/cv_repository.dart';

/// Локальная (офлайн) реализация CV: весь пайплайн крутится в изоляте через
/// [Isolate.run], чтобы не фризить UI. Все матрицы OpenCV освобождаются.
@LazySingleton(as: CvRepository)
class LocalCvDataSource implements CvRepository {
  /// Максимальная сторона рабочего изображения (баланс детализация/память).
  static const int _maxDim = 1600;

  /// Минимальная доля площади, ниже которой регион считается шумом.
  /// Чуть выше — меньше «мусорных» микро-областей и ниже расход памяти.
  static const double _minAreaFraction = 0.0009;

  @override
  Future<CvResult> process(RasterPage page) {
    final palette = [for (final c in AppColors.palette) c.toARGB32()];
    final input = _CvInput(
      bgra: page.bgra,
      width: page.width,
      height: page.height,
      isBgra: page.isBgra,
      maxDim: _maxDim,
      minAreaFraction: _minAreaFraction,
      paletteArgb: palette,
    );
    // Тяжёлые вычисления — в отдельном изоляте.
    return Isolate.run(() => _runPipeline(input));
  }
}

/// Вход пайплайна (переносимые между изолятами данные).
class _CvInput {
  const _CvInput({
    required this.bgra,
    required this.width,
    required this.height,
    required this.isBgra,
    required this.maxDim,
    required this.minAreaFraction,
    required this.paletteArgb,
  });

  final Uint8List bgra;
  final int width;
  final int height;
  final bool isBgra;
  final int maxDim;
  final double minAreaFraction;
  final List<int> paletteArgb;
}

/// Полный CV-пайплайн (выполняется в изоляте).
CvResult _runPipeline(_CvInput input) {
  // 1) BGRA-байты → Mat.
  final src = cv.Mat.create(
    rows: input.height,
    cols: input.width,
    type: cv.MatType.CV_8UC4,
  );
  src.data.setAll(0, input.bgra);

  // 2) Downscale под лимит памяти.
  final maxSide = input.width > input.height ? input.width : input.height;
  final scale = maxSide > input.maxDim ? input.maxDim / maxSide : 1.0;
  final nw = (input.width * scale).round();
  final nh = (input.height * scale).round();
  final resized = scale < 1.0
      ? cv.resize(src, (nw, nh), interpolation: cv.INTER_AREA)
      : src.clone();
  src.dispose();

  // 3) Grayscale (порядок каналов зависит от источника: PDF=BGRA, фото=RGBA).
  final gray = cv.cvtColor(
    resized,
    input.isBgra ? cv.COLOR_BGRA2GRAY : cv.COLOR_RGBA2GRAY,
  );
  resized.dispose();

  // 4) CLAHE — выравнивание локального контраста.
  final clahe = cv.createCLAHE(clipLimit: 2, tileGridSize: (8, 8));
  final equalized = clahe.apply(gray);
  clahe.dispose();
  gray.dispose();

  // 5) Unsharp mask (display-версия, мягкая) — то, что видит пользователь.
  final blurred = cv.gaussianBlur(equalized, (0, 0), 3);
  const amount = 0.6;
  final display = cv.addWeighted(equalized, 1 + amount, blurred, -amount, 0);
  blurred.dispose();

  final (_, enhancedPng) = cv.imencode('.png', display);
  display.dispose();

  // 6a) Денойз перед порогом — убирает крапинки, стабильнее контуры.
  final denoised = cv.medianBlur(equalized, 3);
  equalized.dispose();

  // 6b) Adaptive threshold (binary, только для алгоритма): контуры → белые.
  final binaryInv = cv.adaptiveThreshold(
    denoised,
    255,
    cv.ADAPTIVE_THRESH_GAUSSIAN_C,
    cv.THRESH_BINARY_INV,
    25,
    8,
  );
  denoised.dispose();

  // 6c) Морфологическое замыкание — соединяет разрывы контуров, чтобы соседние
  // области не «сливались» и краска не протекала между ними.
  final kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (3, 3));
  final closedLines = cv.morphologyEx(binaryInv, cv.MORPH_CLOSE, kernel);
  binaryInv.dispose();
  kernel.dispose();

  // 7) Инверсия → внутренности областей становятся «передним планом» (255).
  final interiors = cv.bitwiseNOT(closedLines);
  closedLines.dispose();

  // 8) connectedComponents по внутренностям.
  final labels = cv.Mat.empty();
  final stats = cv.Mat.empty();
  final centroids = cv.Mat.empty();
  final count = cv.connectedComponentsWithStats(
    interiors,
    labels,
    stats,
    centroids,
    8,
    cv.MatType.CV_32S,
    cv.CCL_DEFAULT,
  );

  // Копируем буферы в Dart и освобождаем матрицы OpenCV.
  final labelMap = _readInt32(labels, nw * nh);
  final areas = <int>[for (var i = 0; i < count; i++) stats.at<int>(i, 4)];
  final bbox = <List<int>>[
    for (var i = 0; i < count; i++)
      [
        stats.at<int>(i, 0),
        stats.at<int>(i, 1),
        stats.at<int>(i, 2),
        stats.at<int>(i, 3),
      ],
  ];
  final cxs = <double>[for (var i = 0; i < count; i++) centroids.at<double>(i, 0)];
  final cys = <double>[for (var i = 0; i < count; i++) centroids.at<double>(i, 1)];

  labels.dispose();
  stats.dispose();
  centroids.dispose();

  final result = _labelRegions(
    input: input,
    nw: nw,
    nh: nh,
    ccCount: count,
    labelMap: labelMap,
    areas: areas,
    bbox: bbox,
    cxs: cxs,
    cys: cys,
    interiors: interiors,
    enhancedPng: enhancedPng,
  );
  interiors.dispose();
  return result;
}

/// Пост-обработка: выбор фонового компонента, отсев шума, заливка дырок
/// (цифры внутри областей), перенумерация регионов и сбор [CvResult].
CvResult _labelRegions({
  required _CvInput input,
  required int nw,
  required int nh,
  required int ccCount,
  required Int32List labelMap,
  required List<int> areas,
  required List<List<int>> bbox,
  required List<double> cxs,
  required List<double> cys,
  required cv.Mat interiors,
  required Uint8List enhancedPng,
}) {
  final total = nw * nh;
  final minArea = (total * input.minAreaFraction).round();

  // Внешний фон: наибольший по площади компонент, чей bbox касается границы.
  var bgLabel = -1;
  var bgArea = -1;
  for (var i = 1; i < ccCount; i++) {
    final b = bbox[i];
    final touches =
        b[0] == 0 || b[1] == 0 || b[0] + b[2] >= nw || b[1] + b[3] >= nh;
    if (touches && areas[i] > bgArea) {
      bgArea = areas[i];
      bgLabel = i;
    }
  }

  // Перенумерация валидных регионов в 1..M (фон и шум → 0).
  final remap = Int32List(ccCount);
  final regions = <Region>[];
  var next = 1;
  for (var i = 1; i < ccCount; i++) {
    if (i == bgLabel || areas[i] < minArea) continue;
    final id = next++;
    remap[i] = id;
    final b = bbox[i];
    final colorArgb = input.paletteArgb[(id - 1) % input.paletteArgb.length];
    regions.add(
      Region(
        id: id,
        bounds: Rect.fromLTWH(
          b[0].toDouble(),
          b[1].toDouble(),
          b[2].toDouble(),
          b[3].toDouble(),
        ),
        labelNumber: id,
        numberAnchor: Offset(cxs[i], cys[i]),
        suggestedColor: Color(colorArgb),
      ),
    );
  }

  // Применяем перенумерацию к карте.
  final regionMap = Int32List(total);
  for (var p = 0; p < total; p++) {
    regionMap[p] = remap[labelMap[p]];
  }

  _fillHoles(interiors, regionMap, nw, nh, minArea);

  return CvResult(
    enhancedPng: enhancedPng,
    width: nw,
    height: nh,
    labelMap: regionMap,
    regions: regions,
  );
}

/// Заливка дырок: тёмные компоненты (цифры/мелкие пустоты), полностью
/// окружённые одним регионом, вливаются в этот регион. Линии, разделяющие
/// два региона (или связанные с фоном), остаются нулём.
void _fillHoles(
  cv.Mat interiors,
  Int32List regionMap,
  int nw,
  int nh,
  int minArea,
) {
  // Тёмная маска = НЕ внутренности (линии + цифры), фон уже исключён (он белый).
  final dark = cv.Mat.empty();
  cv.bitwiseNOT(interiors, dst: dark);
  final dLabels = cv.Mat.empty();
  final dCount = cv.connectedComponents(
    dark,
    dLabels,
    8,
    cv.MatType.CV_32S,
    cv.CCL_DEFAULT,
  );
  final total = nw * nh;
  final dMap = _readInt32(dLabels, total);
  dark.dispose();
  dLabels.dispose();

  // Для каждого тёмного компонента собираем соседние регионы.
  final neighbourRegion = Int32List(dCount); // -2 не задан, -1 конфликт
  neighbourRegion.fillRange(0, dCount, -2);
  final size = Int32List(dCount);

  void note(int comp, int region) {
    if (region <= 0) return;
    final cur = neighbourRegion[comp];
    if (cur == -2) {
      neighbourRegion[comp] = region;
    } else if (cur != region) {
      neighbourRegion[comp] = -1; // граничит с несколькими регионами → линия
    }
  }

  for (var y = 0; y < nh; y++) {
    for (var x = 0; x < nw; x++) {
      final p = y * nw + x;
      final comp = dMap[p];
      if (comp == 0) continue;
      size[comp]++;
      if (x > 0) note(comp, regionMap[p - 1]);
      if (x < nw - 1) note(comp, regionMap[p + 1]);
      if (y > 0) note(comp, regionMap[p - nw]);
      if (y < nh - 1) note(comp, regionMap[p + nw]);
    }
  }

  // Заливаем только маленькие, окружённые одним регионом компоненты.
  for (var p = 0; p < total; p++) {
    final comp = dMap[p];
    if (comp == 0 || regionMap[p] != 0) continue;
    final r = neighbourRegion[comp];
    if (r > 0 && size[comp] <= minArea * 4) {
      regionMap[p] = r;
    }
  }
}

/// Копирует CV_32S Mat в самостоятельный Int32List (после освобождения матрицы).
Int32List _readInt32(cv.Mat mat, int length) {
  final bytes = mat.data;
  final view = bytes.buffer.asInt32List(bytes.offsetInBytes, length);
  return Int32List.fromList(view);
}
