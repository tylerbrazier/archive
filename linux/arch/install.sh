#!/bin/bash
set -e

# Customized installation and setup script to be run on a fresh arch system.
# Edit the configuration variables below and run the script as root.
# For more info: https://wiki.archlinux.org/index.php/Installation_guide

### configuration:
hostname=arch
timezone=America/Chicago
superuser=somebody  # will be able to sudo
packages=(
bash-completion
vim
git
tmux
openssh
htop
mlocate
tree
#dialog                # needed for wifi-menu
#wpa_supplicant        # for wpa wireless networks
#xf86-input-synaptics  # for laptop touchpad
#xf86-video-intel      # intel graphics drivers
#lib32-mesa-libgl      # 32bit support needed for steam
#ntfs-3g               # for mounting ntfs
#gvfs-mtp              # for mounting android fs
#gdm                   # display manager
#gnome-shell
#gnome-control-center  # settings
#gnome-tweak-tool      # more settings
#gnome-keyring         # for ssh key storage
#gnome-screenshot
#gnome-terminal
#networkmanager
#nautilus              # file manager
#chromium
#neovim
#xclip                 # for neovim clipboard
#nodejs
#npm
#steam
)
aur_packages=(
pepper-flash       # flash plugin
chromium-widevine  # needed to watch netflix
)
services=(
#gdm
#NetworkManager
)
### end configuration


# enable multilib repo if this is a 64 bit machine
[ "$(uname -m)" == "x86_64" ] && \
  ! grep -q '^\[multilib\]' /etc/pacman.conf && \
  printf '[multilib]\nInclude = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

pacman -Sy --needed sudo "${packages[@]}"

systemctl enable systemd-timesyncd.service "${services[@]}"

echo "$hostname" > /etc/hostname

ln -sf /usr/share/zoneinfo/$timezone /etc/localtime

echo "LANG=en_US.UTF-8" > /etc/locale.conf
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# allow member of wheel group to run sudo without a password
if ! grep -q '^%wheel' /etc/sudoers; then
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
fi

echo "Root password"
passwd root

if ! id -u "$superuser" >/dev/null 2>&1; then
  useradd -m -g users -G wheel -s /bin/bash "$superuser"
  echo "Password for $superuser"
  passwd "$superuser"

  sudo -H -u "$superuser" bash -c "
  cd ~
  git clone https://github.com/tylerbrazier/linux.git ~/linux

  # generate ssh key pair and upload the public key to github, DO, etc.
  ~/linux/any/keygen.sh

  cd ~/linux
  git remote set-url origin git@github.com:tylerbrazier/linux.git

  # install yaourt and aur packages
  ~/linux/arch/yogurt.sh
  [ -n "$aur_packages" ] && yaourt -S ${aur_packages[@]}

  git clone https://github.com/tylerbrazier/dotfiles.git ~/dotfiles
  ~/dotfiles/install.sh -f -p

  cd ~/dotfiles
  git remote set-url origin git@github.com:tylerbrazier/dotfiles.git
  "
fi

echo "finished $0"
