# Changelog

## v1.2 (2026-10)

- Game version v2.6.6 supported (as well as v2.7.x).
- EET tested (v2.6.6): the stash survives the move from Siege of Dragonspear to BG2.
- Damage per round and THAC0 in the weapon tooltips (stash, backpack and equipped), for the shown character; attacks
  per round in the stats. Auto sorts weapons by damage per round.
- Charges shown on wands and other charged items.
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
