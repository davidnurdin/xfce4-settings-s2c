#!/bin/sh
# Construit xfce4-display-settings patché pour screen2cut et l'installe.
#   ./build.sh           installation système : /usr/local (prioritaire sur /usr) + dpkg-divert de
#                        /usr/bin/xfce4-display-settings -> notre version (les mises à jour du paquet
#                        ne l'écrasent pas). Demande sudo.
#   ./build.sh --user    installation dans ~/.local, sans root.
# Prérequis : sudo apt-get build-dep xfce4-settings (deb-src activé) ; screen2cut dans le PATH.
set -e
MODE=system
[ "$1" = "--user" ] && MODE=user
HERE=$(cd "$(dirname "$0")" && pwd)
WORK=${WORK:-$HERE/_build}
if [ $MODE = user ]; then PREFIX=$HOME/.local; SUDO=; else PREFIX=/usr/local; SUDO=sudo; fi
rm -rf "$WORK" && mkdir -p "$WORK" && cd "$WORK"
apt-get source xfce4-settings        # même version que celle installée (4.20.1 sur Debian 13)
cd xfce4-settings-*/
patch -p1 < "$HERE/patches/0001-screen2cut-virtual-screens.patch"
./configure --prefix="$PREFIX" --sysconfdir=/etc --disable-debug
make -C protocols && make -j"$(nproc)" -C common
make -j"$(nproc)" -C dialogs/display-settings
make -C po fr.gmo
$SUDO make -C dialogs/display-settings install
$SUDO make -C po install
# lanceur : chemin absolu (le PATH d'une session graphique n'inclut pas toujours ~/.local/bin)
$SUDO sed -i "s|^Exec=xfce4-display-settings|Exec=$PREFIX/bin/xfce4-display-settings|" \
    "$PREFIX/share/applications/xfce-display-settings.desktop"
if [ $MODE = system ]; then
  # remplace aussi /usr/bin/xfce4-display-settings (raccourcis, appels par chemin absolu…)
  if ! dpkg-divert --list | grep -q "/usr/bin/xfce4-display-settings"; then
    sudo dpkg-divert --local --divert /usr/bin/xfce4-display-settings.distrib --rename --add /usr/bin/xfce4-display-settings
  fi
  sudo ln -sf "$PREFIX/bin/xfce4-display-settings" /usr/bin/xfce4-display-settings
fi
echo "Installé ($MODE)."
echo "Revenir à l'original (système) :"
echo "  sudo rm /usr/bin/xfce4-display-settings && sudo dpkg-divert --remove --rename /usr/bin/xfce4-display-settings"
echo "  sudo rm /usr/local/bin/xfce4-display-settings /usr/local/share/applications/xfce-display-settings.desktop"
