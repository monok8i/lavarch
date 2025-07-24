#!/bin/bash
original=$(cliphist list)
display=$(echo "$original" | sed 's/^[0-9]\+\t//' | sed 's/\[\[ binary data \([0-9]\+\) \([A-Za-z]\+\) \([A-Za-z0-9]\+\) \([0-9x]\+\) \]\]/📷 Screenshot (.\3) | \4 | \1\2/')

# Створюємо масиви
IFS=$'\n' read -d '' -r -a orig_lines <<< "$original"
IFS=$'\n' read -d '' -r -a disp_lines <<< "$display"

ROFI_OVERRIDE="window{location:center;anchor:north;}"

# Показуємо в rofi та отримуємо індекс
selected_index=$(printf '%s\n' "${disp_lines[@]}" | rofi -dmenu -theme ~/.config/rofi/dmenu/config.rasi -theme-str "${ROFI_OVERRIDE}" -p Cliphist: -format i)

if [ -n "$selected_index" ]; then
    echo "${orig_lines[$selected_index]}" | cliphist decode | wl-copy
fi