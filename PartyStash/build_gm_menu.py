"""Builds PSXGM.menu: the camp merchant page (M_PSXGM.lua), its tick menu and the "back" button.

    python build_gm_menu.py            -> PSXGM.menu

Geometry: 864 x 710 like the game's STORE_BUYSELL (centered), drawn over it (modal) while the camp store is open.
Left: category tree. Middle: search + filters, the 8 x 7 icon grid (54 px pitch, like the stash), pages.
Right: the selected item, quantity, Buy, party gold, "vanilla view" (to sell) and Done.
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'PSXGM.menu')

W, H = 864, 710
GX, GY, PITCH, CELL, COLS, ROWS = 236, 104, 54, 52, 8, 7
RX, RW = 684, 160  # right panel


def label(area, text=None, style='normal', align='left center', enabled=None, extra=''):
    out = ['\tlabel', '\t{']
    if enabled:
        out.append(f'\t\tenabled "{enabled}"')
    out.append('\t\tarea %d %d %d %d' % area)
    if text:
        out.append(f'\t\ttext lua "{text}"')
        out.append(f'\t\ttext style "{style}"')
        out.append(f'\t\ttext align {align}')
    if extra:
        out.append(extra)
    out.append('\t}')
    return '\n'.join(out)


def button(area, text=None, action=None, style='button', enabled=None, clickable=None, extra=''):
    out = ['\tbutton', '\t{']
    if enabled:
        out.append(f'\t\tenabled "{enabled}"')
    out.append('\t\tarea %d %d %d %d' % area)
    if text:
        out.append(f'\t\ttext lua "{text}"')
        out.append(f'\t\ttext style "{style}"')
        out.append('\t\ttext align center center')
    if clickable:
        out.append(f'\t\tclickable lua "{clickable}"')
    if action:
        out.append(f'\t\taction "{action}"')
    if extra:
        out.append(extra)
    out.append('\t}')
    return '\n'.join(out)


def frame(area, opacity=120):
    return label(area, extra=f'\t\trectangle 1\n\t\trectangle opacity {opacity}')


def page():
    items = []
    items.append(label((0, 0, W, H), extra='\t\trectangle 0\n\t\trectangle opacity 255'))
    items.append(label((0, 0, 0, 0), enabled='PSXGM_Tick()'))  # the tick also runs from the page itself
    items.append(label((0, 12, W, 40), "PSXGM_T('gm_title')", style='title', align='center center'))
    # category tree
    items.append(frame((16, 56, 208, 588)))
    items.append('''\tlist
\t{
\t\tcolumn
\t\t{
\t\t\twidth 100
\t\t\tlabel
\t\t\t{
\t\t\t\tarea 6 0 -1 -1
\t\t\t\ttext lua "PSXGM_TreeText(rowNumber)"
\t\t\t\ttext style "normal"
\t\t\t\ttext align left center
\t\t\t}
\t\t}
\t\tarea 20 60 200 580
\t\trowheight 26
\t\ttable "PSXGM.treeRows"
\t\tvar PSXGM_treeVar
\t\taction "PSXGM_TreeClick()"
\t}''')
    # search + filters + sort
    items.append('''\tedit
\t{
\t\tarea %d 60 196 32
\t\tvar PSXGM_search
\t\ttext style "edit"
\t\tmaxlines 1
\t\tfill 112 111 111 64
\t\taction "PSXGM.page = 1 return 1"
\t}''' % GX)
    items.append(label((GX + 6, 60, 190, 32), "PSXGM_T('gm_search') .. '...'", enabled="PSXGM_search == ''"))
    items.append(frame((GX + 202, 60, 112, 32)))
    items.append(button((GX + 202, 60, 112, 32), "PSXGM_FilterText('usable')", 'PSXGM_ToggleUsable()'))
    items.append(frame((GX + 318, 60, 114, 32)))
    items.append(button((GX + 318, 60, 114, 32), "PSXGM_FilterText('afford')", 'PSXGM_ToggleAfford()'))
    # grid
    items.append(label((GX, GY, COLS * PITCH, ROWS * PITCH), extra='\t\tactionScroll "PSXGM_Wheel()"'))
    for i in range(COLS * ROWS):
        x, y = GX + (i % COLS) * PITCH, GY + (i // COLS) * PITCH
        items.append(button((x, y, CELL, CELL), extra='\n'.join([
            '\t\tbam PSSLOT',
            f'\t\ticon lua "PSXGM_CellIcon({i})"',
            f'\t\ttint lua "PSXGM_CellTint({i})"',
            f'\t\tgreyscale lua "PSXGM_CellGrey({i})"',
            f'\t\tcount lua "PSXGM_CellCount({i})"',
            f'\t\ttooltip lua "PSXGM_CellTip({i})"',
            f'\t\taction "PSXGM_CellClick({i})"',
            f'\t\tactionAlt "PSXGM_CellDesc({i})"',
            '\t\tactionScroll "PSXGM_Wheel()"'])))
        items.append(label((x + 36, y + 1, 16, 18), "'*'", style='title', align='center center',
                           enabled=f'PSXGM_CellWished({i})'))
    py = GY + ROWS * PITCH + 6
    items.append(button((GX, py, 40, 30), "'<'", 'PSXGM_Page(-1)', style='title', clickable='PSXGM_CanPage(-1)'))
    items.append(label((GX + 40, py, 100, 30), 'PSXGM_PageText()', style='label', align='center center'))
    items.append(button((GX + 140, py, 40, 30), "'>'", 'PSXGM_Page(1)', style='title', clickable='PSXGM_CanPage(1)'))
    items.append(frame((GX + 190, py, 120, 30)))
    items.append(button((GX + 190, py, 120, 30), 'PSXGM_SortText()', 'PSXGM_NextSort()'))
    items.append(label((GX + 316, py, 116, 30), 'PSXGM_CountText()', align='right center'))
    items.append(label((GX, py + 40, COLS * PITCH, 60), 'PSXGM_MsgText()', style='label', align='left top'))
    # right panel: the selected item
    items.append(frame((RX - 4, 56, RW + 8, 588)))
    items.append(button((RX + (RW - CELL) // 2, GY, CELL, CELL), extra='\n'.join([
        '\t\tbam PSSLOT', '\t\ticon lua "PSXGM_SelIcon()"', '\t\tactionAlt "PSXGM_SelDesc()"'])))
    items.append(label((RX, GY + 60, RW, 64), 'PSXGM_SelName()', align='center top'))
    items.append(label((RX, GY + 128, RW, 48), 'PSXGM_SelInfo()', style='label', align='center top'))
    qy = GY + 184
    items.append(button((RX + 10, qy, 34, 30), "'-'", 'PSXGM_Qty(-1)', style='title'))
    items.append(label((RX + 44, qy, RW - 88, 30), 'PSXGM_QtyText()', style='label', align='center center'))
    items.append(button((RX + RW - 44, qy, 34, 30), "'+'", 'PSXGM_Qty(1)', style='title'))
    items.append(label((RX, qy + 34, RW, 30), 'PSXGM_TotalText()', style='label', align='center center'))
    items.append(frame((RX + 10, qy + 70, RW - 20, 40)))
    items.append(button((RX + 10, qy + 70, RW - 20, 40), "PSXGM_T('gm_buy')", 'PSXGM_BuySelected()',
                        clickable='PSXGM_CanBuy()'))
    items.append(label((RX, qy + 120, RW, 30), 'PSXGM_GoldText()', style='gold', align='center center'))
    items.append(frame((RX, 560, RW, 36)))
    items.append(button((RX, 560, RW, 36), "PSXGM_T('gm_vanilla')", 'PSXGM_Vanilla()'))
    items.append(frame((RX, 604, RW, 36)))
    items.append(button((RX, 604, RW, 36), "PSXGM_T('gm_done')", 'PSXGM_Done()'))
    return '''menu
{
\tname "PSXGM"
\talign center center
\tsize %d %d
\tmodal
\tignoreesc
\tonOpen "PSXGM_OnOpen()"
%s
}
''' % (W, H, '\n'.join(items))


def main():
    tick = '''menu
{
\tname "PSXGM_TICK"
\tignoreesc
\t-- Camp merchant: its enabled check runs every frame (throttled in PSXGM_Tick): store discovery, the page.
\tlabel
\t{
\t\tarea 0 0 0 0
\t\tenabled "PSXGM_Tick()"
\t}
}
'''
    back = '''menu
{
\tname "PSXGM_BACK"
\talign center center
\tsize %d %d
\tignoreesc
%s
%s
}
''' % (W, H, frame((664, 14, 184, 32)), button((664, 14, 184, 32), "PSXGM_T('gm_back')", 'PSXGM_Back()'))
    with open(OUT, 'w', newline='\n') as f:
        f.write('-- Generated by build_gm_menu.py: edit that instead.\n')
        f.write(tick + '\n' + back + '\n' + page())
    print('written', OUT)


if __name__ == '__main__':
    main()
