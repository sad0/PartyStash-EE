"""Camp merchant page backgrounds: a wooden notice board with notices pinned on it (John 2026-10-23).

    python build_gm_board.py compose     -> gm/PSXGMBA.png  (assembled: board + papers placed on the page zones)
    python build_gm_board.py ai          -> gm/PSXGMBB.png  (the assembled one redrawn by SwarmUI img2img: same layout)
    python build_gm_board.py mos         -> ../PSXGMBA.MOS, ../PSXGMBB.MOS (build_art.to_mos)

Pieces (gm/nb_*.png) come from the local SwarmUI (Z-Image Turbo): board, three blank papers, a brass pin, an iron
nail, a wax seal, a twine knot (on black, keyed out here). ZONES follow build_gm_menu.py's geometry (864 x 710): each
notice sits under one part of the page (tree, item list, item card, quantity, Buy, sell / done, messages).
"""
import base64
import io
import json
import math
import os
import random
import sys
import urllib.parse
import urllib.request

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

HERE = os.path.dirname(os.path.abspath(__file__))
GM = os.path.join(HERE, 'gm')
W, H = 864, 710

# name: (x, y, w, h, paper, fixing, angle, style)  style: plain | dog (dog-eared corner) | torn
ZONES = {
    'tree':   (16, 46, 202, 620, 'paper1', 'pin', -0.6, 'dog'),
    'list':   (226, 10, 454, 516, 'paper2', 'nail', 0.0, 'plain'),
    'card':   (684, 26, 170, 264, 'paper3', 'wax', 0.8, 'torn'),
    'qty':    (690, 280, 156, 74, 'paper1', 'twine', -1.2, 'plain'),
    'buy':    (702, 354, 126, 96, 'paper2', 'pin', 1.0, 'dog'),
    'msg':    (232, 530, 440, 58, 'paper1', 'pin', -0.4, 'torn'),
    'done':   (682, 552, 170, 98, 'paper2', 'nail', -0.8, 'dog'),
}
TONE = {'paper1': (0.86, 0.78, 0.62), 'paper2': (0.92, 0.86, 0.72), 'paper3': (1.0, 0.97, 0.92)}


def load(name):
    return Image.open(os.path.join(GM, 'nb_%s.png' % name)).convert('RGB')


def board():
    b = load('board2')
    bw, bh = b.size
    m = 0.045  # keep only a thin strip of the frame
    b = b.crop((int(bw * m), int(bh * m * 1.1), int(bw * (1 - m)), int(bh * (1 - m * 1.1)))).resize((W, H), Image.LANCZOS)
    # older, darker wood: the papers must stand out and the game's light text must stay readable on the wood
    b = Image.blend(b, ImageOps.grayscale(b).convert('RGB'), 0.25)
    b = ImageChops.multiply(b, Image.new('RGB', (W, H), (150, 118, 92)))
    vign = Image.new('L', (W, H), 0)
    d = ImageDraw.Draw(vign)
    for i in range(60):
        d.rectangle((i, i, W - 1 - i, H - 1 - i), outline=int(255 * (1 - i / 60) * 0.55))
    return Image.composite(Image.new('RGB', (W, H), 'black'), b, vign.filter(ImageFilter.GaussianBlur(12)))


def keyed(name, size):
    """A piece shot on black, as RGBA (alpha from brightness), scaled to `size` px wide."""
    im = load(name)
    alpha = ImageOps.grayscale(im).point(lambda v: 0 if v < 18 else min(255, (v - 18) * 6))
    im.putalpha(alpha)
    im = im.crop(alpha.getbbox())
    r = size / im.width
    return im.resize((size, max(1, int(im.height * r))), Image.LANCZOS)


def edge_mask(w, h, style, rnd):
    m = Image.new('L', (w, h), 255)
    d = ImageDraw.Draw(m)
    if style == 'torn':  # ragged edges: a random walk along each side
        def walk(n):
            v, out = 2.0, []
            for _ in range(n):
                v = min(6.0, max(0.0, v + rnd.uniform(-1.2, 1.2)))
                out.append(int(v))
            return out
        for x, k in enumerate(walk(w)):
            d.line((x, 0, x, k), fill=0)
        for x, k in enumerate(walk(w)):
            d.line((x, h - 1 - k, x, h - 1), fill=0)
        for y, k in enumerate(walk(h)):
            d.line((0, y, k, y), fill=0)
        for y, k in enumerate(walk(h)):
            d.line((w - 1 - k, y, w - 1, y), fill=0)
    if style == 'dog':  # bottom-right corner folded away
        c = min(w, h) // 6
        d.polygon([(w - c, h), (w, h - c), (w, h)], fill=0)
    return m


