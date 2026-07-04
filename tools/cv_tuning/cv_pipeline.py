# -*- coding: utf-8 -*-
"""
Python-реплика пайплайна из local_cv_data_source.dart.
Запуск:  python3 cv_pipeline.py input.png output_prefix [--preset old|new]
Параметры совпадают с Dart-версией 1:1 (preset=old) либо откалиброваны (preset=new).
"""
import sys
import cv2
import numpy as np

def run_pipeline(img_bgr, *,
                 max_dim=1600,
                 min_area_fraction=0.0009,
                 min_area_abs=None,          # если задано — абсолютный порог в px (важно!)
                 block_size=25, C=8,          # adaptiveThreshold
                 close_kernel=3,              # MORPH_CLOSE
                 hole_fill_factor=4,          # size <= minArea*factor
                 hole_fill_abs=None,          # если задано — абсолютный порог дырок
                 line_dilate=0,               # утолщение линий после CLOSE (px ядра)
                 expand_steps=0,              # вернуть закраску к краю тонкой линии (px)
                 assign_orphans=False):       # приписывать отброшенные мелкие области соседям
    h0, w0 = img_bgr.shape[:2]

    # 2) downscale
    scale = min(1.0, max_dim / max(h0, w0))
    nw, nh = round(w0 * scale), round(h0 * scale)
    resized = cv2.resize(img_bgr, (nw, nh), interpolation=cv2.INTER_AREA) if scale < 1 else img_bgr.copy()

    # 3) grayscale
    gray = cv2.cvtColor(resized, cv2.COLOR_BGR2GRAY)

    # 4) CLAHE
    clahe = cv2.createCLAHE(clipLimit=2, tileGridSize=(8, 8))
    equalized = clahe.apply(gray)

    # 6a) денойз
    denoised = cv2.medianBlur(equalized, 3)

    # 6b) adaptive threshold: линии -> белые
    binary_inv = cv2.adaptiveThreshold(denoised, 255,
                                       cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                       cv2.THRESH_BINARY_INV, block_size, C)

    # 6c) closing линий
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (close_kernel, close_kernel))
    closed_lines = cv2.morphologyEx(binary_inv, cv2.MORPH_CLOSE, kernel)

    # 5+6c') display как в Dart: цвет + unsharp, затем затемнение СЕТКИ линий
    # (глифы — цифры/буквы — не трогаем; darken-only через minimum).
    blurred = cv2.GaussianBlur(resized, (0, 0), 3)
    display = cv2.addWeighted(resized, 1.6, blurred, -0.6, 0)

    gn, gl, gs, _gc = cv2.connectedComponentsWithStats(closed_lines, connectivity=8)
    glyph_max_area = round(nw * nh * 0.0004)
    glyph_max_side = max(nw, nh) // 60
    comp_side = np.maximum(gs[:, 2], gs[:, 3])
    is_glyph = (gs[:, 4] >= 10) & (gs[:, 4] <= glyph_max_area) & (comp_side <= glyph_max_side)
    is_line_comp = ~is_glyph
    is_line_comp[0] = False  # фон компонентов — не линия
    line_mask = (is_line_comp[gl]).astype(np.uint8) * 255
    # защита цветного контента (легенда, готовые мазки): чернила — только на
    # ахроматичные линии; цветной = S > 70 и V > 90, маску слегка расширяем
    hsv = cv2.cvtColor(display, cv2.COLOR_BGR2HSV)
    colored = ((hsv[:, :, 1] > 70) & (hsv[:, :, 2] > 90)).astype(np.uint8) * 255
    colored = cv2.dilate(colored, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3)))
    line_mask = cv2.bitwise_and(line_mask, cv2.bitwise_not(colored))
    alpha_soft = cv2.GaussianBlur(line_mask, (0, 0), 0.7)
    dark3 = cv2.cvtColor(cv2.bitwise_not(alpha_soft), cv2.COLOR_GRAY2BGR)
    display = np.minimum(display, dark3)

    # 6d) опционально: утолщение линий — герметизирует "щели" на перекрёстках
    thin_lines = closed_lines  # маска линий ДО утолщения (для expand_steps)
    if line_dilate:
        dk = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (line_dilate, line_dilate))
        closed_lines = cv2.dilate(closed_lines, dk)

    # 7) инверсия -> внутренности = 255
    interiors = cv2.bitwise_not(closed_lines)

    # 8) connected components
    count, labels, stats, centroids = cv2.connectedComponentsWithStats(interiors, connectivity=8)

    total = nw * nh
    min_area = min_area_abs if min_area_abs is not None else round(total * min_area_fraction)

    # фон: крупнейший компонент, касающийся границы
    bg_label, bg_area = -1, -1
    for i in range(1, count):
        x, y, w, h, a = stats[i]
        touches = x == 0 or y == 0 or x + w >= nw or y + h >= nh
        if touches and a > bg_area:
            bg_area, bg_label = a, i

    # перенумерация
    remap = np.zeros(count, dtype=np.int32)
    regions = []
    dropped = []
    nxt = 1
    for i in range(1, count):
        if i == bg_label:
            continue
        if stats[i][4] < min_area:
            dropped.append(int(stats[i][4]))
            continue
        remap[i] = nxt
        regions.append(dict(id=nxt, area=int(stats[i][4]),
                            bbox=stats[i][:4].tolist(),
                            centroid=centroids[i].tolist()))
        nxt += 1

    region_map = remap[labels]
    is_bg = (labels == bg_label)

    # ---- fillHoles: тёмные компоненты, окружённые одним регионом ----
    dark = cv2.bitwise_not(interiors)
    d_count, d_labels = cv2.connectedComponents(dark, connectivity=8)

    # соседний регион каждого тёмного компонента (векторно, вместо цикла по пикселям)
    neighbour = np.full(d_count, -2, dtype=np.int64)  # -2 не задан, -1 конфликт
    d_sizes = np.bincount(d_labels.ravel(), minlength=d_count)

    def note(comp_ids, reg_ids):
        mask = reg_ids > 0
        comp_ids, reg_ids = comp_ids[mask], reg_ids[mask]
        for c, r in zip(comp_ids, reg_ids):
            cur = neighbour[c]
            if cur == -2:
                neighbour[c] = r
            elif cur != r:
                neighbour[c] = -1

    dm, rm = d_labels, region_map
    # пары (тёмный comp, сосед-регион) по 4 направлениям
    for (cs, rs) in [(dm[:, 1:],  rm[:, :-1]), (dm[:, :-1], rm[:, 1:]),
                     (dm[1:, :],  rm[:-1, :]), (dm[:-1, :], rm[1:, :])]:
        m = cs > 0
        pairs = np.unique(np.stack([cs[m], rs[m]]), axis=1)
        note(pairs[0], pairs[1])

    fillable = np.zeros(d_count, dtype=bool)
    for c in range(1, d_count):
        hole_limit = hole_fill_abs if hole_fill_abs is not None else min_area * hole_fill_factor
        if neighbour[c] > 0 and d_sizes[c] <= hole_limit:
            fillable[c] = True
    fill_mask = fillable[d_labels] & (region_map == 0)
    region_map[fill_mask] = neighbour[d_labels[fill_mask]]

    # ---- опционально: не выбрасывать мелкие области, а вливать в соседа ----
    orphans_px = 0
    if assign_orphans:
        orphan = (interiors > 0) & (region_map == 0) & (~is_bg)
        orphans_px = int(orphan.sum())
        if orphans_px:
            # приписываем каждый "сиротский" пиксель ближайшему региону.
            # Евклидово "ближайший" ≈ Dart-версии (_assignOrphans): там BFS,
            # который тоже проходит сквозь линии, но не красит их; фон там
            # блокирован, здесь он кандидатом не является (lut только регионы).
            known = region_map > 0
            dist, idx_lbl = cv2.distanceTransformWithLabels(
                (~known).astype(np.uint8), cv2.DIST_L2, 3,
                labelType=cv2.DIST_LABEL_PIXEL)
            # DIST_LABEL_PIXEL: метка = индекс ближайшего нулевого (known) пикселя
            flat_known = np.flatnonzero(known.ravel())
            lut = region_map.ravel()[flat_known]  # label -> region id
            nearest_region = lut[idx_lbl - 1]
            region_map[orphan] = nearest_region[orphan]

    # ---- компенсация утолщения: расширяем регионы до края тонкой линии ----
    if expand_steps:
        allowed = thin_lines == 0
        for _ in range(expand_steps):
            grew = False
            for (dst, src) in [(np.s_[:, 1:], np.s_[:, :-1]),
                               (np.s_[:, :-1], np.s_[:, 1:]),
                               (np.s_[1:, :], np.s_[:-1, :]),
                               (np.s_[:-1, :], np.s_[1:, :])]:
                m = (region_map[dst] == 0) & allowed[dst] & (region_map[src] > 0)
                if m.any():
                    region_map[dst][m] = region_map[src][m]
                    grew = True
            if not grew:
                break

    dead = int(((interiors > 0) & (region_map == 0) & (~is_bg)).sum())
    return dict(nw=nw, nh=nh, region_map=region_map, regions=regions, is_bg=is_bg,
                interiors=interiors, display=display,  # цвет + затемнённые линии, как в Dart
                closed_lines=closed_lines,  # маска линий — для поиска разрывов
                stats=dict(cc_total=count - 1, kept=len(regions),
                           dropped=len(dropped),
                           dropped_areas=sorted(dropped, reverse=True)[:8],
                           top_kept=sorted([r['area'] for r in regions], reverse=True)[:8],
                           min_area=min_area, bg_area=bg_area,
                           dead_pixels=dead, orphans_fixed=orphans_px,
                           dead_pct=round(100 * dead / total, 2)))


