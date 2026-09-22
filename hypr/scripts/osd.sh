#!/usr/bin/env bash
# ==============================================================================
#   osd.sh - Hardware key handler & Quickshell OSD notifier
# ==============================================================================
set -euo pipefail

ACTION="${1:-}"

notify_osd_volume() {
    local raw vol muted=false
    raw="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo 'Volume: 0.50')"
    if [[ "$raw" == *"[MUTED]"* ]]; then
        muted=true
    fi
    vol="$(echo "$raw" | grep -oP '(?<=Volume: )[\d\.]+' || echo '0.50')"
    vol="$(awk "BEGIN {print int($vol * 100 + 0.5)}")"

    qs ipc call osd showVolume "$vol" "$muted" 2>/dev/null || true
}

notify_osd_brightness() {
    local br
    br="$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo '50')"
    qs ipc call osd showBrightness "$br" 2>/dev/null || true
}

case "$ACTION" in
    --vol-up)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.5
        notify_osd_volume
        ;;
    --vol-down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        notify_osd_volume
        ;;
    --vol-mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        notify_osd_volume
        ;;
    --bright-up)
        brightnessctl set 5%+
        notify_osd_brightness
        ;;
    --bright-down)
        brightnessctl set 5%-
        notify_osd_brightness
        ;;
    *)
        echo "Usage: $0 [--vol-up|--vol-down|--vol-mute|--bright-up|--bright-down]"
        exit 1
        ;;
esac
