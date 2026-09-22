import QtQuick
import Quickshell
import Quickshell.Io
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

    // Cava audio visualizer process
    property var cavaBars: [0, 0, 0, 0]
    readonly property string cavaConfPath: Quickshell.env("HOME") + "/.config/quickshell/bar/cava.conf"

    Process {
        id: cavaProc
        running: root.isPlaying
        command: ["cava", "-p", root.cavaConfPath]
        stdout: SplitParser {
            onRead: (data) => {
                const points = data.split(";").map(p => parseFloat(p.trim())).filter(p => !isNaN(p));
                if (points.length >= 4) {
                    root.cavaBars = points;
                }
            }
        }
    }

    // Dynamic rhythmic pulse fallback
    property var animHeights: [6, 12, 8, 14]
    Timer {
        interval: 140
        repeat: true
        running: root.isPlaying
        onTriggered: {
            root.animHeights = [
                Math.floor(Math.random() * 11) + 4,
                Math.floor(Math.random() * 13) + 4,
                Math.floor(Math.random() * 11) + 4,
                Math.floor(Math.random() * 10) + 4
            ];
        }
    }

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
                width: Math.min(implicitWidth, 190)
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

        // Audio Visualizer Equalizer Bars
        Item {
            width: 18
            height: 16
            anchors.verticalCenter: parent.verticalCenter

            Row {
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: 4

                    Rectangle {
                        width: 3
                        radius: 1.5
                        anchors.bottom: parent.bottom
                        color: Theme.primary

                        height: {
                            if (!root.isPlaying) return 3;
                            const cVal = (root.cavaBars && root.cavaBars.length > index) ? root.cavaBars[index] : 0;
                            if (cVal > 4) {
                                return Math.max(3, Math.min(16, Math.round((cVal / 100) * 16)));
                            }
                            return root.animHeights[index];
                        }

                        Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
                        Behavior on color { ColorAnimation { duration: 150 } }
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
