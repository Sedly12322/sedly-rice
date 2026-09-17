import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Rectangle {
    id: root
    height: 32
    radius: Theme.radiusFull
    color: kbHover.containsMouse ? Theme.primaryContainer : Theme.surfaceContainerHigh
    opacity: Theme.islandOpacity
    border.color: Theme.outlineVariant
    border.width: 1

    implicitWidth: kbRow.implicitWidth + 18

    property string layoutText: "US"

    Process {
        id: kbProc
        command: ["sh", "-c", "hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const txt = this.text.trim().toLowerCase();
                if (txt.indexOf("czech") !== -1 || txt.indexOf("cz") !== -1) {
                    root.layoutText = "CZ";
                } else {
                    root.layoutText = "US";
                }
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            kbProc.running = false;
            kbProc.running = true;
        }
    }

    Row {
        id: kbRow
        spacing: 6
        anchors.centerIn: parent

        Text {
            text: "󰌌"
            color: Theme.primary
            font.family: Theme.fontMono
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.layoutText
            color: kbHover.containsMouse ? Theme.cOnPrimaryContainer : Theme.cOnSurface
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: kbHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["hyprctl", "switchxkblayout", "current", "next"]);
            kbProc.running = false;
            kbProc.running = true;
        }
    }
}
