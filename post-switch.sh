#!/usr/bin/env bash
# Sedly-Rice post-switch hook
set -eu

# 1. Stop conflicting shells, bars, and daemons from other profiles
killall -9 quickshell qs 2>/dev/null || true
killall ydotool waybar swaybg hyprpaper auto.sh 2>/dev/null || true
pkill -9 -f 'quickshell' 2>/dev/null || true
pkill -9 -x 'qs' 2>/dev/null || true
pkill -x 'wallpaper-loop' 2>/dev/null || true
killall bandwidth-loop system-resources-loop 2>/dev/null || true
pkill -f 'quickshell-sedly' 2>/dev/null || true
pkill -f 'clipboard-monitor.sh' 2>/dev/null || true
sleep 0.5

# 2. Start awww-daemon for wallpaper rendering
if command -v awww-daemon >/dev/null 2>&1; then
    if ! pgrep -x awww-daemon >/dev/null 2>&1; then
        setsid awww-daemon </dev/null >/dev/null 2>&1 &
        sleep 0.3
    fi
fi

# 3. Reload Hyprland
if pidof Hyprland >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi

# 4. Ensure initial palette exists in cache
mkdir -p "$HOME/.cache/quickshell"
if [ ! -s "$HOME/.cache/quickshell/matugen.json" ]; then
    if [ -f "$HOME/.config/lucid/themes/nord/quickshell.json" ]; then
        cp "$HOME/.config/lucid/themes/nord/quickshell.json" "$HOME/.cache/quickshell/matugen.json"
    fi
fi

# 5. Set initial wallpaper & generate dynamic colors
WALL_SCRIPT="$HOME/.config/hypr/scripts/set-wallpaper.sh"
if [ -x "$WALL_SCRIPT" ]; then
    wall="$(find -L "$HOME/.config/wallpapers" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.webp" \) -print -quit 2>/dev/null || true)"
    if [ -n "$wall" ] && [ -f "$wall" ]; then
        bash "$WALL_SCRIPT" "$wall" dark </dev/null >/dev/null 2>&1 || true
    fi
fi

# 6. Start Quickshell for Sedly-Rice
setsid qs </dev/null >/dev/null 2>&1 &

# 7. Start polkit agent and cliphist
systemctl --user start hyprpolkitagent 2>/dev/null || true
if ! pgrep -f 'wl-paste --type text' >/dev/null 2>&1; then
    setsid wl-paste --type text --watch cliphist store </dev/null >/dev/null 2>&1 &
fi
if ! pgrep -f 'wl-paste --type image' >/dev/null 2>&1; then
    setsid wl-paste --type image --watch cliphist store </dev/null >/dev/null 2>&1 &
fi

disown -a 2>/dev/null || true
