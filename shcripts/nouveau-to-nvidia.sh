#!/bin/bash

pacman -Rdds xf86-video-nouveau lib32-mesa-libgl

pacman -S nvidia opencl-nvidia lib32-nvidia-libgl lib32-opencl-nvidia
