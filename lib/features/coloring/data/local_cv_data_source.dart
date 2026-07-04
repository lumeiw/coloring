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
  static const int _maxDim = 2400;

  /// Абсолютный порог площади (px): регион меньше — считается шумом и
  /// вливается в соседа (см. [_assignOrphans]), а не выбрасывается.
  static const int _minAreaPx = 60;

  /// Абсолютный порог (px) для заливки тёмных дырок (цифры/пустоты) внутри
  /// региона в [_fillHoles].
  static const int _holeFillPx = 3500;

  @override
  Future<CvResult> process(RasterPage page) {
    final palette = [for (final c in AppColors.palette) c.toARGB32()];
    final input = _CvInput(
      bgra: page.bgra,
      width: page.width,
      height: page.height,
      isBgra: page.isBgra,
      maxDim: _maxDim,
      minAreaPx: _minAreaPx,
      holeFillPx: _holeFillPx,
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
    required this.minAreaPx,
    required this.holeFillPx,
    required this.paletteArgb,
  });

  final Uint8List bgra;
  final int width;
  final int height;
  final bool isBgra;
  final int maxDim;
  final int minAreaPx;
  final int holeFillPx;
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

  // 3) Grayscale — только для алгоритма; display-версия остаётся цветной
  // (порядок каналов зависит от источника: PDF=BGRA, фото=RGBA).
  final gray = cv.cvtColor(
    resized,
    input.isBgra ? cv.COLOR_BGRA2GRAY : cv.COLOR_RGBA2GRAY,
  );

  // 4) CLAHE — выравнивание локального контраста (для бинаризации).
  final clahe = cv.createCLAHE(clipLimit: 2, tileGridSize: (8, 8));
  final equalized = clahe.apply(gray);
  clahe.dispose();
  gray.dispose();

  // 5) Display-версия (то, что видит пользователь): исходные цвета
  // сохраняются, поверх — мягкий unsharp mask. Оригинал (без обработок)
  // кодируем отдельно — для режима «показать оригинал».
  final displayBgr = cv.cvtColor(
    resized,
    input.isBgra ? cv.COLOR_BGRA2BGR : cv.COLOR_RGBA2BGR,
  );
  resized.dispose();
  final (_, originalPng) = cv.imencode('.png', displayBgr);
  final blurred = cv.gaussianBlur(displayBgr, (0, 0), 3);
  const amount = 0.6;
  final display = cv.addWeighted(displayBgr, 1 + amount, blurred, -amount, 0);
  displayBgr.dispose();
  blurred.dispose();
  // В PNG кодируем позже (шаг 6c'), после затемнения сетки линий на display.

  // 6a) Денойз перед порогом — убирает крапинки, стабильнее контуры.
  final denoised = cv.medianBlur(equalized, 3);
  equalized.dispose();

  // 6b) Adaptive threshold (binary, только для алгоритма): контуры → белые.
  // Параметры откалиброваны на реальных сканах (tools/cv_tuning): окно
  // масштабируется с разрешением (25 при 1600 → 37 при 2400), C=5 ловит
  // бледные тонкие линии, из-за которых соседние области сливались в одну.
  final maxWorkSide = nw > nh ? nw : nh;
  var blockSize = maxWorkSide ~/ 64;
  if (blockSize < 15) blockSize = 15;
  if (blockSize.isEven) blockSize += 1;
  final binaryInv = cv.adaptiveThreshold(
    denoised,
    255,
    cv.ADAPTIVE_THRESH_GAUSSIAN_C,
    cv.THRESH_BINARY_INV,
    blockSize,
    5,
  );
  denoised.dispose();

  // 6b') Разделяем глифы и линии ДО замыкания: close (6c) наводит «мостики»
  // между глифом и близкой линией и склеивает их в один компонент — такой
  // глиф не прошёл бы критерий «маленький изолированный» и заливался бы
  // чёрным пятном при затемнении (6c'). На binaryInv глифы ещё отдельные.
  final pgl = cv.Mat.empty();
  final pgs = cv.Mat.empty();
  final pgc = cv.Mat.empty();
  final pgn = cv.connectedComponentsWithStats(
    binaryInv,
    pgl,
    pgs,
    pgc,
    8,
    cv.MatType.CV_32S,
    cv.CCL_DEFAULT,
  );
  pgc.dispose();
  final glyphMaxArea = (nw * nh * 0.0004).round();
  final glyphMaxSide = (nw > nh ? nw : nh) ~/ 60;
  final isGlyphComp = Uint8List(pgn);
  for (var i = 1; i < pgn; i++) {
    final a = pgs.at<int>(i, 4);
    final w = pgs.at<int>(i, 2);
    final h = pgs.at<int>(i, 3);
    final side = w > h ? w : h;
    if (a >= 10 && a <= glyphMaxArea && side <= glyphMaxSide) {
      isGlyphComp[i] = 1;
    }
  }
  pgs.dispose();
  final pgMap = _readInt32(pgl, nw * nh);
  pgl.dispose();
  final glyphBytes = Uint8List(nw * nh);
  final lineTrueBytes = Uint8List(nw * nh);
  for (var p = 0; p < pgMap.length; p++) {
    final c = pgMap[p];
    if (c == 0) continue;
    if (isGlyphComp[c] == 1) {
      glyphBytes[p] = 255;
    } else {
      lineTrueBytes[p] = 255;
    }
  }
  // glyphMask — пиксели глифов; lineTrue — честные линии до замыкания.
  final glyphMask = cv.Mat.create(rows: nh, cols: nw, type: cv.MatType.CV_8UC1)
    ..data.setAll(0, glyphBytes);
  final lineTrue = cv.Mat.create(rows: nh, cols: nw, type: cv.MatType.CV_8UC1)
    ..data.setAll(0, lineTrueBytes);

  // 6c) Морфологическое замыкание — соединяет разрывы контуров, чтобы соседние
  // области не «сливались» и краска не протекала между ними. Ядро тоже
  // масштабируется (3 при 1600 → 5 при 2400).
  var closeK = maxWorkSide ~/ 480;
  if (closeK < 3) closeK = 3;
  if (closeK.isEven) closeK += 1;
  final kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (closeK, closeK));
  final closed = cv.morphologyEx(binaryInv, cv.MORPH_CLOSE, kernel);
  binaryInv.dispose();
  kernel.dispose();

  // 6c') Затемнение сетки линий на display. На бледных сканах бинарная маска
  // линий гораздо шире визуально тёмной части линии, поэтому краска,
  // останавливаясь у края маски, оставляла заметный белый зазор до линии.
  // Затемняем ТОЛЬКО сетку линий; глифы (найдены в 6b', до close) не трогаем.
  //
  // Защитная зона глифов: сам глиф + «мостики», которые close навёл между
  // глифом и соседней линией (радиус = ядру close).
  final protKernel =
      cv.getStructuringElement(cv.MORPH_ELLIPSE, (closeK, closeK));
  final glyphProtect = cv.dilate(glyphMask, protKernel);
  glyphMask.dispose();
  protKernel.dispose();

  // Чернила: честные линии (до close) ∪ (closed минус защитная зона глифов).
  // Так линия обводится вплотную к глифу, а глиф и мостики остаются бледными.
  final notProtect = cv.bitwiseNOT(glyphProtect);
  glyphProtect.dispose();
  final closedSafe = cv.bitwiseAND(closed, notProtect);
  notProtect.dispose();
  final inkMask = cv.bitwiseOR(lineTrue, closedSafe);
  lineTrue.dispose();
  closedSafe.dispose();

  // Защита цветного контента (легенда с образцами цветов, готовые цветные
  // мазки): чернилами обводим только ахроматичные линии. Цветной пиксель =
  // насыщенный (S > 70) и не почти-чёрный (V > 90); маску цветного слегка
  // расширяем, чтобы защитить антиалиасную кромку.
  final hsv = cv.cvtColor(display, cv.COLOR_BGR2HSV);
  final hsvCh = cv.split(hsv);
  hsv.dispose();
  final (_, satMask) = cv.threshold(hsvCh[1], 70, 255, cv.THRESH_BINARY);
  final (_, valMask) = cv.threshold(hsvCh[2], 90, 255, cv.THRESH_BINARY);
  hsvCh.dispose();
  final coloredRaw = cv.bitwiseAND(satMask, valMask);
  satMask.dispose();
  valMask.dispose();
  final protectKernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (3, 3));
  final colored = cv.dilate(coloredRaw, protectKernel);
  coloredRaw.dispose();
  protectKernel.dispose();
  final notColored = cv.bitwiseNOT(colored);
  colored.dispose();
  final lineMaskSafe = cv.bitwiseAND(inkMask, notColored);
  inkMask.dispose();
  notColored.dispose();

  // Мягкий край (антиалиасинг) → инверсия → darken-only наложение через
  // cv.min: линии уходят в чёрный, бумага и цветные фрагменты не меняются.
  final alphaSoft = cv.gaussianBlur(lineMaskSafe, (0, 0), 0.7);
  lineMaskSafe.dispose();
  final darkGray = cv.bitwiseNOT(alphaSoft);
  alphaSoft.dispose();
  final dark3 = cv.cvtColor(darkGray, cv.COLOR_GRAY2BGR);
  darkGray.dispose();

  final displayInked = cv.min(display, dark3);
  display.dispose();
  dark3.dispose();
  final (_, enhancedPng) = cv.imencode('.png', displayInked);
  displayInked.dispose();

  // 6d) Лёгкое утолщение линий (dilate 3×3): герметизирует волосяные щели на
  // перекрёстках ячеек — главный источник «слипания» двух соседних областей.
  // Регионы нарезаются по утолщённым линиям, но закраска потом возвращается
  // к краю НЕутолщённой линии (см. _expandToLines), чтобы не было белого
  // зазора между краской и контуром.
  final thinLineMask = Uint8List.fromList(closed.data); // линии до утолщения
  final dilateKernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (3, 3));
  final closedLines = cv.dilate(closed, dilateKernel);
  closed.dispose();
  dilateKernel.dispose();

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
    thinLineMask: thinLineMask,
    glyphMask: glyphBytes,
    enhancedPng: enhancedPng,
    originalPng: originalPng,
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
  required Uint8List thinLineMask,
  required Uint8List glyphMask,
  required Uint8List enhancedPng,
  required Uint8List originalPng,
}) {
  final total = nw * nh;
  final minArea = input.minAreaPx;

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

  _fillHoles(interiors, regionMap, nw, nh, input.holeFillPx);

  // Осиротевшие внутренние пиксели (обрезанные мелкие компоненты) вливаем в
  // ближайший регион, чтобы не оставалось «мёртвых зон», которые нельзя закрасить.
  _assignOrphans(regionMap, labelMap, bgLabel, nw, nh);

  // Возвращаем закраску к реальному краю линии: компенсация утолщения (6d),
  // иначе между краской и контуром остаётся белый зазор в 1–2 px.
  _expandToLines(regionMap, thinLineMask, nw, nh);

  // Цифры/буквы внутри областей должны закрашиваться: вливаем пиксели глифов
  // в примыкающий регион. _fillHoles покрывает только изолированные глифы,
  // а прилипшие к линиям (после close) оставались «дырками» в маске.
  _paintOverGlyphs(regionMap, glyphMask, nw, nh);

  return CvResult(
    enhancedPng: enhancedPng,
    originalPng: originalPng,
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
  int holeLimit,
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
    if (r > 0 && size[comp] <= holeLimit) {
      regionMap[p] = r;
    }
  }
}

