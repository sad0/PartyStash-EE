# Party Stash (BG:EE / SoD / BG2:EE)

*[Version française plus bas](#français)*

One infinite stash shared by the whole party, **Pillars of Eternity** style, built into a redesigned inventory page.
A WeiDU mod for the Enhanced Editions, powered by [EEex](https://github.com/Bubb13/EEex).

![Inventory, Baldur's Gate 1 look](docs/inventory_bg1.png)

![Hover help, keybinds in green](docs/help.png)

## Features

- **Shared stash**: every party member reaches the same infinite stash, right on the inventory page. Quests still
  see the items stored in it.
- **New inventory page**: your backpack and the stash in one scrollable grid, a ground column, and the stats shown
  as compact 2×2 blocks (attributes in 3 letters: Str, Dex, Con…).
- **Tabs**: All, Weapons, Armor, Gear, Ammo, Gems, Scrolls, Potions, Quest, Misc, Bags.
- **Smart sorting**: *Auto* (each tab has its own order: weapons and armor by quality, then AC and value, scrolls by
  class and level…), plus Date, Quality, Type, Price and Value/weight.
- **Colour hints**: red = unusable by the shown character, blue = unidentified, **+** = an upgrade for him (or a
  scroll a party mage can still learn).
- **Sell marked**: **Ctrl + click** items in the stash, then sell them all at once from any merchant, straight from the
  stash, with the total shown on the button.
- **Bags**: put a gem bag, scroll case, potion case… in the stash. It is emptied into the stash and kept in the Bags
  tab, and the stash items it can hold weigh nothing. A Bag of Holding makes the whole stash weightless.
- **Weight**: the stash counts against the sum of the members' weight allowances; above it, the party is slowed.
- **Two looks**: Baldur's Gate 1 or Baldur's Gate II style, on either game (the installer recommends the one
  matching your game).
- **Sorted loot** (optional component): ground piles, containers and the quick loot bar list quest items first,
  then weightless items, then the rest by value/weight.
- **15 languages**: English, French, German, Spanish, Italian, Polish, Russian, Portuguese (Brazil), Czech,
  Hungarian, Turkish, Ukrainian, Simplified Chinese, Japanese, Korean.

![Merchant: Sell Marked](docs/merchant.png)
![Bags tab](docs/bags.png)

## Requirements

- **Baldur's Gate: Enhanced Edition** (with or without **Siege of Dragonspear**), **Baldur's Gate II: Enhanced Edition**
  (**EET** should work but is untested), game version **v2.7.x** (the mod calls the game engine directly; on another version the stash disables
  itself instead of crashing).
- **[EEex](https://github.com/Bubb13/EEex)**, installed first.
- **LeUI** works with Party Stash: pick the **Baldur's Gate II look** (see below).
- Another mod that replaces the inventory screen (**Dragonspear UI++**…) will conflict with the new inventory page.

### With LeUI

Party Stash with the Baldur's Gate II look on top of **LeUI** (BG:EE):

![Party Stash with LeUI](docs/leui_bg2.png)

## Installation

1. Install **EEex**.
2. Extract the archive into your game folder (where `chitin.key` is): you get a `PartyStash` folder and
   `setup-PartyStash.exe`.
3. Run `setup-PartyStash.exe`, pick your language, then:
   - **Party Stash**: choose the Baldur's Gate 1 or Baldur's Gate II look;
   - **Sorted loot**: optional.
4. Launch the game through `InfinityLoader.exe` (**EEex**).

## Controls (inventory page)

| Action | Control |
|---|---|
| Take an item from the stash | Click it (double-click: take and equip) |
| Store a backpack item | **Shift + double-click** it, or drop it on the stash grid |
| Store the whole backpack | **Store all** button, or **Space** |
| Mark / unmark for sale | **Ctrl + click** a stash item, then **Sell Marked** at a merchant |
| Item description | Right-click |
| Scroll the grid, the tabs, the ground | Mouse wheel, arrows |
| Store a bag | **Shift + double-click** it, or Store all (asks first) |
| **Empty the stash** (before uninstalling) | **Ctrl + left click** on the big bag next to the weight |

## Uninstalling

**Empty the stash first**, in game: **Ctrl + left click** on the big bag next to the weight. Your collected bags
come back filled with the items they can hold; everything else drops on the ground. Then run
`setup-PartyStash.exe` and uninstall. If you skip this, the stash contents stay in your saves but cannot be reached
until the mod is reinstalled.

## Notes

- Moving from Baldur's Gate to **Siege of Dragonspear**: the stash is carried over as long as the game is not closed
  between the end of BG1 and the start of SoD.
- **EET** (Enhanced Edition Trilogy): it should work (it installs like on **BG2:EE**) but has not been tested yet. Feedback welcome.
- Translations other than English and French were made by the author: corrections are welcome (`PartyStash/tra/`).

## Download and discussion

- Download: [GitHub release](https://github.com/sad0/PartyStash-EE/releases/latest) or [Nexus Mods](https://www.nexusmods.com/baldursgate/mods/134)
- Discussion: [Gibberlings3](https://www.gibberlings3.net/forums/topic/41660-weidu-party-stash-v10-a-shared-infinite-stash-on-a-redesigned-inventory-page-bgee-sod-bg2ee-eeex/) ·
  [Beamdog Forums](https://forums.beamdog.com/discussion/90867/mod-party-stash-v1-0-shared-infinite-stash-redesigned-inventory-eeex/p1) ·
  [Reddit](https://www.reddit.com/r/baldursgate/comments/1xabaur/i_made_a_mod_for_bgee_bg2ee_one_infinite_stash/)
- Bugs and suggestions: [GitHub issues](https://github.com/sad0/PartyStash-EE/issues)

## License

[MIT](LICENSE) © sad0. Game art used by the looks comes from the player's own Enhanced Edition games.

---

## Français

Un coffre infini partagé par tout le groupe, façon **Pillars of Eternity**, intégré à une page d'inventaire repensée.
Un mod WeiDU pour les Enhanced Editions, qui s'appuie sur [EEex](https://github.com/Bubb13/EEex).

### Fonctionnalités

- **Coffre partagé** : tous les membres du groupe accèdent au même coffre infini, directement sur la page
  d'inventaire. Les quêtes voient toujours les objets rangés dedans.
- **Nouvelle page d'inventaire** : sac à dos et coffre dans une seule grille défilante, une colonne pour le sol, et
  les stats en blocs 2×2 (caractéristiques en 3 lettres : For, Dex, Con…).
- **Onglets** : Tout, Armes, Armure, Équipement, Munitions, Gemmes, Parchemins, Potions, Quête, Divers, Sacs.
- **Tri intelligent** : *Auto* (chaque onglet a son ordre : armes et armures par qualité puis CA et valeur,
  parchemins par classe et niveau…), plus Date, Qualité, Type, Prix et Valeur/poids.
- **Couleurs** : rouge = inutilisable par le perso affiché, bleu = non identifié, **+** = une amélioration pour lui
  (ou un parchemin qu'un mage du groupe peut encore apprendre).
- **Vendre cochés** : **Ctrl + clic** sur des objets du coffre, puis vente groupée chez n'importe quel marchand,
  directement depuis le coffre, avec le total affiché sur le bouton.
- **Sacs** : rangez un sac à gemmes, un étui à parchemins, une boîte à potions… dans le coffre. Il y est vidé et
  gardé dans l'onglet Sacs, et les objets du coffre qu'il peut contenir ne pèsent plus rien. Un Sac de contenance
  rend tout le coffre sans poids.
- **Poids** : le coffre compte dans la somme des charges maximales des membres ; au-delà, le groupe est ralenti.
- **Deux looks** : style Baldur's Gate 1 ou Baldur's Gate II, sur les deux jeux (l'installateur recommande celui de
  votre jeu).
- **Butin trié** (composant optionnel) : au sol, dans les contenants et dans la barre de butin, les objets de
  quête d'abord, puis les objets sans poids, puis le reste par valeur/poids.
- **15 langues**.

### Prérequis

- **BG:EE** (avec ou sans **Siege of Dragonspear**) ou **BG2:EE**, version **v2.7.x**. **EET** devrait marcher mais n'est pas encore testé.
- **[EEex](https://github.com/Bubb13/EEex)**, installé avant.
- **LeUI** fonctionne avec Party Stash : choisissez le **look Baldur's Gate II**.
- Un autre mod qui remplace l'écran d'inventaire (**Dragonspear UI++**…) entre en conflit avec la nouvelle page.

### Installation

1. Installez **EEex**.
2. Décompressez l'archive dans le dossier du jeu (là où se trouve `chitin.key`).
3. Lancez `setup-PartyStash.exe`, choisissez la langue, puis le look (BG1 ou BG2) et, si vous voulez, Butin trié.
4. Lancez le jeu avec `InfinityLoader.exe` (**EEex**).

### Commandes (page d'inventaire)

| Action | Commande |
|---|---|
| Prendre un objet du coffre | Clic (double-clic : prendre et équiper) |
| Ranger un objet du sac à dos | **Maj + double-clic**, ou le déposer sur la grille du coffre |
| Tout ranger | Bouton **Tout ranger**, ou **Espace** |
| Cocher / décocher pour la vente | **Ctrl + clic** sur un objet du coffre, puis **Vendre cochés** chez un marchand |
| Description | Clic droit |
| Faire défiler la grille, les onglets, le sol | Molette, flèches |
| Ranger un sac | **Maj + double-clic**, ou Tout ranger (avec confirmation) |
| **Vider le coffre** (avant de désinstaller) | **Ctrl + clic gauche** sur le gros sac à côté du poids |

### Désinstallation

**Videz d'abord le coffre** en jeu : **Ctrl + clic gauche** sur le gros sac à côté du poids. Vos sacs collectionnés
reviennent remplis des objets qu'ils peuvent contenir ; tout le reste tombe au sol. Puis lancez
`setup-PartyStash.exe` et désinstallez. Sinon, le contenu du coffre reste dans vos sauvegardes mais devient
inaccessible jusqu'à la réinstallation du mod.

### Téléchargement et discussion

- Téléchargement : [Release GitHub](https://github.com/sad0/PartyStash-EE/releases/latest) ou [Nexus Mods](https://www.nexusmods.com/baldursgate/mods/134)
- Discussion : [Gibberlings3](https://www.gibberlings3.net/forums/topic/41660-weidu-party-stash-v10-a-shared-infinite-stash-on-a-redesigned-inventory-page-bgee-sod-bg2ee-eeex/) ·
  [Beamdog Forums](https://forums.beamdog.com/discussion/90867/mod-party-stash-v1-0-shared-infinite-stash-redesigned-inventory-eeex/p1) ·
  [Reddit](https://www.reddit.com/r/baldursgate/comments/1xabaur/i_made_a_mod_for_bgee_bg2ee_one_infinite_stash/)
- Bugs et suggestions : [issues GitHub](https://github.com/sad0/PartyStash-EE/issues)

### Licence

[MIT](LICENSE) © sad0.
