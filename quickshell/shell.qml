import QtQuick
import Quickshell
import Quickshell.Io
import "bar" as Bar
import "launcher" as Launcher
import "osd" as Osd
import "cheatsheet" as Cheatsheet
import "wallpaper" as Wallpaper

ShellRoot {
    id: root

    // Top floating bar
    Bar.Bar {
        id: mainBar
    }

    // Material 3 App Launcher
    Launcher.Launcher {
        id: launcher
    }

    // Keybindings Cheatsheet Overlay
    Cheatsheet.Cheatsheet {
        id: cheatsheet
    }

    // Wallpaper Manager Overlay
    Wallpaper.WallpaperPicker {
        id: wallpaperPicker
    }

    // Volume & Brightness OSD
    Osd.VolumeBrightnessOsd {
        id: osd
    }

    // IPC commands
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            launcher.toggle();
        }

        function open(): void {
            launcher.open();
        }

        function close(): void {
            launcher.close();
        }
    }

    IpcHandler {
        target: "cheatsheet"

        function toggle(): void {
            cheatsheet.toggle();
        }

        function open(): void {
            cheatsheet.open();
        }

        function close(): void {
            cheatsheet.close();
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            wallpaperPicker.toggle();
        }

        function open(): void {
            wallpaperPicker.open();
        }

        function close(): void {
            wallpaperPicker.close();
        }
    }

    IpcHandler {
        target: "theme"

        function reload(): void {
            Theme.reload();
        }
    }
}
