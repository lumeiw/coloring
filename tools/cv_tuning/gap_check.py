# -*- coding: utf-8 -*-
"""Реплика ТЕКУЩЕЙ Dart-версии (v2: dilate + orphans + expandToLines)
+ симуляция закраски + анализ белых зазоров + фикс (затемнение линий на display)."""
import cv2
import numpy as np

def replicate_v2(img_bgr, max_dim=2400, min_area=60, hole_px=3500):
    h0, w0 = img_bgr.shape[:2]
    s = min(1.0, max_dim / max(h0, w0))
    work = cv2.resize(img_bgr, None, fx=s, fy=s, interpolation=cv2.INTER_AREA) if s < 1 else img_bgr.copy()
    nh, nw = work.shape[:2]
    total = nw * nh

    gray = cv2.cvtColor(work, cv2.COLOR_BGR2GRAY)
    eq = cv2.createCLAHE(clipLimit=2, tileGridSize=(8, 8)).apply(gray)

    # display: цвет + unsharp (шаг 5 текущего кода)
    blur = cv2.GaussianBlur(work, (0, 0), 3)
    disp = cv2.addWeighted(work, 1.6, blur, -0.6, 0)

    den = cv2.medianBlur(eq, 3)
    ms = max(nw, nh)
    block = max(15, ms // 64);  block += (block % 2 == 0)
    binv = cv2.adaptiveThreshold(den, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                 cv2.THRESH_BINARY_INV, block, 5)
    ck = max(3, ms // 480);  ck += (ck % 2 == 0)
    closed = cv2.morphologyEx(binv, cv2.MORPH_CLOSE,
                              cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (ck, ck)))
    thin = closed.copy()                                   # линии ДО утолщения
    lines = cv2.dilate(closed, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3)))
    interiors = cv2.bitwise_not(lines)

    cnt, lbl, stats, cent = cv2.connectedComponentsWithStats(interiors, connectivity=8)
    bg, bga = -1, -1
    for i in range(1, cnt):
        x, y, w, h, a = stats[i]
        if (x == 0 or y == 0 or x + w >= nw or y + h >= nh) and a > bga:
            bg, bga = i, a
    remap = np.zeros(cnt, np.int32)
    nxt = 1
    for i in range(1, cnt):
        if i != bg and stats[i][4] >= min_area:
            remap[i] = nxt; nxt += 1
    rm = remap[lbl]

    # fillHoles (векторно)
    dark = cv2.bitwise_not(interiors)
    dc, dl = cv2.connectedComponents(dark, connectivity=8)
    dsz = np.bincount(dl.ravel(), minlength=dc)
    neigh = np.full(dc, -2, np.int64)
    for cs, rs in [(dl[:, 1:], rm[:, :-1]), (dl[:, :-1], rm[:, 1:]),
                   (dl[1:, :], rm[:-1, :]), (dl[:-1, :], rm[1:, :])]:
        m = (cs > 0) & (rs > 0)
        pairs = np.unique(np.stack([cs[m], rs[m]]), axis=1)
        for c, r in zip(pairs[0], pairs[1]):
            if neigh[c] == -2: neigh[c] = r
            elif neigh[c] != r: neigh[c] = -1
    fillable = (neigh > 0) & (dsz <= hole_px)
    fm = fillable[dl] & (rm == 0)
    rm[fm] = neigh[dl[fm]]

    # assignOrphans: сироты = rm==0 & lbl!=0 & lbl!=bg; растим регионы max-дилатацией
    orphan = (rm == 0) & (lbl != 0) & (lbl != bg)
    n_orph = int(orphan.sum())
    f = rm.astype(np.float32)
    for _ in range(64):
        if not orphan.any(): break
        d = cv2.dilate(f, np.ones((3, 3), np.uint8))
        upd = orphan & (d > 0)
        if not upd.any(): break
        f[upd] = d[upd]; orphan &= ~upd
    rm = f.astype(np.int32)

    # expandToLines: 2 волны на пиксели thin==0 & rm==0
    for _ in range(2):
        d = cv2.dilate(rm.astype(np.float32), np.ones((3, 3), np.uint8))
        upd = (rm == 0) & (thin == 0) & (d > 0)
        rm[upd] = d[upd].astype(np.int32)

    return dict(work=work, disp=disp, gray=gray, thin=thin, rm=rm,
                lbl=lbl, bg=bg, nreg=nxt - 1, orphans=n_orph, block=block, ck=ck)

