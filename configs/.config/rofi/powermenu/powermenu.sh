#!/bin/bash

# Set the theme path
theme_path="$HOME/.config/rofi/powermenu/powermenu.rasi"

# Check if the theme exists
if [ ! -f "$theme_path" ]; then
    echo "Error: Powermenu theme not found at $theme_path"
    exit 1
fi

# Options
poweroff='  '
reboot='  '
lock='  '
suspend='  '
logout='  '


echo -e "$poweroff\n$reboot\n$lock\n$suspend\n$logout" | rofi -dmenu -theme ~/.config/rofi/powermenu/powermenu.rasi