def visualize(res, out_prefix):
    rm = res["region_map"]
    nreg = len(res["regions"])
    rng = np.random.RandomState(42)
    palette = np.zeros((nreg + 1, 3), np.uint8)
    palette[1:] = rng.randint(60, 255, (nreg, 3))
    color = palette[np.clip(rm, 0, nreg)]

    # мёртвые зоны (внутренность есть, региона нет) — ярко-красным
    dead = (res["interiors"] > 0) & (rm == 0) & (~res["is_bg"])
    color[dead] = (0, 0, 255)
    # линии (не внутренность, не регион) — чёрным
    lines = (res["interiors"] == 0) & (rm == 0)
    color[lines] = (0, 0, 0)

    cv2.imwrite(f"{out_prefix}_regions.png", color)

    disp = res["display"]
    if disp.ndim == 2:
        disp = cv2.cvtColor(disp, cv2.COLOR_GRAY2BGR)
    overlay = cv2.addWeighted(disp, 0.55, color, 0.45, 0)
    cv2.imwrite(f"{out_prefix}_overlay.png", overlay)

    # маска линий после closing: белое = линия; разрыв в линии = протечка
    cv2.imwrite(f"{out_prefix}_lines.png", res["closed_lines"])


if __name__ == "__main__":
    src, prefix = sys.argv[1], sys.argv[2]
    preset = sys.argv[3] if len(sys.argv) > 3 else "old"
    img = cv2.imread(src)
    if preset == "old":
        res = run_pipeline(img)
    elif preset == "new":
        res = run_pipeline(img, min_area_abs=40, hole_fill_abs=2500,
                           assign_orphans=True)
    elif preset == "new2400":
        # соответствует текущему Dart-коду приложения
        res = run_pipeline(img, max_dim=2400, min_area_abs=60,
                           hole_fill_abs=3500, assign_orphans=True,
                           block_size=37, C=5, close_kernel=5, line_dilate=3,
                           expand_steps=2)
    print(prefix, preset, res["stats"])
    visualize(res, f"{prefix}_{preset}")
