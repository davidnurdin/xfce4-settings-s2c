# xfce4-settings-s2c

Version **patchée de « Affichage » de XFCE** (`xfce4-display-settings`, xfce4-settings 4.20.1 / Debian 13)
qui comprend les **écrans virtuels** créés avec [screen2cut](https://github.com/davidnurdin/screen2cut)
(moniteurs RandR 1.5 : un écran physique découpé en plusieurs écrans).

L'interface reste **celle d'origine** ; le patch ne fait que deux ajouts :

1. **Aperçu de la disposition** : les écrans virtuels sont dessinés en pointillés, avec leur nom
   (`eDP.1`, `eDP.2`…), à l'intérieur de l'écran physique qui les porte.
2. **Une ligne « Écrans virtuels : [colonnes] × [lignes] [Découper] [Fusionner] [Éditer…] »** dans l'onglet
   Général, pour l'écran sélectionné. Elle appelle `screen2cut --grid` / `--ungrid`, qui enregistre le
   découpage (`~/.config/screen2cut/config.json`) et le réapplique à l'ouverture de session.
   Les découpages **récursifs** (ex. : écran coupé en 2, puis seulement la moitié droite recoupée en 2)
   s'affichent dans l'aperçu ; la ligne indique « découpage personnalisé : N écrans » et **Éditer…**
   ouvre screen2cut sur cet écran pour les modifier.

> État : testé sur XFCE 4.20 / Debian 13 / X11 — aperçu (y compris découpage récursif), détection du
> découpage existant et traduction française vérifiés visuellement. Les clics sur Découper / Fusionner /
> Éditer… n'ont pas pu être testés automatiquement : ils appellent le CLI `screen2cut`, testé à part.
> Wayland non géré (le patch est désactivé hors X11).

## Installation

```bash
sudo apt-get build-dep xfce4-settings      # deb-src doit être activé
git clone https://github.com/davidnurdin/screen2cut          # + cargo build --release, binaire dans le PATH
git clone https://github.com/davidnurdin/xfce4-settings-s2c
cd xfce4-settings-s2c && ./build.sh          # système (sudo) ; ./build.sh --user pour ~/.local
```

Le script télécharge les sources Debian de la **même version** que celle installée, applique
`patches/0001-screen2cut-virtual-screens.patch`, compile et installe dans `/usr/local` (prioritaire sur
`/usr`, donc pour tous les utilisateurs et pour le menu Paramètres), puis détourne
`/usr/bin/xfce4-display-settings` vers notre version avec `dpkg-divert` : une mise à jour du paquet
`xfce4-settings` ne l'écrase pas (l'original reste dans `/usr/bin/xfce4-display-settings.distrib`).

Revenir à l'original : voir les commandes affichées en fin de `build.sh`.

## Licence

GPL-2.0-or-later, comme xfce4-settings dont ce dépôt est un patch (voir `LICENSE`).
Le code ajouté est dans `patches/` (`s2c.h`, modifications de `main.c`, traductions `fr.po`).
