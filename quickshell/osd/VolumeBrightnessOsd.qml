import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."

PanelWindow {
    id: root

    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    exclusiveZone: 0

    anchors {
        bottom: true
    }

    margins.bottom: 64
    implicitHeight: 56
    implicitWidth: 280

    property string iconText: "󰕾"
    property int level: 50
    property string title: "Hlasitost"
    property color accentColor: Theme.primary

    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: root.visible = false
    }

    function showOsd(icon, val, name, color) {
        root.iconText = icon;
        root.level = Math.max(0, Math.min(100, val));
        root.title = name;
        root.accentColor = color || Theme.primary;
        root.visible = true;
        hideTimer.restart();
    }

    function showVolume(val, muted) {
        let icon = "󰕾";
        if (muted) {
            icon = "󰝟";
            showOsd(icon, val, "Ztlumeno", Theme.error);
        } else {
            if (val >= 60) icon = "󰕾";
            else if (val >= 25) icon = "󰖀";
            else icon = "󰕿";
            showOsd(icon, val, "Hlasitost", Theme.primary);
        }
    }

    function showBrightness(val) {
        let icon = "󰃠";
        if (val < 30) icon = "󰃞";
        else if (val < 60) icon = "󰃟";
        showOsd(icon, val, "Jas obrazovky", Theme.tertiary);
    }

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: Theme.radiusFull
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1
        opacity: Theme.islandOpacity

        scale: root.visible ? 1.0 : 0.94
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 14

            Text {
                text: root.iconText
                color: root.accentColor
                font.family: Theme.fontMono
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 44
                spacing: 5

                Item {
                    width: parent.width
                    height: 16

                    Text {
                        anchors.left: parent.left
                        text: root.title
                        color: Theme.cOnSurface
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors.right: parent.right
                        text: root.level + "%"
                        color: Theme.outline
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }
                }

                // Progress track
                Rectangle {
                    width: parent.width
                    height: 6
                    radius: 3
                    color: Theme.surfaceContainerHighest

                    Rectangle {
                        width: Math.max(6, parent.width * (root.level / 100))
                        height: parent.height
                        radius: 3
                        color: root.accentColor

                        Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
        }
    }
}
