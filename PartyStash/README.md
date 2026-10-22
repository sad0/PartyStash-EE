# Party Stash (BG:EE / SoD / BG2:EE)

*[Version franÃ§aise plus bas](#franÃ§ais)*

One infinite stash shared by the whole party, **Pillars of Eternity** style, built into a redesigned inventory page.
A WeiDU mod for the Enhanced Editions, powered by [EEex](https://github.com/Bubb13/EEex).

![Inventory, Baldur's Gate 1 look](docs/inventory_bg1.png)

![Click on the gold ? for the help overlay](docs/help.png)

## Features

- **Shared stash**: every party member reaches the same infinite stash, right on the inventory page. Quests still
  see the items stored in it.
- **New inventory page**: your backpack and the stash in one scrollable grid, a ground column, and the stats shown
  as compact 2Ã—2 blocks (attributes in 3 letters: Str, Dex, Conâ€¦).
- **Tabs**: All, Weapons, Armor, Gear, Ammo, Gems, Scrolls, Potions, Quest, Misc, Bags.
- **Smart sorting**: *Auto* (each tab has its own order: weapons by damage per round for the shown character, armor
  by AC, scrolls by class and levelâ€¦), plus Date, Quality, Type, Price and Value/weight. **Right-click** the sort
  button to reverse it.
- **Colour hints**: red = unusable by the shown character, blue = unidentified, **+** = an upgrade for him (or a
  scroll a party mage can still learn).
- **Marks**: **Ctrl + click** an item (in the stash, the backpack or equipped) to mark it **for sale** (darkened),
  again to make it **valuable** (golden), again to clear it. **Sell Marked** sells everything marked for sale at once
  from any merchant, straight from the stash, with the total shown on the button.
- **Valuable items** are never sold, skipped by Store all and by the merchants' selection, and cannot be dropped on
  the ground. A backpack item marked for sale goes straight to the stash.
- **Damage per round**: weapon tooltips show the damage per round and THAC0 for the shown character (strength,
  proficiencies, attacks per round, both hands when dual-wielding); the stats show the attacks per round.
- **Charges**: wands and other charged items show their charges in the corner of their cell.
- **Help overlay**: the gold **?** button at the top right shows what each part of the page does.
- **Put away**: **right-click** the big bag next to the weight, then open a container, and choose to put the
  backpack or the shown stash page in it (valuable and quest items stay). The container panel has a button for it too.
- **Bags**: put a gem bag, scroll case, potion caseâ€¦ in the stash. It is emptied into the stash and kept in the Bags
  tab, and the stash items it can hold weigh nothing. A Bag of Holding makes the whole stash weightless.
- **Weight**: the stash counts against the sum of the members' weight allowances; above it, the party is slowed.
- **Two looks**: Baldur's Gate 1 or Baldur's Gate II style, on either game (the installer recommends the one
  matching your game).
- **Sorted loot** (optional component): ground piles, containers and the quick loot bar list quest items first,
  then weightless items, then the rest by value/weight.
- **Options** (optional components): the stash weighs nothing; keep the party gold through the campaign changes
  (BG1 to SoD, SoD to BG2 in EET); hardcore: those changes empty the stash too.
- **15 languages**: English, French, German, Spanish, Italian, Polish, Russian, Portuguese (Brazil), Czech,
  Hungarian, Turkish, Ukrainian, Simplified Chinese, Japanese, Korean.

![Merchant: Sell Marked](docs/merchant.png)
![Bags tab](docs/bags.png)

## Requirements

- **Baldur's Gate: Enhanced Edition** (with or without **Siege of Dragonspear**), **Baldur's Gate II: Enhanced Edition**
  or **EET**, game version **v2.6.6** or **v2.7.x** (the mod calls the game engine directly; on another version the
  stash disables itself instead of crashing).
- **[EEex](https://github.com/Bubb13/EEex)**, installed first.
- **LeUI** works with Party Stash: install LeUI first, then pick the **Baldur's Gate II look** (see below).
- **Infinity UI++** works with Party Stash: install it first.
- Another mod that replaces the inventory screen (**Dragonspear UI++**â€¦) will conflict with the new inventory page.

### With LeUI

Party Stash with the Baldur's Gate II look on top of **LeUI** (BG:EE):

![Party Stash with LeUI](docs/leui_bg2.png)

## Installation

1. Install **EEex**.
2. Extract the archive into your game folder (where `chitin.key` is): you get a `PartyStash` folder and
   `setup-PartyStash.exe`.
3. Run `setup-PartyStash.exe`, pick your language, then:
   - **Party Stash**: choose the Baldur's Gate 1 or Baldur's Gate II look;
   - **Sorted loot**: optional;
   - **Options**: weightless stash, keep the gold through campaign changes, hardcore (optional).
4. Launch the game through `InfinityLoader.exe` (**EEex**).

## Controls (inventory page)

| Action | Control |
|---|---|
| Take an item from the stash | Click it (double-click: take and equip) |
| Store a backpack item | **Shift + double-click** it, or drop it on the stash grid |
| Store the whole backpack | **Store all** button, or **Space** |
| Mark for sale / valuable / clear | **Ctrl + click** an item (stash, backpack or equipped) |
| Item description | Right-click |
| Scroll the grid, the tabs, the ground | Mouse wheel, arrows |
| Help: what Party Stash adds to the page | The gold **?** button at the top right |
| Reverse the sort | **Right-click** the sort button |
| Put the backpack or a stash page in a container | **Right-click** the big bag, then open the container; or the red button at the bottom right of the container panel |
| Store a bag | **Shift + double-click** it, or Store all (asks first) |
| **Empty the stash** (before uninstalling) | **Ctrl + left click** on the big bag next to the weight |

## Uninstalling

**Empty the stash first**, in game: **Ctrl + left click** on the big bag next to the weight. Your collected bags
come back filled with the items they can hold; everything else drops on the ground. Then run
`setup-PartyStash.exe` and uninstall. If you skip this, the stash contents stay in your saves but cannot be reached
until the mod is reinstalled.

## FAQ

**How does sorting work?** Each tab has its own default sort (**Auto**: weapons by damage per round, armor by AC,
scrolls by class and level...), or you pick **Date**, **Quality**, **Type**, **Price** or **Value/weight**.

**What about bags, even bags of holding?** There is no nesting. A bag put in the stash is emptied into it and kept
in the **Bags** tab, so the stash stays one flat list. Each collected bag makes the stash items it could hold
weightless. A **bag of holding** covers every type, so with one the whole stash weighs nothing.

**I carry around every damn thing. Is that a problem?** The stash is infinite. Without a bag of holding, its weight
counts against the party's combined allowance (over it, everyone slows down). **Store all** empties a backpack in
one click, and **Sell Marked** sells everything you marked at any merchant in one go.

**Does it slow the game down?** No per-creature hooks (no opcode, script or action hooks): its work is throttled
(a quick check every 500 ms, the party weight every 2 s), so the number of creatures on screen doesn't change its
cost. Here is the Ducal Palace in **Siege of Dragonspear**, with hundreds of NPCs, still around 120+ FPS:

![FPS in a crowded scene](docs/fps_sod.png)

## Notes

- Moving from Baldur's Gate to **Siege of Dragonspear**: the stash is carried over as long as the game is not closed
  between the end of BG1 and the start of SoD.
- **EET** (Enhanced Edition Trilogy): tested on v2.6.6. The stash survives the move from **Siege of Dragonspear** to
  Baldur's Gate II.
- Translations other than English and French were made by the author: corrections are welcome (`PartyStash/tra/`).

## Download and discussion

- Download: [GitHub release](https://github.com/sad0/PartyStash-EE/releases/latest) or [Nexus Mods](https://www.nexusmods.com/baldursgate/mods/134)
- Discussion: [Gibberlings3](https://www.gibberlings3.net/forums/topic/41660-weidu-party-stash-v10-a-shared-infinite-stash-on-a-redesigned-inventory-page-bgee-sod-bg2ee-eeex/) Â·
  [Beamdog Forums](https://forums.beamdog.com/discussion/90867/mod-party-stash-v1-0-shared-infinite-stash-redesigned-inventory-eeex/p1) Â·
  [Reddit](https://www.reddit.com/r/baldursgate/comments/1xabaur/i_made_a_mod_for_bgee_bg2ee_one_infinite_stash/)
- Bugs and suggestions: [GitHub issues](https://github.com/sad0/PartyStash-EE/issues)

## License

[MIT](LICENSE) Â© sad0. Game art used by the looks comes from the player's own Enhanced Edition games.

---

## FranÃ§ais

Un coffre infini partagÃ© par tout le groupe, faÃ§on **Pillars of Eternity**, intÃ©grÃ© Ã  une page d'inventaire repensÃ©e.
Un mod WeiDU pour les Enhanced Editions, qui s'appuie sur [EEex](https://github.com/Bubb13/EEex).

### FonctionnalitÃ©s

- **Coffre partagÃ©** : tous les membres du groupe accÃ¨dent au mÃªme coffre infini, directement sur la page
  d'inventaire. Les quÃªtes voient toujours les objets rangÃ©s dedans.
- **Nouvelle page d'inventaire** : sac Ã  dos et coffre dans une seule grille dÃ©filante, une colonne pour le sol, et
  les stats en blocs 2Ã—2 (caractÃ©ristiques en 3 lettres : For, Dex, Conâ€¦).
- **Onglets** : Tout, Armes, Armure, Ã‰quipement, Munitions, Gemmes, Parchemins, Potions, QuÃªte, Divers, Sacs.
- **Tri intelligent** : *Auto* (chaque onglet a son ordre : armes par dÃ©gÃ¢ts par round pour le perso affichÃ©,
  armures par CA, parchemins par classe et niveauâ€¦), plus Date, QualitÃ©, Type, Prix et Valeur/poids. **Clic droit**
  sur le bouton de tri pour l'inverser.
- **Couleurs** : rouge = inutilisable par le perso affichÃ©, bleu = non identifiÃ©, **+** = une amÃ©lioration pour lui
  (ou un parchemin qu'un mage du groupe peut encore apprendre).
- **Marques** : **Ctrl + clic** sur un objet (coffre, sac Ã  dos ou Ã©quipÃ©) pour le cocher **pour la vente**
  (assombri), encore pour le rendre **prÃ©cieux** (dorÃ©), encore pour l'effacer. **Vendre cochÃ©s** vend d'un coup tout
  ce qui est cochÃ© chez n'importe quel marchand, directement depuis le coffre, avec le total affichÃ© sur le bouton.
- **Objets prÃ©cieux** : jamais vendus, ignorÃ©s par Tout ranger et par la sÃ©lection des marchands, impossibles Ã 
  poser au sol. Un objet du sac Ã  dos cochÃ© pour la vente part directement au coffre.
- **DÃ©gÃ¢ts par round** : les infobulles des armes affichent les dÃ©gÃ¢ts par round et le TAC0 pour le perso affichÃ©
  (force, compÃ©tences, attaques par round, les deux mains en combat Ã  deux armes) ; les stats affichent les attaques
  par round.
- **Charges** : les baguettes et autres objets Ã  charges affichent leurs charges dans le coin de leur case.
- **Aide** : le bouton **?** dorÃ© en haut Ã  droite explique chaque partie de la page.
- **DÃ©pÃ´t** : **clic droit** sur le gros sac Ã  cÃ´tÃ© du poids, puis ouvrez un conteneur, et choisissez d'y dÃ©poser le
  sac Ã  dos ou la page du coffre affichÃ©e (les objets prÃ©cieux et de quÃªte restent). Le panneau du conteneur a aussi
  un bouton pour Ã§a.
- **Sacs** : rangez un sac Ã  gemmes, un Ã©tui Ã  parchemins, une boÃ®te Ã  potionsâ€¦ dans le coffre. Il y est vidÃ© et
  gardÃ© dans l'onglet Sacs, et les objets du coffre qu'il peut contenir ne pÃ¨sent plus rien. Un Sac de contenance
  rend tout le coffre sans poids.
- **Poids** : le coffre compte dans la somme des charges maximales des membres ; au-delÃ , le groupe est ralenti.
- **Deux looks** : style Baldur's Gate 1 ou Baldur's Gate II, sur les deux jeux (l'installateur recommande celui de
  votre jeu).
- **Butin triÃ©** (composant optionnel) : au sol, dans les contenants et dans la barre de butin, les objets de
  quÃªte d'abord, puis les objets sans poids, puis le reste par valeur/poids.
- **Options** (composants optionnels) : le coffre ne pÃ¨se rien ; garder l'or du groupe aux changements de campagne
  (BG1 vers SoD, SoD vers BG2 dans EET) ; hardcore : ces changements vident aussi le coffre.
- **15 langues**.

### PrÃ©requis

- **BG:EE** (avec ou sans **Siege of Dragonspear**), **BG2:EE** ou **EET**, version **v2.6.6** ou **v2.7.x**.
- **[EEex](https://github.com/Bubb13/EEex)**, installÃ© avant.
- **LeUI** fonctionne avec Party Stash : installez LeUI avant, puis choisissez le **look Baldur's Gate II**.
- **Infinity UI++** fonctionne avec Party Stash : installez-le avant.
- Un autre mod qui remplace l'Ã©cran d'inventaire (**Dragonspear UI++**â€¦) entre en conflit avec la nouvelle page.

### Installation

1. Installez **EEex**.
2. DÃ©compressez l'archive dans le dossier du jeu (lÃ  oÃ¹ se trouve `chitin.key`).
3. Lancez `setup-PartyStash.exe`, choisissez la langue, puis le look (BG1 ou BG2) et, si vous voulez, Butin triÃ© et
   les options (coffre sans poids, garder l'or, hardcore).
4. Lancez le jeu avec `InfinityLoader.exe` (**EEex**).

### Commandes (page d'inventaire)

| Action | Commande |
|---|---|
| Prendre un objet du coffre | Clic (double-clic : prendre et Ã©quiper) |
| Ranger un objet du sac Ã  dos | **Maj + double-clic**, ou le dÃ©poser sur la grille du coffre |
| Tout ranger | Bouton **Tout ranger**, ou **Espace** |
| Cocher pour la vente / prÃ©cieux / effacer | **Ctrl + clic** sur un objet (coffre, sac Ã  dos ou Ã©quipÃ©) |
| Description | Clic droit |
| Faire dÃ©filer la grille, les onglets, le sol | Molette, flÃ¨ches |
| Aide : ce que Party Stash ajoute Ã  la page | Le bouton **?** dorÃ© en haut Ã  droite |
| Inverser le tri | **Clic droit** sur le bouton de tri |
| DÃ©poser le sac Ã  dos ou une page du coffre dans un conteneur | **Clic droit** sur le gros sac, puis ouvrir le conteneur ; ou le bouton rouge en bas Ã  droite du panneau du conteneur |
| Ranger un sac | **Maj + double-clic**, ou Tout ranger (avec confirmation) |
| **Vider le coffre** (avant de dÃ©sinstaller) | **Ctrl + clic gauche** sur le gros sac Ã  cÃ´tÃ© du poids |

### DÃ©sinstallation

**Videz d'abord le coffre** en jeu : **Ctrl + clic gauche** sur le gros sac Ã  cÃ´tÃ© du poids. Vos sacs collectionnÃ©s
reviennent remplis des objets qu'ils peuvent contenir ; tout le reste tombe au sol. Puis lancez
`setup-PartyStash.exe` et dÃ©sinstallez. Sinon, le contenu du coffre reste dans vos sauvegardes mais devient
inaccessible jusqu'Ã  la rÃ©installation du mod.

### FAQ

**Comment marche le tri ?** Chaque onglet a son tri par dÃ©faut (**Auto** : armes par dÃ©gÃ¢ts par round, armures par
CA, parchemins par classe et niveau...), ou bien vous choisissez **Date**, **QualitÃ©**, **Type**, **Prix** ou **po/lb**.

**Et les sacs, mÃªme les sacs sans fond ?** Pas d'imbrication. Un sac mis dans le coffre y est vidÃ© puis rangÃ© dans
l'onglet **Sacs** : le coffre reste une seule liste. Chaque sac collectionnÃ© rend sans poids les objets du coffre qu'il
pourrait contenir. Un **sac sans fond** couvre tous les types : avec lui, le coffre entier ne pÃ¨se rien.

**Je ramasse absolument tout. C'est un problÃ¨me ?** Le coffre est infini. Sans sac sans fond, son poids compte dans la
capacitÃ© cumulÃ©e du groupe (au-delÃ , tout le monde est ralenti). **Tout ranger** vide un sac Ã  dos en un clic, et
**Vendre cochÃ©s** vend d'un coup tout ce que vous avez marquÃ©, chez n'importe quel marchand.

**Est-ce que Ã§a ralentit le jeu ?** Aucun hook par crÃ©ature (ni opcode, ni script, ni action) : le travail est espacÃ©
(une vÃ©rification toutes les 500 ms, le poids du groupe toutes les 2 s), donc le nombre de crÃ©atures Ã  l'Ã©cran ne
change pas son coÃ»t.

### Remarques

- De Baldur's Gate Ã  **Siege of Dragonspear**, le coffre suit tant que le jeu n'est pas fermÃ© entre la fin de BG1 et
  le dÃ©but de SoD.
- **EET** : testÃ© en v2.6.6. Le coffre survit au passage de **Siege of Dragonspear** Ã  Baldur's Gate II.

### TÃ©lÃ©chargement et discussion

- TÃ©lÃ©chargement : [Release GitHub](https://github.com/sad0/PartyStash-EE/releases/latest) ou [Nexus Mods](https://www.nexusmods.com/baldursgate/mods/134)
- Discussion : [Gibberlings3](https://www.gibberlings3.net/forums/topic/41660-weidu-party-stash-v10-a-shared-infinite-stash-on-a-redesigned-inventory-page-bgee-sod-bg2ee-eeex/) Â·
  [Beamdog Forums](https://forums.beamdog.com/discussion/90867/mod-party-stash-v1-0-shared-infinite-stash-redesigned-inventory-eeex/p1) Â·
  [Reddit](https://www.reddit.com/r/baldursgate/comments/1xabaur/i_made_a_mod_for_bgee_bg2ee_one_infinite_stash/)
- Bugs et suggestions : [issues GitHub](https://github.com/sad0/PartyStash-EE/issues)

### Licence

[MIT](LICENSE) Â© sad0.