def analyze_gap(res, tag):
    disp_g = cv2.cvtColor(res["disp"], cv2.COLOR_BGR2GRAY)
    rm, thin = res["rm"], res["thin"]
    near = cv2.dilate((rm > 0).astype(np.uint8), np.ones((7, 7), np.uint8)) > 0
    # видимый белый зазор: непокрашиваемо, визуально светло, рядом с краской
    gap = (rm == 0) & (disp_g > 170) & near
    # ширина бинарной линии vs визуально тёмной её части
    in_mask = thin > 0
    dark_core = in_mask & (res["gray"] < 128)
    ratio = in_mask.sum() / max(dark_core.sum(), 1)
    left = int(((rm == 0) & (thin == 0) & (res["lbl"] != res["bg"]) & (res["lbl"] != 0)).sum())
    print(f"{tag}: block={res['block']}, close={res['ck']}, регионов={res['nreg']}, сирот было={res['orphans']}")
    print(f"  бинарная линия шире видимой тёмной в x{ratio:.2f}")
    print(f"  БЕЛЫЙ ЗАЗОР: {int(gap.sum())} px рядом с краской  |  непокрытых внутренних: {left}")
    return gap

def fix_display(res, glyph_area_frac=0.0004, side_div=60, sigma=0.7):
    """Затемняем на display ТОЛЬКО сетку линий (глифы не трогаем)."""
    thin = res["thin"]; nh, nw = thin.shape
    n, lbl, stats, _ = cv2.connectedComponentsWithStats(thin, connectivity=8)
    max_a = int(nh * nw * glyph_area_frac); max_s = max(nh, nw) // side_div
    is_glyph = np.zeros(n, bool)
    for i in range(1, n):
        x, y, w, h, a = stats[i]
        is_glyph[i] = 10 <= a <= max_a and max(w, h) <= max_s
    line_mask = np.where((lbl > 0) & ~is_glyph[lbl], 255, 0).astype(np.uint8)
    alpha = cv2.GaussianBlur(line_mask, (0, 0), sigma)
    dark3 = cv2.cvtColor(cv2.bitwise_not(alpha), cv2.COLOR_GRAY2BGR)
    return cv2.min(res["disp"], dark3)     # darken-only: линии к чёрному, остальное нетронуто

def simulate(disp, rm, nreg):
    rng = np.random.RandomState(7)
    pal = np.zeros((nreg + 1, 3), np.uint8); pal[1:] = rng.randint(70, 230, (nreg, 3))
    out = disp.copy()
    out[rm > 0] = pal[np.clip(rm[rm > 0], 0, nreg)]
    return out

if __name__ == "__main__":
    for name, tag in [("page_21_1_.png", "complex"), ("simle.png", "simple")]:
        res = replicate_v2(cv2.imread(name))
        gap = analyze_gap(res, tag)
        sim_now = simulate(res["disp"], res["rm"], res["nreg"])
        disp_fx = fix_display(res)
        sim_fx = simulate(disp_fx, res["rm"], res["nreg"])
        res["disp"] = disp_fx
        print("  после фикса:", end=" ")
        analyze_gap(res, tag + "-fixed")
        cv2.imwrite(f"{tag}_sim_now.png", sim_now)
        cv2.imwrite(f"{tag}_sim_fixed.png", sim_fx)
        cv2.imwrite(f"{tag}_disp_fixed.png", disp_fx)
