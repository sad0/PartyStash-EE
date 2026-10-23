"""The camp chest's encyclopedia: every item of the game, and the area names -> M_PSXCAT.lua (dev build).

    python build_gm_catalog.py          (reads the game this folder sits in: chitin.key, override, the French TLK)

PSXGM_ALL = { 'AMUL01', ... }  items with an icon and a name (gold left out), sorted.
PSXGM_AREAS = { AR2300 = 'Auberge de Brasamical', ... }  WORLDMAP.WMP area captions; an inner area (AR2301) takes
its outer area's name (AR2300) in M_PSXGM.lua. A release builds the same file at install time from the player's own
game and language (TODO in the installer).
"""
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GAME = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(GAME, 'BGBot', 'bot', 'data'))
import build_items  # noqa: E402  (KEY/BIF reader)

build_items.TYP.update({'WMP': 0x3f7, 'BAM': 0x3e8, 'ARE': 0x3f2, 'STO': 0x3f6, 'CRE': 0x3f1})


def res8(b):
    return b.split(b'\0')[0].decode('latin-1').upper()


MAX_FROM = 12  # origins kept per item
PER_KIND = 4   # and per kind (stores would fill the list of a common item)


def origins(g, tlk):
    """{ RES: ['S~store name~', 'G~~AR2600', 'C~~AR2600', 'K~creature name~AR2600', ...] } from the game files:
    the stores that sell it (STO, store / tavern / inn / temple), the areas' ground piles and containers (ARE),
    the creatures placed in the areas (ARE actors -> CRE inventory, undroppable items left out)."""
    out = {}

    def add(res, entry):
        res = res.upper()
        lst = out.setdefault(res, [])
        same = sum(1 for x in lst if x[0] == entry[0])
        if entry not in lst and same < PER_KIND and len(lst) < MAX_FROM:
            lst.append(entry)

    for n in g.names('STO'):
        d = g.get(n, 'STO')
        if not d or d[:4] != b'STOR' or len(d) < 0x9C:
            continue
        typ, name = struct.unpack_from('<Ii', d, 0x08)
        if typ > 3:
            continue
        nm = tlk(name)
        if not nm or len(nm) > 40:  # a few stores point at a dialogue line, not a name
            nm = n
        ioff, icnt = struct.unpack_from('<II', d, 0x34)
        for i in range(icnt):
            e = ioff + i * 0x1C
            if e + 0x1C > len(d):
                break
            stock, inf = struct.unpack_from('<II', d, e + 0x14)
            if stock > 0 or inf & 1:
                add(res8(d[e:e + 8]), 'S~%s~' % nm)
    cre_items = {}

    def cre(n):
        if n in cre_items:
            return cre_items[n]
        d = g.get(n, 'CRE')
        r = (None, [])
        if d and d[:8] == b'CRE V1.0' and len(d) > 0x2C4:
            name = tlk(struct.unpack_from('<i', d, 0x08)[0]) or tlk(struct.unpack_from('<i', d, 0x0C)[0])
            ioff, icnt = struct.unpack_from('<II', d, 0x2BC)
            its = []
            for i in range(icnt):
                e = ioff + i * 0x14
                if e + 0x14 > len(d):
                    break
                if not struct.unpack_from('<I', d, e + 0x10)[0] & 0x8:  # undroppable
                    its.append(res8(d[e:e + 8]))
            r = (name, its)
        cre_items[n] = r
        return r

    for n in g.names('ARE'):
        d = g.get(n, 'ARE')
        if not d or d[:8] != b'AREAV1.0' or len(d) < 0x11C:
            continue
        aoff, acnt = struct.unpack_from('<IH', d, 0x54)
        coff, ccnt, icnt, ioff = struct.unpack_from('<IHHI', d, 0x70)
        for c in range(ccnt):
            e = coff + c * 0xC0
            if e + 0xC0 > len(d):
                break
            ctype = struct.unpack_from('<H', d, e + 0x24)[0]
            first, cnt = struct.unpack_from('<II', d, e + 0x40)
            kind = 'G' if ctype == 4 else 'C'
            for i in range(first, first + cnt):
                ie = ioff + i * 0x14
                if ie + 0x14 > len(d):
                    break
                add(res8(d[ie:ie + 8]), '%s~~%s' % (kind, n))
        for a in range(acnt):
            e = aoff + a * 0x110
            if e + 0x110 > len(d):
                break
            name, its = cre(res8(d[e + 0x80:e + 0x88]))
            for r in its:
                add(r, 'K~%s~%s' % (name or '?', n))
    return out


def main():
    g = build_items.Game(GAME)
    tlk = build_items.TLK(os.path.join(GAME, 'lang', 'fr_FR', 'dialog.tlk'))
    items = []
    for n in g.names('ITM'):
        d = g.get(n, 'ITM')
        if not d or d[:4] != b'ITM ' or len(d) < 0x72:
            continue
        typ = struct.unpack_from('<H', d, 0x1C)[0]
        icon = res8(d[0x3A:0x42])
        idn, unid = struct.unpack_from('<ii', d, 0x0C)[0], struct.unpack_from('<i', d, 0x08)[0]
        name = tlk(idn) or tlk(unid)
        if typ == 33 or not icon or not name or g.get(icon, 'BAM') is None:
            continue
        items.append(n)
    areas = {}
    d = g.get('WORLDMAP', 'WMP')
    if d and d[:4] == b'WMAP':
        nmaps, moff = struct.unpack_from('<II', d, 8)
        for m in range(nmaps):
            mo = moff + m * 0xB8
            na, ao = struct.unpack_from('<II', d, mo + 0x20)
            for a in range(na):
                e = ao + a * 0xF0
                area = res8(d[e:e + 8])
                cap = struct.unpack_from('<i', d, e + 0x40)[0]
                nm = tlk(cap) or tlk(struct.unpack_from('<i', d, e + 0x44)[0])
                if area and nm and area not in areas:
                    areas[area] = nm
    frm = origins(g, tlk)
    q = lambda s: "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('\n', ' ') + "'"
    lines = ['-- Generated by build_gm_catalog.py: the camp chest encyclopedia (every item) and the area names.',
             'PSXGM_ALL = {']
    for i in range(0, len(items), 10):
        lines.append('\t' + ', '.join(q(x) for x in items[i:i + 10]) + ',')
    lines.append('}')
    lines.append('PSXGM_AREAS = {')
    for k in sorted(areas):
        lines.append('\t["%s"] = %s,' % (k, q(areas[k])))  # keys quoted: a resref may start with a digit
    lines.append('}')
    lines.append('-- Where each item comes from at the start of the game: kind~name~area entries joined by "|"')
    lines.append('-- (S a store that sells it, G on the ground, C in a container, K a creature that carries it).')
    lines.append('PSXGM_FROM = {')
    for k in sorted(frm):
        lines.append('\t["%s"] = %s,' % (k, q('|'.join(frm[k]))))
    lines.append('}')
    out = os.path.join(HERE, 'M_PSXCAT.lua')
    open(out, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')
    print(len(items), 'items,', len(areas), 'areas ->', out)


if __name__ == '__main__':
    main()
