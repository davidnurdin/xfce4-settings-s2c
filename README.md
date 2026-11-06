# xfce4-settings-s2c

Version **patchée de « Affichage » de XFCE** (`xfce4-display-settings`, xfce4-settings 4.20.1 / Debian 13)
qui comprend les **écrans virtuels** créés avec [screen2cut](https://github.com/davidnurdin/screen2cut)
(moniteurs RandR 1.5 : un écran physique découpé en plusieurs écrans).

L'interface reste **celle d'origine** ; le patch ne fait que deux ajouts :

1. **Aperçu de la disposition** : les écrans virtuels sont dessinés en pointillés, avec leur nom
   (`eDP.1`, `eDP.2`…), à l'intérieur de l'écran physique qui les porte.
2. **Une ligne « Écrans virtuels : [colonnes] × [lignes] [Découper] [Fusionner] »** dans l'onglet Général,
   pour l'écran sélectionné. Elle appelle `screen2cut --grid` / `--ungrid`, qui enregistre le découpage
   (`~/.config/screen2cut/config.json`) et le réapplique à l'ouverture de session.

> État : testé sur XFCE 4.20 / Debian 13 / X11 — aperçu, ligne de réglage (détection du découpage
> existant) et traduction française vérifiés ; les boutons Découper / Fusionner appellent le même CLI
> `screen2cut` que celui testé en ligne de commande. Wayland non géré (le patch est désactivé hors X11).

## Installation (sans root, dans `~/.local`)

```bash
sudo apt-get build-dep xfce4-settings      # deb-src doit être activé
git clone https://github.com/davidnurdin/screen2cut          # + cargo build --release, binaire dans le PATH
git clone https://github.com/davidnurdin/xfce4-settings-s2c
cd xfce4-settings-s2c && ./build.sh
```

Le script télécharge les sources Debian de la **même version** que celle installée, applique
`patches/0001-screen2cut-virtual-screens.patch`, compile et installe `xfce4-display-settings` et son
lanceur dans `~/.local` (ils passent devant ceux du paquet Debian ; rien n'est modifié dans `/usr`).

Désinstaller : supprimer `~/.local/bin/xfce4-display-settings` et
`~/.local/share/applications/xfce-display-settings.desktop`.

## Licence

GPL-2.0-or-later, comme xfce4-settings dont ce dépôt est un patch (voir `LICENSE`).
Le code ajouté est dans `patches/` (`s2c.h`, modifications de `main.c`, traductions `fr.po`).
