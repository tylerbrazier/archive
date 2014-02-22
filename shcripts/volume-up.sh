#!/usr/bin/env bash

# Bind a key on keyboard to call this script to increase volume.

result="$(amixer set Master 5%+ unmute | grep -Eo -m 1 [0123456789]\+%)"
zenity --info --text="$result" --timeout=1

