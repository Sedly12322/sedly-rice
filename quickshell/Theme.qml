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

    // Material 3 Color Roles with defaults (prefixed with c for on* to prevent QML signal collision)
    property color primary: "#bfc2ff"
    property color cOnPrimary: "#272b60"
    property color primaryContainer: "#3e4278"
    property color cOnPrimaryContainer: "#e0e0ff"

    property color secondary: "#c5c4dd"
    property color cOnSecondary: "#2e2f42"
    property color secondaryContainer: "#444559"
    property color cOnSecondaryContainer: "#e1e0f9"

    property color tertiary: "#e8b9d5"
    property color cOnTertiary: "#46263b"
    property color tertiaryContainer: "#5e3c52"
    property color cOnTertiaryContainer: "#ffd8ee"

    property color surface: "#131318"
    property color cOnSurface: "#e4e1e9"
    property color surfaceVariant: "#464551"
    property color cOnSurfaceVariant: "#c4c7c5"
    property color surfaceContainer: "#1f1f25"
    property color surfaceContainerHigh: "#2a2930"
    property color surfaceContainerHighest: "#35343b"

    property color outline: "#908f9c"
    property color outlineVariant: "#464551"

    property color error: "#ffb4ab"
    property color cOnError: "#690005"
    property color errorContainer: "#93000a"
    property color cOnErrorContainer: "#ffdad6"

    readonly property string palettePath: Quickshell.env("HOME") + "/.cache/quickshell/matugen.json"

    FileView {
        id: paletteFile
        path: root.palettePath
        watchChanges: true
        onFileChanged: root.reload()
        onLoaded: root.reload()
    }

    function reload() {
        if (!paletteFile.text()) return;
        try {
            const data = JSON.parse(paletteFile.text());
            if (data.primary) root.primary = data.primary;
            if (data.on_primary) root.cOnPrimary = data.on_primary;
            if (data.primary_container) root.primaryContainer = data.primary_container;
            if (data.on_primary_container) root.cOnPrimaryContainer = data.on_primary_container;

            if (data.secondary) root.secondary = data.secondary;
            if (data.on_secondary) root.cOnSecondary = data.on_secondary;
            if (data.secondary_container) root.secondaryContainer = data.secondary_container;
            if (data.on_secondary_container) root.cOnSecondaryContainer = data.on_secondary_container;

            if (data.tertiary) root.tertiary = data.tertiary;
            if (data.on_tertiary) root.cOnTertiary = data.on_tertiary;
            if (data.tertiary_container) root.tertiaryContainer = data.tertiary_container;
            if (data.on_tertiary_container) root.cOnTertiaryContainer = data.on_tertiary_container;

            if (data.surface) root.surface = data.surface;
            if (data.on_surface) root.cOnSurface = data.on_surface;
            if (data.surface_variant) root.surfaceVariant = data.surface_variant;
            if (data.on_surface_variant) root.cOnSurfaceVariant = data.on_surface_variant;
            if (data.surface_container) root.surfaceContainer = data.surface_container;
            if (data.surface_container_high) root.surfaceContainerHigh = data.surface_container_high;
            if (data.surface_container_highest) root.surfaceContainerHighest = data.surface_container_highest;

            if (data.outline) root.outline = data.outline;
            if (data.outline_variant) root.outlineVariant = data.outline_variant;

            if (data.error) root.error = data.error;
            if (data.on_error) root.cOnError = data.on_error;
            if (data.error_container) root.errorContainer = data.error_container;
            if (data.on_error_container) root.cOnErrorContainer = data.on_error_container;
        } catch (e) {
            console.log("Theme.qml: Failed to parse matugen.json: " + e);
        }
    }

    Component.onCompleted: root.reload()
}
