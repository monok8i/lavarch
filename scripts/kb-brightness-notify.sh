#!/bin/bash

BRIGHTNESS_FILE="/sys/class/leds/asus::kbd_backlight/brightness"
MAX_BRIGHTNESS_FILE="/sys/class/leds/asus::kbd_backlight/max_brightness"

# Ensure required files exist
if [[ ! -r "$BRIGHTNESS_FILE" || ! -r "$MAX_BRIGHTNESS_FILE" ]]; then
    echo "Error: Brightness files not found or not readable."
    exit 1
fi

# Ensure inotifywait is installed
if ! command -v inotifywait &> /dev/null; then
    echo "Error: inotifywait is not installed."
    exit 1
fi

# Ensure notify-send is installed
if ! command -v notify-send &> /dev/null; then
    echo "Error: notify-send is not installed."
    exit 1
fi

# read initial value
prev=$(cat "$BRIGHTNESS_FILE")

# poll every 0.5s for a change
while true; do
    curr=$(cat "$BRIGHTNESS_FILE")
    if [[ "$curr" != "$prev" ]]; then
        prev=$curr
        max=$(cat "$MAX_BRIGHTNESS_FILE")
        (( max == 0 )) && { echo "Error: Max brightness is zero."; exit 1; }
        percent=$(( 100 * curr / max ))


        dunstify -a "kb-brightness" -t 2000 -r 2593 -u normal -h int:value:"${percent}" "Keyboard brightness: $percent%"
    fi
    sleep 0.5
done
