import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import ".."

Rectangle {
    id: root
    height: 32
    radius: Theme.radiusFull
    color: Theme.secondaryContainer
    opacity: Theme.islandOpacity
    visible: !!root.activePlayer && root.trackTitle.length > 0

    readonly property var activePlayer: {
        for (const p of Mpris.players.values) {
            if (p.trackTitle && p.trackTitle.length > 0) return p;
        }
        return null;
    }

    readonly property string trackTitle: root.activePlayer ? root.activePlayer.trackTitle : ""
    readonly property string trackArtist: root.activePlayer ? (root.activePlayer.trackArtists ? root.activePlayer.trackArtists.join(", ") : "") : ""
    readonly property string trackArtUrl: root.activePlayer ? (root.activePlayer.trackArtUrl || "") : ""
    readonly property bool isPlaying: root.activePlayer ? root.activePlayer.playbackState === MprisPlaybackState.Playing : false

    implicitWidth: contentRow.implicitWidth + 24

    Row {
        id: contentRow
        spacing: 8
        anchors.centerIn: parent

        // Album art circular thumbnail or music note fallback
        Rectangle {
            width: 20
            height: 20
            radius: 10
            clip: true
            color: Theme.surfaceContainerHighest
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: pillArt
                anchors.fill: parent
                source: root.trackArtUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: root.trackArtUrl.length > 0 && status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                text: "󰝚"
                color: Theme.primary
                font.family: Theme.fontMono
                font.pixelSize: 12
                visible: !pillArt.visible
            }
        }

        // Title and artist with click to open control center
        Item {
            implicitWidth: label.implicitWidth
            implicitHeight: label.implicitHeight
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: label
                text: root.trackArtist !== "" ? (root.trackArtist + " - " + root.trackTitle) : root.trackTitle
                color: mediaHover.containsMouse ? Theme.primary : Theme.cOnSecondaryContainer
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                elide: Text.ElideRight
                maximumLineCount: 1
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, 200)
            }

            MouseArea {
                id: mediaHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (typeof controlCenter !== "undefined" && controlCenter) {
                        controlCenter.toggle();
                    }
                }
            }
        }

        // Play / Pause button
        Rectangle {
            width: 24
            height: 24
            radius: 12
            color: playHover.containsMouse ? Theme.surfaceContainerHighest : "transparent"
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: root.isPlaying ? "󰏤" : "󰐊"
                color: Theme.cOnSecondaryContainer
                font.family: Theme.fontMono
                font.pixelSize: 13
            }

            MouseArea {
                id: playHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.activePlayer) root.activePlayer.playPause()
            }
        }

        // Next button
        Rectangle {
            width: 24
            height: 24
            radius: 12
            color: nextHover.containsMouse ? Theme.surfaceContainerHighest : "transparent"
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: "󰒭"
                color: Theme.cOnSecondaryContainer
                font.family: Theme.fontMono
                font.pixelSize: 13
            }

            MouseArea {
                id: nextHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.activePlayer) root.activePlayer.next()
            }
        }
    }
}
