#!/bin/bash
set -e

# Partition, format, and install a vanilla Arch system.
# To be used while booted from an iso image.
# The only argument to the script is the device to install on (e.g. /dev/sda).
# THIS SCRIPT WILL WIPE THE ENTIRE DRIVE!
#
# The grub bootloader will be installed on partition 1.
# The swap partition will be on 2 and occupies 2x the system memory.
# The root ext4 fs will be on partition 3, occupying the rest of the disk.
#
# The arch wiki has a lot more info:
# https://wiki.archlinux.org/index.php/Partitioning
# https://wiki.archlinux.org/index.php/GRUB
# https://wiki.archlinux.org/index.php/swap

dev="$1"

[ ! -b "$dev" ] && echo "Usage: $0 /dev/sdX" >&2 && exit 1
df | grep -q "^$dev" && echo "$dev is mounted" >&2 && exit 1

pacman -Sy --needed --noconfirm grub

# determine system memory
mem="$(grep MemTotal /proc/meminfo | awk '{print $2}')"

(
echo o # clear out any existing partitions

# create boot partition
echo n      # new
echo p      # primary
echo 1      # first partition
echo        # default first sector
echo +200M  # of size 200M
echo t      # change partition type
echo c      # FAT32
echo a      # set the boot flag

# create swap partition
echo n   # new
echo p   # primary
echo 2   # second partition
echo     # default first sector
echo "+$(($mem * 2))K"  # 2x the system memory
echo t   # change partition type
echo 2   # second partition
echo 82  # swap

# create root partition
echo n  # new
echo p  # primary
echo 3  # third partition
echo    # default first sector
echo    # default last sector

echo w  # write changes
) | fdisk "$dev"


boot="${dev}1"
swap="${dev}2"
root="${dev}3"

mkfs.ext4 "$boot"
mkswap "$swap"
mkfs.ext4 "$root"

mount "$root" /mnt
swapon "$swap"  # turn on so genfstab picks it up
mkdir /mnt/boot
mount "$boot" /mnt/boot

# install the base system
pacstrap /mnt base grub

# https://wiki.archlinux.org/index.php/Microcode
grep -q -i vendor_id.*intel /proc/cpuinfo && pacstrap /mnt intel-ucode

# install the bootloader
grub-install --boot-directory=/mnt/boot "$dev"
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

genfstab /mnt >> /mnt/etc/fstab

git clone https://github.com/tylerbrazier/linux.git /mnt/root/linux

echo
echo "finished $0"
echo "$root is still mounted at /mnt so you can arch-chroot and run install.sh"
echo "'umount -R /mnt' after leaving chroot"
