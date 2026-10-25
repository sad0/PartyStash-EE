# Changelog

## v1.2.2 (2026-10)

- Bags from mods installed after Party Stash (Tweaks Anthology's bags of holding, Neera's gem bag moved by
  Convenient EE NPCs...) no longer vanish when stored: they stay in the Bags tab, also after a reload (issue #2).
- Hardcore option: the campaign changes still empty the stash, but keep the quest items.
- Quest items of BG1, SoD and BG2 weigh nothing (the critical items and every item a dialog or script checks or takes).
- New Notes tab: books, letters, notes and the scrolls that cannot be cast.
- Quest and Notes tabs sorted by date; the Auto sort says what it sorts by on the shown tab ("Auto (DPS)").
- Marks: Ctrl + click marks for sale, Alt + click marks valuable (the same click again clears it).

## v1.2.1 (2026-10)

- Weapon tooltips: THAC0 and damage per round no longer change with the weapon in hand (attacks per round read
  right, the untrained weapon penalty counted for every weapon).
- README: new help screenshot.

## v1.2 (2026-10)

- Game version v2.6.6 supported (as well as v2.7.x).
- EET tested (v2.6.6): the stash survives the move from Siege of Dragonspear to BG2.
- Damage per round and THAC0 in the weapon tooltips (stash, backpack and equipped), for the shown character; attacks
  per round in the stats. Auto sorts weapons by damage per round.
- Charges shown on wands and other charged items.
- Help overlay: a gold ? button at the top right explains each part of the page (bubbles and arrows); keybinds
  in green, labels in gold.
- Weapon upgrade "+" by damage per round: melee against the best quick weapon (or the fist; dual wielding: the
  weaker hand), ranged against the best ranged one (none: every ranged weapon is an upgrade).
- Marks cycle with Ctrl + click: for sale (darkened) → valuable (golden) → none, on stash, backpack and equipped items.
  Valuable items are never sold, skipped by Store all and the merchants' selection, and cannot be dropped on the
  ground. A backpack item marked for sale goes straight to the stash.
- Right-click the sort button to reverse the sort.
- Put away: right-click the big bag, open a container, choose the backpack or the shown stash page.
  Or the new red button at the bottom right of the container panel.
- Gold sound when selling the marked items.
- New optional components: weightless stash; keep the party gold through campaign changes; hardcore (campaign
  changes empty the stash too).
- Infinity UI++ supported (the stats no longer depend on its helpers, the slots keep their frames).
- LeUI: fixed the inventory opening script stopping early on the first open.
- The inventory error message no longer overlaps the page.

## v1.1 (2026-10)

- LeUI support: Party Stash works on top of LeUI (pick the Baldur's Gate II look).
- Stats details (THAC0, damage, item comparison) no longer depend on helpers missing from LeUI.
- BG:EE with LeUI: the stats values are placed for LeUI's font.

## v1.0 (2026-10)

First public release.

- Shared infinite stash on a redesigned inventory page (backpack + stash grid, ground column, 2×2 stats).
- Tabs, Auto sorting per tab, Date / Quality / Type / Price / Value-weight sorts.
- Unusable / unidentified / upgrade hints.
- Sell Marked at merchants (Ctrl + click to mark).
- Bags tab: collected bags make the items they hold weightless.
- Party weight against the sum of the members' allowances.
- Baldur's Gate 1 and Baldur's Gate II looks, on BG:EE and BG2:EE (EET untested).
- Optional Sorted loot component.
- 15 languages.
- Ctrl + left click on the weight bag empties the stash before uninstalling.
