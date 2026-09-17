#!/usr/bin/env bash
# set-wallpaper.sh <path-to-image> [dark|light]
set -euo pipefail

WALLPAPER="${1:-}"
MODE="${2:-dark}"

if [ -z "$WALLPAPER" ]; then
    WALLPAPER="$(find -L "$HOME/.config/wallpapers" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.webp" \) -print -quit 2>/dev/null || true)"
fi

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "Error: wallpaper not found: $WALLPAPER" >&2
    exit 1
fi

# Ensure awww-daemon is running
if command -v awww >/dev/null 2>&1; then
    if ! pgrep -x awww-daemon >/dev/null 2>&1; then
        setsid awww-daemon </dev/null >/dev/null 2>&1 &
        sleep 0.3
    fi
    awww img "$WALLPAPER" --transition-type fade --transition-duration 1 --transition-fps 60 || true
fi

# Save to cache
mkdir -p "$HOME/.cache/sedly-rice"
printf '%s' "$WALLPAPER" > "$HOME/.cache/sedly-rice/current_wallpaper"

# Generate dynamic colors with matugen
if command -v matugen >/dev/null 2>&1; then
    matugen image "$WALLPAPER" -m "$MODE" --source-color-index 0 </dev/null >/dev/null 2>&1 || true
fi

# Reload Hyprland and notify Quickshell
if pidof Hyprland >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi

# Signal quickshell to reload theme if running
if command -v qs >/dev/null 2>&1; then
    qs ipc call theme reload >/dev/null 2>&1 || true
fi

echo "Wallpaper set: $WALLPAPER ($MODE)"
