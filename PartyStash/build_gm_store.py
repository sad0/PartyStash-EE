"""Builds PSXCAMP.STO: the camp merchant's store (empty; M_PSXGM.lua fills it in game).

    python build_gm_store.py           -> PSXCAMP.STO

STO V1.0: type 0 (store), flags = buy | sell, sell markup 300 % (M_PSXGM.lua switches it to each item's
best markup seen while buying through the page; the vanilla view, used to sell, must not be a cheaper way to buy), buy markup 50 %, the item types it buys from the party (everything but quest
categories: keys, gold, books, notes...). Name strref -1: the installer sets it (SAY NAME), the page has its own title.
"""
import os
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'PSXCAMP.STO')

BUYS = [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
        32, 34, 35, 41, 44, 47, 49, 53, 57, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 72, 73]
HEADER = 0x9C


def build(name_strref=-1):
    flags = 0x1 | 0x2
    buys = b''.join(struct.pack('<I', t) for t in BUYS)
    h = bytearray(HEADER)
    h[0:8] = b'STORV1.0'
    struct.pack_into('<IiI', h, 0x08, 0, name_strref, flags)
    struct.pack_into('<III', h, 0x14, 300, 50, 0)       # sell markup, buy markup, depreciation
    struct.pack_into('<HH', h, 0x20, 0, 0)              # steal failure, capacity (0 = no limit)
    struct.pack_into('<II', h, 0x2C, HEADER, len(BUYS))  # purchased types
    struct.pack_into('<II', h, 0x34, HEADER + len(buys), 0)  # items
    struct.pack_into('<II', h, 0x3C, 0, 0)              # lore, identify price
    struct.pack_into('<II', h, 0x4C, HEADER + len(buys), 0)  # drinks
    struct.pack_into('<II', h, 0x70, HEADER + len(buys), 0)  # cures
    return bytes(h) + buys


if __name__ == '__main__':
    with open(OUT, 'wb') as f:
        f.write(build())
    print('written', OUT)