/// Приписывает «осиротевшие» внутренние пиксели (обрезанные как шум мелкие
/// компоненты) ближайшему региону — многоисточниковый BFS от всех пикселей
/// регионов. Волна ПРОХОДИТ сквозь пиксели линий (labelMap == 0), но не
/// красит их: регион волны ведётся в отдельном массиве owner, а не в
/// regionMap. Поэтому замурованная в линиях микроячейка достаётся ближайшему
/// (по расстоянию волны) региону. Внешний фон (bgLabel) блокирован, чужие
/// регионы не перекрашиваются — протечек нет.
void _assignOrphans(
  Int32List regionMap,
  Int32List labelMap,
  int bgLabel,
  int nw,
  int nh,
) {
  final total = nw * nh;
  final owner = Int32List(total);
  final queue = Int32List(total);
  var head = 0;
  var tail = 0;
  for (var p = 0; p < total; p++) {
    if (regionMap[p] > 0) {
      owner[p] = regionMap[p];
      queue[tail++] = p;
    }
  }

  while (head < tail) {
    final p = queue[head++];
    final r = owner[p];
    final x = p % nw;
    final y = p ~/ nw;

    void visit(int q) {
      if (owner[q] != 0) return;
      final lbl = labelMap[q];
      if (lbl == bgLabel) return;
      if (regionMap[q] > 0) return;
      owner[q] = r;
      if (lbl != 0) regionMap[q] = r; // сирота — красим; линия — проходим
      queue[tail++] = q;
    }

    if (x > 0) visit(p - 1);
    if (x < nw - 1) visit(p + 1);
    if (y > 0) visit(p - nw);
    if (y < nh - 1) visit(p + nw);
  }
}

