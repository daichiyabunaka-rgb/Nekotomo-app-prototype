"""ニーアキャット配布用アプリアイコン（1024px）を作るスクリプト。
Pillow でフラットデザインのねこの顔を描く。生成物:
  - app/assets/icon/app_icon.png      （flutter_launcher_icons のソース）
"""
from PIL import Image, ImageDraw

SIZE = 1024
BG = (242, 231, 213)       # ベージュ（シリーズ共通の落ち着いた背景色）
HEAD = (232, 168, 124)     # 茶トラっぽいオレンジ
HEAD_DARK = (209, 138, 92)  # 頭の縞
INNER_EAR = (245, 202, 186)
MUZZLE = (250, 243, 233)
NOSE_BTN = (226, 138, 135)
EYE = (86, 66, 54)
WHISKER = (120, 104, 92)


def rounded(im: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", im.size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=radius, fill=255)
    out = Image.new("RGBA", im.size, (0, 0, 0, 0))
    out.paste(im, (0, 0), mask)
    return out


def draw_cat():
    im = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)

    # 背景（角丸ベージュ）
    d.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=192, fill=BG + (255,))

    # 耳（頭の後ろに描く）
    ear_w, ear_h = 190, 230
    head_cx, head_cy = SIZE // 2, 560
    head_r = 300
    for sx in (-1, 1):
        x0 = head_cx + sx * 150 - ear_w // 2
        y0 = head_cy - head_r - 30
        d.polygon([(x0, y0 + ear_h), (x0 + ear_w // 2, y0), (x0 + ear_w, y0 + ear_h)], fill=HEAD + (255,))
        d.polygon(
            [
                (x0 + ear_w * 0.24, y0 + ear_h * 0.9),
                (x0 + ear_w * 0.5, y0 + ear_h * 0.28),
                (x0 + ear_w * 0.76, y0 + ear_h * 0.9),
            ],
            fill=INNER_EAR + (255,),
        )

    # 頭
    d.ellipse(
        [head_cx - head_r, head_cy - head_r, head_cx + head_r, head_cy + head_r],
        fill=HEAD + (255,),
    )
    # 頭の縞（茶トラ）
    stripe_w = 34
    for i, off in enumerate((-86, 0, 86)):
        x = head_cx + off
        top = head_cy - head_r + 40 + (i == 1 and -14 or 0)
        d.rounded_rectangle([x - stripe_w // 2, top, x + stripe_w // 2, top + 150], radius=16, fill=HEAD_DARK + (255,))

    # マズル
    m_r = 175
    d.ellipse(
        [head_cx - m_r, head_cy - 20, head_cx + m_r, head_cy + 240],
        fill=MUZZLE + (255,),
    )

    # 目（閉じ目の弧: 穏やかな表情）
    eye_w, eye_h = 90, 60
    for sx in (-1, 1):
        cx = head_cx + sx * 118
        cy = head_cy + 40
        d.arc([cx - eye_w // 2, cy - eye_h // 2, cx + eye_w // 2, cy + eye_h // 2], start=20, end=160, fill=EYE + (255,), width=14)

    # 鼻
    nose_w = 44
    d.polygon(
        [
            (head_cx - nose_w // 2, head_cy + 92),
            (head_cx + nose_w // 2, head_cy + 92),
            (head_cx, head_cy + 92 + nose_w // 2),
        ],
        fill=NOSE_BTN + (255,),
    )
    # 口（ω型）
    d.arc([head_cx - 60, head_cy + 96, head_cx, head_cy + 156], start=0, end=90, fill=EYE + (255,), width=12)
    d.arc([head_cx, head_cy + 96, head_cx + 60, head_cy + 156], start=90, end=180, fill=EYE + (255,), width=12)

    # ひげ
    for sy in (-1, 0, 1):
        for sx in (-1, 1):
            y = head_cy + 120 + sy * 38
            x1 = head_cx + sx * (m_r + 14)
            x2 = head_cx + sx * (m_r + 140)
            dy = -18 if sy == 0 else sy * 26
            d.line([(x1, y), (x2, y + dy)], fill=WHISKER + (255,), width=10)

    return im


if __name__ == "__main__":
    im = draw_cat()
    im = rounded(im, 192)
    out = r"..\app\assets\icon\app_icon.png"
    im.save(out)
    print("saved:", out)
