#!/usr/bin/env bash

IFACE="wlan0"
IFACE_WIRED="enp4s0"
THEME_DIR="$HOME/.config/rofi/wifi"
WIFI_THEME="$THEME_DIR/wifi.rasi"
PASS_THEME="$THEME_DIR/password.rasi"

# force a new scan
scan_networks() {
  iwctl station "$IFACE" scan
}

# grab just the SSID column
get_networks() {
  iwctl station "$IFACE" get-networks \
    | tail -n +3 \
    | awk '{printf "%s %s%%\n", $1, $2}'
}

# show connectivity status
get_status() {
  local wifi_ssid
  wifi_ssid=$(iwctl station "$IFACE" show \
    | awk -F': ' '/Connected network/ { print $2 }')
  if [[ -n "$wifi_ssid" && "$wifi_ssid" != "None" ]]; then
    printf "Wi-Fi: %s\n" "$wifi_ssid"
  else
    local state
    state=$(cat /sys/class/net/"$IFACE_WIRED"/operstate 2>/dev/null)
    if [[ "$state" == "up" ]]; then
      printf "Wired: Connected\n"
    else
      printf "Not connected\n"
    fi
  fi
}

# main loop: Show SSIDs + Scan + Settings
main_menu() {
  while true; do
    scan_networks
    local status_line
    status_line=$(get_status)
    items="$status_line\nScan\nSettings\n"
    items+="$(get_networks)"
    CHOICE=$(printf "%b" "$items" \
      | rofi -dmenu -theme "$WIFI_THEME" -p "Wi-Fi ")
    R=$?
    # break on Esc/Ctrl-C
    [ $R -ne 0 ] && return 1

    case "$CHOICE" in
      Scan)
        continue
        ;;
      Settings)
        settings_menu
        ;;
      *)
        password_menu "$CHOICE" && return 0
        ;;
    esac
  done
}

# ask for Wi-Fi password
password_menu() {
  local ssid="$1"
  PASS=$(echo -n \
    | rofi -dmenu -password \
        -theme "$PASS_THEME" \
        -p "Password:")
  R=$?
  [ $R -ne 0 ] && return 1

  echo -n "$PASS" \
    | iwctl station "$IFACE" connect "$ssid"
  return 0
}

# tiny Settings submenu
settings_menu() {
  while true; do
    S=$(printf "Disable adapter\nBack" \
        | rofi -dmenu -theme "$WIFI_THEME" -p "Settings")
    R=$?
    [ $R -ne 0 ] && return 0
    case "$S" in
      "Disable adapter")
        iwctl station "$IFACE" set-property Powered off
        return 0
        ;;
      Back)
        return 0
        ;;
    esac
  done
}

main_menu
exit 0