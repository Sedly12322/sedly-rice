import QtQuick
import Quickshell
import Quickshell.Hyprland
import ".."

Row {
    id: root
    spacing: 5
    anchors.verticalCenter: parent.verticalCenter

    readonly property int activeWsId: {
        for (const w of Hyprland.workspaces.values) {
            if (w.active) return w.id;
        }
        return 1;
    }

    readonly property var hasWindowsMap: {
        const map = {};
        for (const w of Hyprland.workspaces.values) {
            if (w.id > 0) map[w.id] = true;
        }
        return map;
    }

    Repeater {
        model: 8 // Show first 8 workspaces or active

        Rectangle {
            id: wsPill
            readonly property int wsId: index + 1
            readonly property bool isActive: root.activeWsId === wsId
            readonly property bool hasWindows: !!root.hasWindowsMap[wsId]

            width: isActive ? 28 : (hasWindows ? 16 : 8)
            height: 12
            radius: Theme.radiusFull
            anchors.verticalCenter: parent.verticalCenter

            color: isActive ? Theme.primary : (hasWindows ? Theme.secondaryContainer : Theme.outlineVariant)
            opacity: isActive ? 1.0 : (hasWindows ? 0.8 : 0.4)

            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + wsPill.wsId)
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0) {
                        Hyprland.dispatch("workspace m-1");
                    } else if (wheel.angleDelta.y < 0) {
                        Hyprland.dispatch("workspace m+1");
                    }
                }
            }
        }
    }
}
