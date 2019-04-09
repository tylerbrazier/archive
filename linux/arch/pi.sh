#!/bin/bash
set -e

# Burn Arch onto an SD card for Rasberry Pi.
# This automates the installation instructions from
# http://archlinuxarm.org/platforms/armv6/raspberry-pi
#
# Usage: ./pi.sh /dev/sdX
# Where X is the device letter for the sdcard. Unmount it before running this.
#
# When finished, put the SD into the pi, connect ethernet, and 5V power.
# The image boots with sshd enabled. You can use nmap to find its IP on the
# local network: sudo nmap -sn "$(hostname -i)/24"
# Login with alarm:alarm. The default root password is root.

[ ! -b "$1" ] && echo "Usage: $0 /dev/sdX" >&2 && exit 1
df | grep -q "^$1" && echo "$1 is mounted" >&2 && exit 1

# needed for make a FAT32 fs
pacman -S --needed dosfstools

(
echo o      # clear out partitions
echo n      # create a new one
echo p      # primary partition
echo 1      # first partition
echo        # default first sector
echo +100M  # size 100M
echo t      # change partition type
echo c      # W95 FAT32 (LBA)
echo n      # create another
echo p      # primary
echo 2      # second partition
echo        # default first sector
echo        # default last sector
echo w      # write changes
) | fdisk "$1"

mkfs.vfat "${1}1"
mkdir boot
mount "${1}1" boot

mkfs.ext4 "${1}2"
mkdir root
mount "${1}2" root

curl -O -L http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
echo 'Extracting to the sd card...'
bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C root
sync

mv root/boot/* boot
umount boot root
