import QtQuick
import Quickshell
import Quickshell.Io
import "bar" as Bar
import "launcher" as Launcher
import "osd" as Osd

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
        target: "theme"

        function reload(): void {
            Theme.reload();
        }
    }
}
