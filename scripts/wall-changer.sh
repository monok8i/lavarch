#!/usr/bin/env bash

WALLPAPER_DIR="${1:-$HOME/.wallpapers}"
ROFI_THEME="$HOME/.config/rofi/wall_changer/config.rasi"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache/.wallpapers}/thumbnails"
THUMB_SIZE="400x400"

mkdir -p "$CACHE_DIR"

# Find all image files
mapfile -t IMG_FILES < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \))

if [ "${#IMG_FILES[@]}" -eq 0 ]; then
    echo "No images found!"
    exit 1
fi

# Generate thumbnails and build rofi input
ROFI_INPUT=""
for IMG_FILE in "${IMG_FILES[@]}"; do
    BASENAME=$(basename "$IMG_FILE")
    # Get name without extension and the extension
    NAME_WITHOUT_EXT="${BASENAME%.*}"
    EXTENSION="${BASENAME##*.}"

    # Truncate long names but keep extension
    if [ ${#NAME_WITHOUT_EXT} -gt 22 ]; then
        DISPLAY_NAME="${NAME_WITHOUT_EXT:0:19}....${EXTENSION}"
    else
        DISPLAY_NAME="${NAME_WITHOUT_EXT}.${EXTENSION}"
    fi

    THUMB_FILE="$CACHE_DIR/${BASENAME}.png"
    if [ ! -f "$THUMB_FILE" ]; then
        convert "$IMG_FILE" -auto-orient -thumbnail "${THUMB_SIZE}^" -gravity center -extent "$THUMB_SIZE" "$THUMB_FILE"
    fi
    ROFI_INPUT+="${DISPLAY_NAME}\0icon\x1f${THUMB_FILE}\0info\x1f${IMG_FILE}\n"
done

# Show rofi menu
SELECTED_INDEX=$(echo -en "$ROFI_INPUT" | rofi -dmenu \
    -show-icons \
    -theme "$ROFI_THEME" \
    -p "Select Wallpaper" \
    -format 'i' \
    -selected-row 0
)

# Якщо користувач натиснув Escape, виходимо
if [ -z "$SELECTED_INDEX" ]; then
    exit 0
fi

# Отримуємо шлях до файлу з масиву, використовуючи ПРАВИЛЬНУ змінну
WALLPAPER_PATH="${IMG_FILES[$SELECTED_INDEX]}"

# Перевіряємо, чи файл дійсно існує
if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Error: Selected file '$WALLPAPER_PATH' not found!"
    exit 1
fi

# Встановлюємо шпалери, викликаючи hyprpaper НАПРЯМУ
hyprctl hyprpaper preload "$WALLPAPER_PATH" 2>/dev/null
hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER_PATH" 2>/dev/null

exit 0