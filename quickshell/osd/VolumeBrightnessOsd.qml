import QtQuick
import Quickshell
import Quickshell.Io
import ".."

PanelWindow {
    id: root

    visible: false
    color: "transparent"

    anchors {
        bottom: true
    }

    margins.bottom: 60
    implicitHeight: 52
    implicitWidth: 260

    property string iconText: "󰕾"
    property int level: 50
    property string title: "Hlasitost"

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.visible = false
    }

    function showOsd(icon, val, name) {
        root.iconText = icon;
        root.level = Math.max(0, Math.min(100, val));
        root.title = name;
        root.visible = true;
        hideTimer.restart();
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusFull
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1
        opacity: Theme.islandOpacity

        Row {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Text {
                text: root.iconText
                color: Theme.primary
                font.family: Theme.fontMono
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 40
                spacing: 4

                Item {
                    width: parent.width
                    height: 16

                    Text {
                        anchors.left: parent.left
                        text: root.title
                        color: Theme.cOnSurface
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }

                    Text {
                        anchors.right: parent.right
                        text: root.level + "%"
                        color: Theme.outline
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                }

                // Progress track
                Rectangle {
                    width: parent.width
                    height: 6
                    radius: 3
                    color: Theme.surfaceContainerHighest

                    Rectangle {
                        width: parent.width * (root.level / 100)
                        height: parent.height
                        radius: 3
                        color: Theme.primary
                    }
                }
            }
        }
    }
}
