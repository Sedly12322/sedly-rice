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
    readonly property bool isPlaying: root.activePlayer ? root.activePlayer.playbackState === MprisPlaybackState.Playing : false

    implicitWidth: contentRow.implicitWidth + 24

    Row {
        id: contentRow
        spacing: 8
        anchors.centerIn: parent

        Text {
            text: "󰝚"
            color: Theme.primary
            font.family: Theme.fontMono
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: label
            text: root.trackArtist !== "" ? (root.trackArtist + " - " + root.trackTitle) : root.trackTitle
            color: Theme.cOnSecondaryContainer
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            elide: Text.ElideRight
            maximumLineCount: 1
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 200)
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
