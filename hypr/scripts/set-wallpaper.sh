#!/usr/bin/env bash
# ==============================================================================
#   set-wallpaper.sh [<path-to-image/video>|--pick|--random|--restore] [dark|light]
#   Supports Static Images (PNG, JPG, AVIF), Animated (GIF, WebP), and Videos (MP4, WebM)
# ==============================================================================
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
FRAME_FILE="$CACHE_DIR/current_frame.png"
mkdir -p "$CACHE_DIR"

# Find list of all available wallpapers (including GIF, WebP, MP4, WebM, MKV)
get_all_wallpapers() {
    for d in "${WALLPAPER_DIRS[@]}"; do
        if [ -d "$d" ]; then
            find -L "$d" -maxdepth 3 -type f \( \
                -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o \
                -iname "*.webp" -o -iname "*.gif" -o -iname "*.avif" -o \
                -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" \
            \) 2>/dev/null || true
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

    FILTER_STR="Všechny tapety (*.png *.jpg *.jpeg *.webp *.gif *.avif *.mp4 *.webm *.mkv)|*.png *.jpg *.jpeg *.webp *.gif *.avif *.mp4 *.webm *.mkv"
    SELECTED=""
    if command -v kdialog >/dev/null 2>&1; then
        SELECTED="$(kdialog --title "Vybrat tapetu" --getopenfilename "$START_DIR" "$FILTER_STR" 2>/dev/null || true)"
    elif command -v zenity >/dev/null 2>&1; then
        SELECTED="$(zenity --file-selection --title="Vyberte tapetu" --filename="$START_DIR/" --file-filter="Všechny tapety | *.png *.jpg *.jpeg *.webp *.gif *.avif *.mp4 *.webm *.mkv" 2>/dev/null || true)"
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

# Detect extension
EXT="${WALLPAPER##*.}"
EXT="$(echo "$EXT" | tr '[:upper:]' '[:lower:]')"
IS_VIDEO=false
if [[ "$EXT" =~ ^(mp4|webm|mkv|mov)$ ]]; then
    IS_VIDEO=true
fi

MATUGEN_SOURCE="$WALLPAPER"

# --- Apply Wallpaper ---
if [ "$IS_VIDEO" = true ]; then
    # Extract reference frame for palette & fallback
    if command -v ffmpeg >/dev/null 2>&1; then
        ffmpeg -y -ss 00:00:01 -i "$WALLPAPER" -vframes 1 -update 1 "$FRAME_FILE" >/dev/null 2>&1 || \
        ffmpeg -y -i "$WALLPAPER" -vframes 1 -update 1 "$FRAME_FILE" >/dev/null 2>&1 || true
        MATUGEN_SOURCE="$FRAME_FILE"
    fi

    if command -v mpvpaper >/dev/null 2>&1; then
        killall -9 mpvpaper 2>/dev/null || true
        # Pause awww to save GPU resources
        if command -v awww >/dev/null 2>&1; then
            awww clear 000000ff 2>/dev/null || true
        fi
        setsid mpvpaper -o "no-audio --loop" '*' "$WALLPAPER" </dev/null >/dev/null 2>&1 &
        echo "Video wallpaper set via mpvpaper: $WALLPAPER"
    else
        # Fallback to static frame and notify user
        killall -9 mpvpaper 2>/dev/null || true
        if command -v awww >/dev/null 2>&1; then
            if ! pgrep -x awww-daemon >/dev/null 2>&1; then
                setsid awww-daemon </dev/null >/dev/null 2>&1 &
                sleep 0.3
            fi
            awww img "$FRAME_FILE" --transition-type fade --transition-duration 1 || true
        fi
        if command -v notify-send >/dev/null 2>&1; then
            (notify-send -a "Sedly Rice" -i "$FRAME_FILE" "Video tapeta detekována" "Pro živé přehrávání videa nainstalujte: yay -S mpvpaper mpv" 2>/dev/null || true) &
        fi
    fi
else
    # Static Image or Animated GIF / WebP
    killall -9 mpvpaper 2>/dev/null || true
    if command -v awww >/dev/null 2>&1; then
        if ! pgrep -x awww-daemon >/dev/null 2>&1; then
            setsid awww-daemon </dev/null >/dev/null 2>&1 &
            sleep 0.3
        fi
        awww img "$WALLPAPER" --transition-type fade --transition-duration 1 --transition-fps 60 || true
    fi
    MATUGEN_SOURCE="$WALLPAPER"
fi

# Save to cache
printf '%s\n' "$WALLPAPER" > "$CACHE_FILE"

# Generate dynamic colors with matugen
if command -v matugen >/dev/null 2>&1 && [ -f "$MATUGEN_SOURCE" ]; then
    matugen image "$MATUGEN_SOURCE" -m "$MODE" --source-color-index 0 </dev/null >/dev/null 2>&1 || true
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
NOTIF_ICON="$MATUGEN_SOURCE"
if command -v notify-send >/dev/null 2>&1; then
    (timeout 1s notify-send -a "Sedly Rice" -i "$NOTIF_ICON" "Tapeta změněna" "$(basename "$WALLPAPER")" 2>/dev/null || true) &
fi

echo "Wallpaper set: $WALLPAPER ($MODE)"
