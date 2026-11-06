#!/bin/sh
# Construit et installe (dans ~/.local, sans root) xfce4-display-settings patché pour screen2cut.
# Prérequis : paquets de build (sudo apt-get build-dep xfce4-settings), deb-src activé,
#             et l'outil screen2cut dans le PATH (https://github.com/davidnurdin/screen2cut).
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
WORK=${WORK:-$HERE/_build}
PREFIX=${PREFIX:-$HOME/.local}
rm -rf "$WORK" && mkdir -p "$WORK" && cd "$WORK"
apt-get source xfce4-settings        # même version que celle installée (4.20.1 sur Debian 13)
cd xfce4-settings-*/
patch -p1 < "$HERE/patches/0001-screen2cut-virtual-screens.patch"
./configure --prefix="$PREFIX" --sysconfdir=/etc --disable-debug
make -C protocols && make -j"$(nproc)" -C common
make -j"$(nproc)" -C dialogs/display-settings
make -C po fr.gmo
make -C dialogs/display-settings install
make -C po install
# lanceur : chemin absolu (le PATH d'une session graphique n'inclut pas toujours ~/.local/bin)
sed -i "s|^Exec=xfce4-display-settings|Exec=$PREFIX/bin/xfce4-display-settings|" \
    "$PREFIX/share/applications/xfce-display-settings.desktop"
update-desktop-database "$PREFIX/share/applications" 2>/dev/null || true
echo "Installé dans $PREFIX. Désinstaller : rm $PREFIX/bin/xfce4-display-settings $PREFIX/share/applications/xfce-display-settings.desktop"
