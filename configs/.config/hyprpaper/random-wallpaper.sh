#!/bin/bash

# Шлях до папки з шпалерами
WALL_DIR="$HOME/.wallpapers"

# Випадкова картинка
RANDOM_WALL=$(find "$WALL_DIR" -type f | shuf -n 1)

# Монітор — зміни на свій, якщо в тебе не eDP-1 (перевір через `hyprctl monitors`)
MONITOR="eDP-1"

# Генеруємо новий конфіг
cat > "$HOME/.config/hypr/hyprpaper.conf" <<EOF
preload = $RANDOM_WALL
wallpaper = $MONITOR, $RANDOM_WALL
EOF

# Запускаємо hyprpaper
killall hyprpaper 2>/dev/null
hyprpaper &