/// Компенсация утолщения линий (шаг 6d): регионы нарезаны по утолщённым
/// линиям, из-за чего маска закраски на 1–2 px «худее» настоящего контура.
/// Расширяем каждый регион назад — на пиксели, которые в НЕутолщённой маске
/// [thinLineMask] ещё не линия. Настоящие линии непроходимы, а глубина
/// ограничена [steps], поэтому протечка в соседний регион или фон исключена.
void _expandToLines(
  Int32List regionMap,
  Uint8List thinLineMask, // >0 = линия (до утолщения)
  int nw,
  int nh, {
  int steps = 2,
}) {
  final total = nw * nh;
  final px = <int>[];
  final ids = <int>[];
  for (var s = 0; s < steps; s++) {
    px.clear();
    ids.clear();
    for (var p = 0; p < total; p++) {
      if (regionMap[p] != 0 || thinLineMask[p] != 0) continue;
      final x = p % nw;
      var r = 0;
      if (x > 0) r = regionMap[p - 1];
      if (r <= 0 && x < nw - 1) r = regionMap[p + 1];
      if (r <= 0 && p >= nw) r = regionMap[p - nw];
      if (r <= 0 && p < total - nw) r = regionMap[p + nw];
      if (r > 0) {
        px.add(p);
        ids.add(r);
      }
    }
    if (px.isEmpty) break;
    // Применяем волну целиком после прохода, чтобы за одну итерацию регион
    // рос ровно на 1 px, а не «стрелял» вдоль направления сканирования.
    for (var i = 0; i < px.length; i++) {
      regionMap[px[i]] = ids[i];
    }
  }
}