def paper(z, rnd):
    x, y, w, h, kind, fixing, angle, style = z
    tex = load(kind)
    tw, th = tex.size
    # crop away the texture's own border (paper3 has burnt edges: keep them for the torn notice)
    inset = 0.0 if kind == 'paper3' else 0.06
    tex = tex.crop((int(tw * inset), int(th * inset), int(tw * (1 - inset)), int(th * (1 - inset))))
    tex = tex.resize((w, h), Image.LANCZOS)
    tex = ImageChops.multiply(tex, Image.new('RGB', (w, h), tuple(int(255 * t) for t in TONE[kind])))
    # faint creases (a light line over a darker one) and darker edges
    over = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(over)
    for _ in range(2 if h > 150 else 1):
        yy = rnd.randint(h // 4, h * 3 // 4)
        dy = rnd.randint(-2, 2)
        d.line((0, yy, w, yy + dy), fill=(90, 70, 40, 45), width=2)
        d.line((0, yy + 1, w, yy + 1 + dy), fill=(255, 245, 220, 50), width=1)
    tex = Image.alpha_composite(tex.convert('RGBA'), over).convert('RGB')
    edge = Image.new('L', (w, h), 0)
    de = ImageDraw.Draw(edge)
    for i in range(14):
        de.rectangle((i, i, w - 1 - i, h - 1 - i), outline=int(110 * (1 - i / 14)))
    tex = Image.composite(Image.new('RGB', (w, h), (95, 70, 40)), tex, edge.filter(ImageFilter.GaussianBlur(3)))
    mask = edge_mask(w, h, style, rnd)
    sheet = tex.convert('RGBA')
    sheet.putalpha(mask)
    if style == 'dog':  # the folded triangle, darker
        c = min(w, h) // 6
        fold = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        ImageDraw.Draw(fold).polygon([(w - c, h), (w, h - c), (w - c, h - c)], fill=(150, 128, 96, 255))
        sheet = Image.alpha_composite(sheet, fold)
    return sheet


def compose():
    rnd = random.Random(7)
    out = board().convert('RGBA')
    for name, z in ZONES.items():
        x, y, w, h, kind, fixing, angle, style = z
        sheet = paper(z, rnd)
        pad = 12
        layer = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
        layer.paste(sheet, (pad, pad), sheet)
        layer = layer.rotate(angle, resample=Image.BICUBIC)
        shadow = Image.new('RGBA', layer.size, (0, 0, 0, 0))
        shadow.putalpha(layer.getchannel('A').point(lambda a: a * 150 // 255).filter(ImageFilter.GaussianBlur(5)))
        out.alpha_composite(shadow, (x - pad + 4, y - pad + 5))
        out.alpha_composite(layer, (x - pad, y - pad))
        # fixings: centred at the top (wide notices get two)
        size = {'pin': 20, 'nail': 18, 'wax': 30, 'twine': 46}[fixing]
        piece = keyed(fixing, size)
        spots = [x + w // 2] if w < 300 else [x + 24, x + w - 24]
        for sx in spots:
            px, py = sx - piece.width // 2, y - piece.height // 2 + (6 if fixing != 'twine' else 2)
            sh = Image.new('RGBA', piece.size, (0, 0, 0, 0))
            sh.putalpha(piece.getchannel('A').point(lambda a: a * 170 // 255).filter(ImageFilter.GaussianBlur(2)))
            out.alpha_composite(sh, (px + 3, py + 3))
            out.alpha_composite(piece, (px, py))
    os.makedirs(GM, exist_ok=True)
    out.convert('RGB').save(os.path.join(GM, 'PSXGMBA.png'))
    print('written gm/PSXGMBA.png')


def ai(creativity=0.42, seed=5):
    api = 'http://localhost:7801/API/'

    def post(name, body):
        req = urllib.request.Request(api + name, json.dumps(body).encode(), {'Content-Type': 'application/json'})
        return json.loads(urllib.request.urlopen(req, timeout=900).read())

    src = Image.open(os.path.join(GM, 'PSXGMBA.png')).resize((1728, 1408), Image.LANCZOS)
    buf = io.BytesIO()
    src.save(buf, 'PNG')
    sid = post('GetNewSession', {})['session_id']
    r = post('GenerateText2Image', {
        'session_id': sid, 'images': 1, 'model': 'ZImage/SwarmUI_Z-Image-Turbo-FP8Mix', 'width': 1728, 'height': 1408,
        'steps': 8, 'cfgscale': 1, 'seed': seed,
        'prompt': 'front view of a rustic wooden tavern notice board covered with blank pinned parchment notices, a torn '
                  'wanted poster with a red wax seal, small paper tickets, brass pins, iron nails, twine, dog-eared '
                  'corners, stains, warm candle light, medieval fantasy, highly detailed painting',
        'negativeprompt': 'text, letters, writing, words, watermark, logo, people',
        'initimage': 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode(),
        'initimagecreativity': creativity})
    img = (r.get('images') or [None])[0]
    if not img:
        sys.exit('SwarmUI: %s' % r.get('error'))
    with urllib.request.urlopen('http://localhost:7801/' + urllib.parse.quote(img), timeout=120) as f:
        Image.open(io.BytesIO(f.read())).convert('RGB').resize((W, H), Image.LANCZOS).save(
            os.path.join(GM, 'PSXGMBB.png'))
    print('written gm/PSXGMBB.png')


def mos():
    sys.argv = sys.argv[:1]  # build_art reads argv[2] for the game
    import build_art
    for n in ('PSXGMBA', 'PSXGMBB'):
        build_art.to_mos(os.path.join(GM, n + '.png'), os.path.join(HERE, '..', n + '.MOS'))
        print('written', n + '.MOS')


if __name__ == '__main__':
    {'compose': compose, 'ai': ai, 'mos': mos}[sys.argv[1]]()
