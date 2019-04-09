#!/bin/bash
set -e -u

# Build a custom Arch iso.
# Edit the configuration variables below and run the script as root.
# Once built, the iso can be flashed to a USB stick with something like:
#   dd bs=4M if=path/to/iso of=/dev/sdX && sync
# Arch wiki has more info: https://wiki.archlinux.org/index.php/Archiso

### configuration:
workdir=/root/archlive  # /tmp might not have enough space
out=/root  # where the built iso will go
packages=( # additional packages to install on the iso
tmux
git
)
### end configuration


# install dependencies
pacman -Sy --needed archiso

# set up working directory
rm -rf "$workdir"
mkdir -p "$workdir"
cp -r /usr/share/archiso/configs/releng/* "$workdir"

# include this project so it can be used to install arch
git clone https://github.com/tylerbrazier/linux.git \
  "$workdir/airootfs/etc/skel/linux"

# include dotfiles
git clone https://github.com/tylerbrazier/dotfiles.git \
  "$workdir/airootfs/etc/skel/dotfiles"

# commands in customize_airootfs.sh will be executed when the iso boots
echo '
usermod -s /usr/bin/bash root
/root/dotfiles/install.sh -f
' >> "$workdir/airootfs/root/customize_airootfs.sh"

# configure packages to install
printf '%s\n' "${packages[@]}" >> "$workdir/packages.both"

# build.sh from the archiso package does the real work
cd "$workdir"
./build.sh -v -o "$out"

# set permissions
chown root:users "$out"/archlinux-*.iso
chmod g+rw "$out"/archlinux-*.iso

echo "finished $0"
