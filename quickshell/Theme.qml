import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    readonly property string fontFamily: "Google Sans Flex"
    readonly property string fontMono: "JetBrainsMono Nerd Font"

    readonly property int radiusSm: 8
    readonly property int radiusMd: 12
    readonly property int radiusLg: 16
    readonly property int radiusFull: 999

    readonly property int barHeight: 38
    readonly property int barRadius: 19
    readonly property real islandOpacity: 0.88

    readonly property string palettePath: Quickshell.env("HOME") + "/.cache/quickshell/matugen.json"

    FileView {
        id: paletteFile
        path: root.palettePath
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            id: m

            property string primary: "#bfc2ff"
            property string on_primary: "#272b60"
            property string primary_container: "#3e4278"
            property string on_primary_container: "#e0e0ff"

            property string secondary: "#c5c4dd"
            property string on_secondary: "#2e2f42"
            property string secondary_container: "#444559"
            property string on_secondary_container: "#e1e0f9"

            property string tertiary: "#e8b9d5"
            property string on_tertiary: "#46263b"
            property string tertiary_container: "#5e3c52"
            property string on_tertiary_container: "#ffd8ee"

            property string surface: "#131318"
            property string on_surface: "#e4e1e9"
            property string surface_variant: "#464551"
            property string on_surface_variant: "#c4c7c5"
            property string surface_container: "#1f1f25"
            property string surface_container_high: "#2a2930"
            property string surface_container_highest: "#35343b"

            property string outline: "#908f9c"
            property string outline_variant: "#464551"

            property string error: "#ffb4ab"
            property string on_error: "#690005"
            property string error_container: "#93000a"
            property string on_error_container: "#ffdad6"
        }
    }

    // Material 3 Color Roles (declarative reactive bindings)
    readonly property color primary: m.primary
    readonly property color cOnPrimary: m.on_primary
    readonly property color primaryContainer: m.primary_container
    readonly property color cOnPrimaryContainer: m.on_primary_container

    readonly property color secondary: m.secondary
    readonly property color cOnSecondary: m.on_secondary
    readonly property color secondaryContainer: m.secondary_container
    readonly property color cOnSecondaryContainer: m.on_secondary_container

    readonly property color tertiary: m.tertiary
    readonly property color cOnTertiary: m.on_tertiary
    readonly property color tertiaryContainer: m.tertiary_container
    readonly property color cOnTertiaryContainer: m.on_tertiary_container

    readonly property color surface: m.surface
    readonly property color cOnSurface: m.on_surface
    readonly property color surfaceVariant: m.surface_variant
    readonly property color cOnSurfaceVariant: m.on_surface_variant
    readonly property color surfaceContainer: m.surface_container
    readonly property color surfaceContainerHigh: m.surface_container_high
    readonly property color surfaceContainerHighest: m.surface_container_highest

    readonly property color outline: m.outline
    readonly property color outlineVariant: m.outline_variant

    readonly property color error: m.error
    readonly property color cOnError: m.on_error
    readonly property color errorContainer: m.error_container
    readonly property color cOnErrorContainer: m.on_error_container

    function reload() {
        const p = root.palettePath;
        paletteFile.path = "";
        paletteFile.path = p;
        paletteFile.reload();
    }

    Component.onCompleted: root.reload()
}
