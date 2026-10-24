"""The Codex encyclopedia (Decard's page): every item the player can come across, and the area names -> M_PSXCAT.lua
(dev build).

    python build_gm_catalog.py          (reads the game this folder sits in: chitin.key, override, the installed language's TLK)

PSXGM_ALL = { 'AMUL01', ... }  items with an icon and a name (gold left out) that obtainable() finds, sorted.
PSXGM_AREAS = { AR2300 = 'Auberge de Brasamical', ... }  WORLDMAP.WMP area captions; an inner area (AR2301) takes
its outer area's name (AR2300) in M_PSXGM.lua. A release builds the same file at install time from the player's own
game and language (TODO in the installer).
"""
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GAME = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(GAME, 'BGBot', 'bot', 'data'))
# fallback: a game without BGBot (e.g. the EET dev game) uses the Steam BGBot reader
sys.path.append(r"E:\SteamLibrary\steamapps\common\Baldur's Gate Enhanced Edition\BGBot\bot\data")
import build_items  # noqa: E402  (KEY/BIF reader)

build_items.TYP.update({'WMP': 0x3f7, 'BAM': 0x3e8, 'ARE': 0x3f2, 'STO': 0x3f6, 'CRE': 0x3f1, 'INI': 0x802})


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


# script actions (ACTION.IDS) that hand an item to the party / create a creature (its first CRE string)
ITEM_ACTIONS = {82, 140, 256, 363}  # CreateItem, GiveItemCreate, CreateItemGlobal, AddStoreItem
CRE_ACTIONS = {7, 227, 228, 231, 232, 233, 238, 246, 250, 252, 295, 323}  # CreateCreature* (all variants)
ITEM_RE = re.compile(rb'(?:GiveItemCreate|CreateItem|CreateItemGlobal|AddStoreItem)\s*\(([^)]*)\)', re.I)
CRE_RE = re.compile(rb'CreateCreature\w*\s*\(([^)]*)\)', re.I)
# 2DA tables of random treasure and starting gear (items), random spawns and NPC level versions (creatures)
ITEM_TABLES = ('RNDTRES', 'RNDTREAS', 'RNDSCROL', 'RNDEQUIP', 'RNDWEP', 'RNDMAGIC', '25STWEAP', 'MPSTWEAP', 'BDSTWEAP')
CRE_TABLES = ('SPAWNGRP', 'NPCLVLDS')
TOKEN_RE = re.compile(rb'[A-Za-z0-9_#!$-]{1,8}')


def obtainable(g, frm):
    """The items the player can come across in play (John 2026-10-24: the Codex lists only these): an origin of
    origins() (store, ground, container, placed creature), an item a script or a dialogue gives / creates / adds to a
    store, a random treasure or starting gear table, or a droppable item of a creature that a script, a dialogue, a
    spawn point, a rest encounter, a spawn INI or a spawn table creates."""
    items = set(n.upper() for n in g.names('ITM'))
    cres = set(n.upper() for n in g.names('CRE'))
    got = {}  # item -> how: 'found' (store, ground, container), 'carried' (placed creature), 'give' (script /
    # dialogue), 'table' (random treasure, starting gear), 'spawn' (a created creature carries it)
    spawned = set()

    def mark(res_set, how):
        for r in res_set:
            got.setdefault(r, set()).add(how)

    for r, lst in frm.items():
        mark({r}, 'found' if any(e[0] in 'SGC' for e in lst) else 'carried')

    def strings(b):
        return set(s.decode('latin-1').upper() for s in re.findall(rb'"([^"]{1,8})"', b))

    for n in g.names('BCS'):
        d = g.get(n, 'BCS') or b''
        for m in re.finditer(rb'AC\n(\d+)(.*?)AC\n', d, re.S):
            aid = int(m.group(1))
            if aid in ITEM_ACTIONS or aid in CRE_ACTIONS:
                s = strings(m.group(2).split(b'OB\n')[-1])  # the action's own strings come after its objects
                if aid in ITEM_ACTIONS:
                    mark(s & items, 'give')
                else:
                    spawned |= s & cres
    for n in g.names('DLG'):
        d = g.get(n, 'DLG') or b''
        for m in ITEM_RE.finditer(d):
            mark(strings(m.group(1)) & items, 'give')
        for m in CRE_RE.finditer(d):
            spawned |= strings(m.group(1)) & cres
    for n in g.names('2DA'):
        if n.upper() in ITEM_TABLES or n.upper() in CRE_TABLES:
            toks = set(t.decode('latin-1').upper() for t in TOKEN_RE.findall(g.get(n, '2DA') or b''))
            mark(toks & items, 'table')
            spawned |= toks & cres
    for n in g.names('INI'):
        toks = set(t.decode('latin-1').upper() for t in TOKEN_RE.findall(g.get(n, 'INI') or b''))
        spawned |= toks & cres
    for n in g.names('ARE'):
        d = g.get(n, 'ARE')
        if not d or d[:8] != b'AREAV1.0' or len(d) < 0x11C:
            continue
        soff, scnt = struct.unpack_from('<IH', d, 0x60)
        for s in range(scnt):
            e = soff + s * 0xC8
            if e + 0xC8 > len(d):
                break
            cnt = struct.unpack_from('<H', d, e + 0x74)[0]
            for k in range(min(cnt, 10)):
                spawned.add(res8(d[e + 0x24 + k * 8:e + 0x2C + k * 8]))
        roff = struct.unpack_from('<I', d, 0xC0)[0]
        if roff and roff + 0xE4 <= len(d):
            for k in range(10):
                spawned.add(res8(d[roff + 0x48 + k * 8:roff + 0x50 + k * 8]))
    for n in spawned & cres:
        d = g.get(n, 'CRE')
        if d and d[:8] == b'CRE V1.0' and len(d) > 0x2C4:
            ioff, icnt = struct.unpack_from('<II', d, 0x2BC)
            for i in range(icnt):
                e = ioff + i * 0x14
                if e + 0x14 > len(d):
                    break
                if not struct.unpack_from('<I', d, e + 0x10)[0] & 0x8:  # undroppable
                    mark({res8(d[e:e + 8])}, 'spawn')
    return got


def main():
    g = build_items.Game(GAME)
    lang = 'en_US'  # the installed language (weidu.conf lang_dir), like the installer's own build
    conf = os.path.join(GAME, 'weidu.conf')
    if os.path.exists(conf):
        m = re.search(r'lang_dir\s*=\s*(\w+)', open(conf, encoding='latin-1').read())
        lang = m.group(1) if m else lang
    tlk = build_items.TLK(os.path.join(GAME, 'lang', lang, 'dialog.tlk'))
    items = []
    droppable = {}  # ITM flag 0x4: a creature drops it, the party can drop it
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
        droppable[n.upper()] = struct.unpack_from('<I', d, 0x18)[0] & 0x4
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
    got = obtainable(g, frm)
    # an item only a creature carries must be droppable (ITM flag 0x4: no monster weapons, creature immunity rings...)
    keep = lambda n: n in got and (droppable[n] or bool(got[n] & {'found', 'give', 'table'}))
    left = [n for n in items if not keep(n.upper())]
    items = [n for n in items if keep(n.upper())]
    print(len(left), 'items left out (not obtainable), e.g.', ', '.join(sorted(left)[:40]))
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
