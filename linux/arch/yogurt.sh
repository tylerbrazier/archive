#!/bin/bash
set -e -u

# Install yaourt.
# https://wiki.archlinux.org/index.php/Yaourt

workdir=/tmp/install_yaourt

if [ $(id -u) -eq 0 ]; then
   echo "Do not run this as root but as a user who can sudo" >&2
   exit 1
fi

sudo pacman -Sy --needed --noconfirm base-devel

rm -rf "$workdir"
mkdir -p "$workdir"

cd "$workdir"
curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz
tar -zxf package-query.tar.gz
cd package-query
makepkg -s --noconfirm
sudo pacman -U --noconfirm package-query-*.pkg.tar.xz

cd "$workdir"
curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz
tar -zxf yaourt.tar.gz
cd yaourt
makepkg -s --noconfirm
sudo pacman -U --noconfirm yaourt-*.pkg.tar.xz
