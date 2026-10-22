"""README group titles as images (John 2026-10-22: gold titles; GitHub Markdown has no colours).

    python docs/titles/build_titles.py

Gold serif text, dark outline (readable on GitHub's light and dark themes), transparent background.
Writes docs/titles/<lang>_<n>.png from PartyStash's features_tr.py (english and french).
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, r"E:\SteamLibrary\steamapps\common\Baldur's Gate Enhanced Edition\PartyStash")
from features_tr import GROUPS  # noqa: E402

FONT = r'C:\Windows\Fonts\georgiab.ttf'
K = 3  # supersampling
SIZE = 26


def title(text, out):
    font = ImageFont.truetype(FONT, SIZE * K)
    probe = ImageDraw.Draw(Image.new('L', (1, 1)))
    l, t, r, b = probe.textbbox((0, 0), text, font=font)
    pad = 6 * K
    w, h = r - l + 2 * pad, b - t + 2 * pad
    mask = Image.new('L', (w, h), 0)
    ImageDraw.Draw(mask).text((pad - l, pad - t), text, font=font, fill=255)
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    outline = mask.filter(ImageFilter.MaxFilter(2 * K + 1))
    img.paste((40, 24, 6, 255), (0, 0), outline)
    grad = Image.new('RGB', (w, h))
    px = grad.load()
    for y in range(h):
        u = y / (h - 1)
        top, low = (255, 232, 150), (200, 150, 60)
        c = tuple(int(top[i] + (low[i] - top[i]) * u) for i in range(3))
        for x in range(w):
            px[x, y] = c
    img.paste(grad, (0, 0), mask)
    img = img.resize((w // K, h // K), Image.LANCZOS)
    img.save(out, optimize=True)


if __name__ == '__main__':
    for lang, code in (('english', 'en'), ('french', 'fr')):
        for n, (_emoji, text, _lines) in enumerate(GROUPS[lang][1], 1):
            title(text, os.path.join(HERE, '%s_%d.png' % (code, n)))
    print('ok')
