#!/bin/bash

# if hypepaper already executed:

if ! pgrep -x "hyprpaper" > /dev/null
then
    # Якщо процес не працює, то запускаємо hyprpaper
    hyprpaper --config ~/.config/hyprpaper/hyprpaper.conf &
fi

