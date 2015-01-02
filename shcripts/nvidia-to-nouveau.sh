#!/bin/bash

pacman -Rdds nvidia nvidia-utils nvidia-libgl libvdpau libcl lib32-nvidia-libgl lib32-nvidia-utils lib32-opencl-nvidia opencl-nvidia

rm -f /etc/X11/xorg.conf

pacman -S xorg-server mesa

pacman -S xf86-video-nouveau lib32-mesa-libgl
