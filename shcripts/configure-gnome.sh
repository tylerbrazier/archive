#!/usr/bin/env bash

# Gnome is configured thru the gsettings tool (or dconf) instead of editing
# config files.

# key repeat delay
gsettings set org.gnome.settings-daemon.peripherals.keyboard delay 200

# mouse speed
gsettings set org.gnome.settings-daemon.peripherals.mouse \
  motion-acceleration 7.0
gsettings set org.gnome.settings-daemon.peripherals.mouse \
  motion-threshold 4
gsettings set org.gnome.settings-daemon.peripherals.touchpad \
  motion-acceleration 7.0
gsettings set org.gnome.settings-daemon.peripherals.touchpad \
  motion-threshold 4


# 12h clock format
gsettings set org.gnome.desktop.interface clock-format 12h


### reassign keybindings ###

# switch to next workspace (first unassign focus active)
gsettings set org.gnome.shell.keybindings focus-active-notification "[]"
gsettings set org.gnome.desktop.wm.keybindings \
  switch-to-workspace-down "['<Super>n']"

# switch to previous workspace
gsettings set org.gnome.desktop.wm.keybindings \
  switch-to-workspace-up "['<Super>p']"

# move window to next workspace
gsettings set org.gnome.desktop.wm.keybindings \
  move-to-workspace-down "['<Shift><Super>n']"

# move window to previous workspace
gsettings set org.gnome.desktop.wm.keybindings \
  move-to-workspace-up "['<Shift><Super>p']"


### custom keybindings ###

gsettings set org.gnome.settings-daemon.plugins.media-keys \
  custom-keybindings "[\
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/',\
  '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/'\
]"

# define custom0 as urxvt
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/\
  name "urxvt"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/\
  command "urxvt"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/\
  binding "<Super>t"

# define custom1 as chromium
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/\
  name "chromium"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/\
  command "chromium"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/\
  binding "<Super>b"
