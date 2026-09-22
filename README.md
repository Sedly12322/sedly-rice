# 🌌 Sedly-Rice

<div align="center">

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-00ADD8?style=for-the-badge&logo=wayland&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![Quickshell](https://img.shields.io/badge/Quickshell-5E81AC?style=for-the-badge&logo=qt&logoColor=white)
![Matugen](https://img.shields.io/badge/Matugen-Material_3-blueviolet?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A sleek, modern, and dynamic Material You (M3) Hyprland desktop environment for Arch Linux.**  
Configured entirely in **Lua**, with an ultra-responsive UI driven by **Quickshell** and dynamic palette theming by **Matugen**.

</div>

---

## ✨ Features

- 💎 **Hyprland Configured in Lua**: Modular configuration split cleanly into `modules/*.lua` (animations, keybinds, autostart, windowrules, layerrules, input, monitors, and decorations).
- 🎨 **Material You Dynamic Theming (Matugen)**:
  - Set any wallpaper and the entire desktop dynamically updates its color scheme in real time!
  - Harmonizes Hyprland borders, Kitty terminal, Starship prompt, Quickshell widgets, GTK themes, and Hyprlock.
- ⚡ **Quickshell Interface Suite**:
  - **Top Bar**: Minimalist pill-based bar with workspace indicator, live media player pill with album art and click-to-open, interactive clock with dropdown calendar, and system status stats (CPU, RAM, volume with mouse-wheel control, battery).
  - **Calendar Popup**: Clean monthly calendar dropdown when clicking the top bar clock with today indicator and month navigation.
  - **Control Center (Quick Settings)**: Frosted glass panel with expandable Wi-Fi network scanner, Bluetooth device picker, power profile selector (Power Saver / Balanced / Performance), media player with high-res album art, volume & brightness sliders (`SUPER + A` / `SUPER + S`).
  - **Notification Toasts**: Native Material 3 notification server with animated popups, action buttons, progress bars, and Do Not Disturb (DND) integration.
  - **Volume & Brightness OSD**: Real-time on-screen animated display responding to hardware keys and volume/brightness changes.
  - **App Launcher**: Instant floating launcher with fuzzy search and emoji picker integration (`SUPER` or `SUPER + Period`).
  - **Keybindings Cheatsheet**: Interactive on-screen hotkey overlay (`SUPER + /` or `F1`).
  - **Wallpaper Manager**: Live interactive grid picker to preview and switch wallpapers (`CTRL + SUPER + T`).
- 💻 **Terminal & Shell**:
  - **Kitty** terminal with JetBrains Mono Nerd Font and dynamic color propagation.
  - **Zsh** with **Starship** prompt, auto-suggestions, syntax highlighting, and fzf-tab completion.
  - Fast system overview with **Fastfetch**.

---

## 📁 Repository Structure

```text
sedly-rice/
├── hypr/                   # Hyprland (Lua) configuration
│   ├── hyprland.lua        # Master entrypoint
│   ├── hypridle.conf       # Idle daemon settings
│   ├── hyprlock.conf       # Lockscreen settings
│   ├── modules/            # Modular configs (animations, binds, autostart, etc.)
│   └── scripts/            # Wallpaper switcher & color reload scripts
├── quickshell/             # Full Quickshell QML desktop shell
│   ├── bar/                # Top status bar pills and widgets
│   ├── controlcenter/      # Quick settings / control center panel
│   ├── launcher/           # Application launcher
│   ├── cheatsheet/         # Hotkeys cheatsheet overlay
│   ├── wallpaper/          # Interactive wallpaper picker
│   ├── osd/                # Volume & Brightness on-screen displays
│   └── Theme.qml           # Central theme and dynamic color provider
├── kitty/                  # Terminal configuration & Matugen color imports
├── matugen/                # Material You generator configuration & templates
├── fastfetch/              # Fastfetch system info script & JSONC config
├── wallpapers/             # Default wallpapers
├── post-switch.sh          # Desktop switcher hook to reload daemons
├── starship.toml           # Dynamic shell prompt configuration
├── dolphinrc               # Dolphin file manager settings
├── .zshrc                  # Portable Zsh configuration
└── install.sh              # Automatic setup and symlinker script
```

---

## ⌨️ Keybindings

### 🚀 Applications & System Shell
| Keybinding | Action |
|---|---|
| `SUPER` or `SUPER_L` | Toggle Quickshell App Launcher |
| `SUPER + Return` / `SUPER + T` | Open Kitty Terminal |
| `SUPER + E` | Open Dolphin File Manager |
| `SUPER + W` | Open Web Browser (Firefox) |
| `SUPER + C` | Open Code Editor (VS Code) |
| `SUPER + A` or `SUPER + S` | Toggle Control Center (Quick Settings) |
| `CTRL + SUPER + T` | Open Wallpaper Picker |
| `CTRL + SUPER + ALT + T` | Set Random Wallpaper |
| `SUPER + /` or `SUPER + F1` | Toggle Keybindings Cheatsheet |
| `SUPER + V` | Clipboard History (`cliphist` + `fuzzel`) |
| `SUPER + Period` | Emoji Picker |
| `SUPER + SHIFT + S` | Screenshot Selected Area |
| `Print` | Screenshot Full Screen |
| `CTRL + SUPER + R` | Restart Quickshell |

### 🪟 Window Management
| Keybinding | Action |
|---|---|
| `SUPER + Q` | Close Focused Window |
| `SUPER + ALT + Space` | Toggle Float / Tile |
| `SUPER + F` | Toggle Fullscreen |
| `SUPER + D` | Toggle Maximize |
| `SUPER + Arrows` | Focus window in direction |
| `SUPER + SHIFT + Arrows` | Move window in direction |
| `SUPER + Left Mouse Drag` | Move window |
| `SUPER + Right Mouse Drag` | Resize window |

### 🧭 Workspaces
| Keybinding | Action |
|---|---|
| `SUPER + 1..9` | Switch to Workspace 1..9 |
| `SUPER + SHIFT + 1..9` | Move window to Workspace 1..9 |
| `SUPER + CTRL + Left / Right` | Relative Workspace navigation |
| `SUPER + Tab` / `SUPER + SHIFT + Tab` | Cycle forward / backward through workspaces |
| `SUPER + S` | Toggle Special Workspace (Scratchpad) |

### 🔒 Session & Hardware
| Keybinding | Action |
|---|---|
| `SUPER + L` | Lock Screen (`hyprlock`) |
| `SUPER + SHIFT + L` | Suspend system |
| `XF86AudioRaiseVolume` / `LowerVolume` | Adjust Volume |
| `XF86AudioMute` | Toggle Audio Mute |
| `XF86MonBrightnessUp` / `Down` | Adjust Brightness |
| `XF86AudioPlay` / `SUPER + SHIFT + P` | Media Play / Pause |

---

## 📦 Dependencies

### Official Arch Repositories (`pacman`)
```bash
sudo pacman -S --needed \
    hyprland hypridle hyprlock kitty zsh starship fastfetch \
    dolphin fuzzel cliphist wl-clipboard grim slurp \
    brightnessctl wireplumber playerctl ttf-jetbrains-mono-nerd \
    lsd bat fzf
```

### AUR (`yay` / `paru`)
```bash
yay -S --needed quickshell matugen-bin awww hyprpolkitagent
```

---

## 🚀 Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Sedly12322/sedly-rice.git
   cd sedly-rice
   ```

2. **Run the installer**:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

The installation script will:
- Check for all required dependencies.
- Safely back up any existing conflicting configs to a timestamped backup directory.
- Symlink all configs into `~/.config/` and `~/.zshrc`.
- Initialize cache directories and apply the initial Matugen theme from the default wallpaper.

---

## 🖼️ Wallpaper & Theming

To change wallpapers and dynamically update your theme:
- Press **`CTRL + SUPER + T`** to open the interactive wallpaper picker.
- Or use the CLI script directly:
  ```bash
  ~/.config/hypr/scripts/set-wallpaper.sh /path/to/your/image.jpg
  ```
- Or trigger a random wallpaper from your library:
  ```bash
  ~/.config/hypr/scripts/set-wallpaper.sh --random
  ```

---

## 📜 License

Distributed under the [MIT License](LICENSE). Created with ❤️ by [Sedly12322](https://github.com/Sedly12322).
