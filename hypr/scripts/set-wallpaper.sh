#!/usr/bin/env bash
# set-wallpaper.sh [<path-to-image>|--pick|--random|--restore] [dark|light]
set -euo pipefail

MODE="dark"
ACTION=""
WALLPAPER=""

# Wallpaper search directories
WALLPAPER_DIRS=(
    "$HOME/.config/wallpapers"
    "$HOME/Obrázky/Wallpapers"
    "$HOME/Pictures/wallpapers"
    "$HOME/Obrázky/Wallpapers/Wallpaper-Bank-main/wallpapers"
)

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pick|-p)
            ACTION="pick"
            shift
            ;;
        --random|-r)
            ACTION="random"
            shift
            ;;
        --restore)
            ACTION="restore"
            shift
            ;;
        --mode|-m)
            MODE="${2:-dark}"
            shift 2
            ;;
        dark|light)
            MODE="$1"
            shift
            ;;
        *)
            if [ -z "$WALLPAPER" ]; then
                WALLPAPER="$1"
            fi
            shift
            ;;
    esac
done

CACHE_DIR="$HOME/.cache/sedly-rice"
CACHE_FILE="$CACHE_DIR/current_wallpaper"
mkdir -p "$CACHE_DIR"

# Find list of all available wallpapers
get_all_wallpapers() {
    for d in "${WALLPAPER_DIRS[@]}"; do
        if [ -d "$d" ]; then
            find -L "$d" -maxdepth 3 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.avif" \) 2>/dev/null || true
        fi
    done | awk '!seen[$0]++'
}

# 1. Restore action
if [ "$ACTION" = "restore" ]; then
    if [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then
        saved_wall="$(cat "$CACHE_FILE" | tr -d '\r\n')"
        if [ -f "$saved_wall" ]; then
            WALLPAPER="$saved_wall"
        fi
    fi
    if [ -z "$WALLPAPER" ]; then
        WALLPAPER="$(get_all_wallpapers | head -n 1 || true)"
    fi

# 2. Pick action (GUI file dialog)
elif [ "$ACTION" = "pick" ] || ( [ -z "$ACTION" ] && [ -z "$WALLPAPER" ] && [ -n "${WAYLAND_DISPLAY:-}" ] ); then
    START_DIR="$HOME/Obrázky/Wallpapers"
    if [ ! -d "$START_DIR" ]; then
        START_DIR="$HOME/.config/wallpapers"
    fi

    SELECTED=""
    if command -v kdialog >/dev/null 2>&1; then
        SELECTED="$(kdialog --title "Vybrat tapetu" --getopenfilename "$START_DIR" "*.png *.jpg *.jpeg *.webp *.avif|Obrázky (*.png *.jpg *.jpeg *.webp *.avif)" 2>/dev/null || true)"
    elif command -v zenity >/dev/null 2>&1; then
        SELECTED="$(zenity --file-selection --title="Vyberte tapetu" --filename="$START_DIR/" --file-filter="Obrázky | *.png *.jpg *.jpeg *.webp *.avif" 2>/dev/null || true)"
    fi

    if [ -z "$SELECTED" ] || [ ! -f "$SELECTED" ]; then
        echo "No wallpaper selected or cancelled."
        exit 0
    fi
    WALLPAPER="$SELECTED"

# 3. Random action
elif [ "$ACTION" = "random" ]; then
    current=""
    if [ -f "$CACHE_FILE" ]; then
        current="$(cat "$CACHE_FILE" | tr -d '\r\n')"
    fi

    # Read all into array
    mapfile -t all_walls < <(get_all_wallpapers)
    if [ ${#all_walls[@]} -eq 0 ]; then
        echo "Error: No wallpapers found in wallpaper directories." >&2
        exit 1
    fi

    # Filter out current wallpaper if possible
    candidates=()
    for w in "${all_walls[@]}"; do
        if [ "$w" != "$current" ]; then
            candidates+=("$w")
        fi
    done

    if [ ${#candidates[@]} -gt 0 ]; then
        WALLPAPER="${candidates[RANDOM % ${#candidates[@]}]}"
    else
        WALLPAPER="${all_walls[RANDOM % ${#all_walls[@]}]}"
    fi

# 4. Fallback if no specific wallpaper provided
elif [ -z "$WALLPAPER" ]; then
    WALLPAPER="$(get_all_wallpapers | head -n 1 || true)"
fi

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "Error: Wallpaper not found: $WALLPAPER" >&2
    exit 1
fi

# Ensure awww-daemon is running and set wallpaper
if command -v awww >/dev/null 2>&1; then
    if ! pgrep -x awww-daemon >/dev/null 2>&1; then
        setsid awww-daemon </dev/null >/dev/null 2>&1 &
        sleep 0.3
    fi
    awww img "$WALLPAPER" --transition-type fade --transition-duration 1 --transition-fps 60 || true
fi

# Save to cache
printf '%s\n' "$WALLPAPER" > "$CACHE_FILE"

# Generate dynamic colors with matugen
if command -v matugen >/dev/null 2>&1; then
    matugen image "$WALLPAPER" -m "$MODE" --source-color-index 0 </dev/null >/dev/null 2>&1 || true
fi

# Reload Hyprland colors
if pidof Hyprland >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi

# Signal Quickshell to reload theme if running
if command -v qs >/dev/null 2>&1; then
    qs ipc call theme reload >/dev/null 2>&1 || true
fi

# Send notification
if command -v notify-send >/dev/null 2>&1; then
    (timeout 1s notify-send -a "Sedly Rice" -i "$WALLPAPER" "Tapeta změněna" "$(basename "$WALLPAPER")" 2>/dev/null || true) &
fi

echo "Wallpaper set: $WALLPAPER ($MODE)"
