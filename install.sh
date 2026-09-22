#!/usr/bin/env bash
# ==============================================================================
#   Sedly-Rice Installation & Setup Script
#   Modern, Dynamic Material 3 Hyprland Rice with Quickshell & Lua
# ==============================================================================
set -euo pipefail

# Colors for output
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

log_info() { echo -e "${BLUE}${BOLD}[INFO]${NC} $1"; }
log_ok()   { echo -e "${GREEN}${BOLD}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}${BOLD}[WARN]${NC} $1"; }
log_err()  { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.config/sedly-rice-backup-$(date +%Y%m%d_%H%M%S)"

echo -e "${BOLD}"
echo "  ███████╗███████╗██████╗ ██╗  ██╗   ██╗   ██████╗ ██╗ ██████╗███████╗"
echo "  ██╔════╝██╔════╝██╔══██╗██║  ╚██╗ ██╔╝   ██╔══██╗██║██╔════╝██╔════╝"
echo "  ███████╗█████╗  ██║  ██║██║   ╚████╔╝    ██████╔╝██║██║     █████╗  "
echo "  ╚════██║██╔══╝  ██║  ██║██║    ╚██╔╝     ██╔══██╗██║██║     ██╔══╝  "
echo "  ███████║███████╗██████╔╝███████╗██║      ██║  ██║██║╚██████╗███████╗"
echo "  ╚══════╝╚══════╝╚═════╝ ╚══════╝╚═╝      ╚═╝  ╚═╝╚═╝ ╚═════╝╚══════╝"
echo -e "${NC}"
echo "Welcome to the Sedly-Rice installer."
echo "Repository path: $REPO_DIR"
echo ""

# 1. Package Dependencies Check
check_dependencies() {
    log_info "Checking core dependencies..."
    local missing_pacman=()
    local missing_aur=()

    local PACMAN_PKGS=(
        "hyprland" "hypridle" "hyprlock" "kitty" "zsh" "starship"
        "fastfetch" "dolphin" "fuzzel" "cliphist" "wl-clipboard"
        "grim" "slurp" "brightnessctl" "wireplumber" "playerctl"
        "ttf-jetbrains-mono-nerd" "lsd" "bat" "fzf" "ffmpeg" "mpv" "cava"
    )

    local AUR_PKGS=(
        "quickshell" "matugen-bin" "awww" "hyprpolkitagent" "mpvpaper"
    )

    for pkg in "${PACMAN_PKGS[@]}"; do
        if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
            missing_pacman+=("$pkg")
        fi
    done

    for pkg in "${AUR_PKGS[@]}"; do
        if ! pacman -Qi "$pkg" >/dev/null 2>&1 && ! command -v "${pkg%%-*}" >/dev/null 2>&1; then
            missing_aur+=("$pkg")
        fi
    done

    if [ ${#missing_pacman[@]} -gt 0 ]; then
        log_warn "Missing pacman packages: ${missing_pacman[*]}"
        read -rp "Do you want to install them now with sudo pacman -S? [y/N] " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            sudo pacman -S --needed "${missing_pacman[@]}"
        fi
    else
        log_ok "All core pacman packages are installed."
    fi

    if [ ${#missing_aur[@]} -gt 0 ]; then
        log_warn "Missing AUR/helper packages: ${missing_aur[*]}"
        local aur_helper=""
        command -v yay >/dev/null 2>&1 && aur_helper="yay"
        command -v paru >/dev/null 2>&1 && aur_helper="paru"

        if [ -n "$aur_helper" ]; then
            read -rp "Install AUR packages via $aur_helper? [y/N] " ans
            if [[ "$ans" =~ ^[Yy]$ ]]; then
                "$aur_helper" -S --needed "${missing_aur[@]}"
            fi
        else
            log_warn "No AUR helper (yay/paru) detected. Please install manually: ${missing_aur[*]}"
        fi
    else
        log_ok "All AUR/helper utilities found."
    fi
}

# 2. Symlink creation helper
link_config() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ]; then
        local current_target
        current_target="$(readlink -f "$dest" || true)"
        local expected_target
        expected_target="$(readlink -f "$src" || true)"

        if [ "$current_target" = "$expected_target" ]; then
            log_ok "Already linked: $dest -> $src"
            return
        else
            log_warn "Updating symlink: $dest"
            rm "$dest"
        fi
    elif [ -e "$dest" ]; then
        log_warn "Existing file found at $dest! Backing up to $BACKUP_DIR..."
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
    fi

    ln -s "$src" "$dest"
    log_ok "Linked: $dest -> $src"
}

# 3. Create symlinks
create_symlinks() {
    log_info "Creating configuration symlinks..."
    mkdir -p "$CONFIG_DIR"

    # Managed directories and files in ~/.config
    local CONFIG_ITEMS=(
        "dolphinrc"
        "fastfetch"
        "hypr"
        "kitty"
        "matugen"
        "quickshell"
        "starship.toml"
        "wallpapers"
    )

    for item in "${CONFIG_ITEMS[@]}"; do
        if [ -e "$REPO_DIR/$item" ]; then
            link_config "$REPO_DIR/$item" "$CONFIG_DIR/$item"
        fi
    done

    # Symlink .zshrc in home directory
    if [ -f "$REPO_DIR/.zshrc" ]; then
        link_config "$REPO_DIR/.zshrc" "$HOME/.zshrc"
    fi
}

# 4. Set execution permissions
set_permissions() {
    log_info "Setting script permissions..."
    chmod +x "$REPO_DIR/post-switch.sh" 2>/dev/null || true
    chmod +x "$REPO_DIR/hypr/scripts/set-wallpaper.sh" 2>/dev/null || true
    chmod +x "$REPO_DIR/fastfetch/fastfetch.sh" 2>/dev/null || true
    log_ok "Script permissions updated."
}

# 5. Initialize cache & directories
init_environment() {
    log_info "Initializing runtime directories and theme..."
    mkdir -p "$HOME/.cache/quickshell"
    mkdir -p "$HOME/.cache/sedly-rice"
    mkdir -p "$HOME/.cache/matugen"

    # Trigger wallpaper & color generation if script exists
    if [ -x "$REPO_DIR/hypr/scripts/set-wallpaper.sh" ]; then
        log_info "Applying default wallpaper and generating Matugen colors..."
        bash "$REPO_DIR/hypr/scripts/set-wallpaper.sh" "$REPO_DIR/wallpapers/default.jpg" || true
    fi
}

# Run installation
echo "Starting installation..."
check_dependencies
create_symlinks
set_permissions
init_environment

echo ""
log_ok "Installation finished successfully!"
echo -e "${GREEN}${BOLD}You can now start Hyprland or run 'qs' to enjoy Sedly-Rice!${NC}"
