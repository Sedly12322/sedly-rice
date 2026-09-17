import QtQuick
import Quickshell
import ".."

PanelWindow {
    id: barWindow

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 48
    color: "transparent"
    exclusiveZone: 46

    // Left Island: Launcher Button + Workspaces
    Row {
        id: leftIsland
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Launcher trigger button
        Rectangle {
            width: Theme.barHeight
            height: Theme.barHeight
            radius: Theme.barRadius
            color: launchHover.containsMouse ? Theme.primaryContainer : Theme.surfaceContainer
            opacity: Theme.islandOpacity
            border.color: Theme.outlineVariant
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "󰣇"
                color: launchHover.containsMouse ? Theme.cOnPrimaryContainer : Theme.primary
                font.family: Theme.fontMono
                font.pixelSize: 18
            }

            MouseArea {
                id: launchHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: launcher.toggle()
            }
        }

        // Workspaces island
        Rectangle {
            height: Theme.barHeight
            radius: Theme.barRadius
            color: Theme.surfaceContainer
            opacity: Theme.islandOpacity
            border.color: Theme.outlineVariant
            border.width: 1

            implicitWidth: wsContent.implicitWidth + 20

            Workspaces {
                id: wsContent
                anchors.centerIn: parent
            }
        }
    }

    // Center Island: Media Pill + Clock Pill
    Row {
        id: centerIsland
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        MediaPill {
            anchors.verticalCenter: parent.verticalCenter
        }

        ClockPill {
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Right Island: SysUsage + KbLayout + SystemStatus
    Row {
        id: rightIsland
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        SysUsagePill {
            anchors.verticalCenter: parent.verticalCenter
        }

        KbLayoutPill {
            anchors.verticalCenter: parent.verticalCenter
        }

        SystemStatusPill {
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