/// Вливает пиксели глифов (цифры/буквы, маска из 6b' — ДО замыкания) в
/// примыкающий регион, чтобы их можно было закрашивать поверх. Многоисточниковый
/// BFS от пикселей регионов, волна ходит ТОЛЬКО по пикселям глифов — линии
/// остаются барьерами, протечки между регионами исключены.
void _paintOverGlyphs(
  Int32List regionMap,
  Uint8List glyphMask, // >0 = пиксель глифа
  int nw,
  int nh,
) {
  final total = nw * nh;
  final queue = Int32List(total);
  var head = 0;
  var tail = 0;
  for (var p = 0; p < total; p++) {
    if (regionMap[p] > 0) queue[tail++] = p;
  }

  while (head < tail) {
    final p = queue[head++];
    final r = regionMap[p];
    final x = p % nw;
    final y = p ~/ nw;

    void visit(int q) {
      if (regionMap[q] != 0 || glyphMask[q] == 0) return;
      regionMap[q] = r;
      queue[tail++] = q;
    }

    if (x > 0) visit(p - 1);
    if (x < nw - 1) visit(p + 1);
    if (y > 0) visit(p - nw);
    if (y < nh - 1) visit(p + nw);
  }
}

/// Копирует CV_32S Mat в самостоятельный Int32List (после освобождения матрицы).
Int32List _readInt32(cv.Mat mat, int length) {
  final bytes = mat.data;
  final view = bytes.buffer.asInt32List(bytes.offsetInBytes, length);
  return Int32List.fromList(view);
}
