import QtQuick
import Quickshell
import Quickshell.Io
import "bar" as Bar
import "launcher" as Launcher
import "osd" as Osd
import "cheatsheet" as Cheatsheet
import "wallpaper" as Wallpaper
import "controlcenter" as ControlCenter
import "notifications" as Notifications

ShellRoot {
    id: root

    // Top floating bar
    Bar.Bar {
        id: mainBar
    }

    // Interactive Calendar Popup
    Bar.CalendarPopup {
        id: calendarPopup
    }

    // Material 3 Toast Notifications
    Notifications.NotificationToasts {
        id: notificationToasts
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

    // Control Center (Quick Settings) Panel
    ControlCenter.ControlCenter {
        id: controlCenter
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
        target: "controlcenter"

        function toggle(): void {
            controlCenter.toggle();
        }

        function open(): void {
            controlCenter.open();
        }

        function close(): void {
            controlCenter.close();
        }
    }

    IpcHandler {
        target: "calendar"

        function toggle(): void {
            calendarPopup.toggle();
        }

        function open(): void {
            calendarPopup.open();
        }

        function close(): void {
            calendarPopup.close();
        }
    }

    IpcHandler {
        target: "osd"

        function showVolume(val: int, muted: bool): void {
            osd.showVolume(val, muted);
        }

        function showBrightness(val: int): void {
            osd.showBrightness(val);
        }
    }

    IpcHandler {
        target: "theme"

        function reload(): void {
            Theme.reload();
        }
    }
}
