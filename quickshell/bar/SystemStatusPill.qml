import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Rectangle {
    id: root
    height: Theme.barHeight
    radius: Theme.barRadius
    color: Theme.surfaceContainer
    opacity: Theme.islandOpacity
    border.color: Theme.outlineVariant
    border.width: 1

    implicitWidth: statusRow.implicitWidth + 24

    property int volumeLevel: 50
    property bool volumeMuted: false

    property int batteryLevel: 100
    property bool batteryCharging: false
    property bool hasBattery: false

    // Volume query process
    Process {
        id: volProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = this.text.trim();
                root.volumeMuted = line.indexOf("[MUTED]") !== -1;
                const m = line.match(/Volume:\s+([\d\.]+)/);
                if (m) {
                    root.volumeLevel = Math.round(parseFloat(m[1]) * 100);
                }
            }
        }
    }

    // Battery query process
    Process {
        id: batProc
        command: ["sh", "-c", "if [ -d /sys/class/power_supply/BAT* ]; then cat /sys/class/power_supply/BAT*/capacity; cat /sys/class/power_supply/BAT*/status; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n");
                if (lines.length >= 2 && lines[0].length > 0) {
                    root.hasBattery = true;
                    root.batteryLevel = parseInt(lines[0], 10) || 0;
                    root.batteryCharging = lines[1].trim() === "Charging";
                } else {
                    root.hasBattery = false;
                }
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            volProc.running = false;
            volProc.running = true;
            batProc.running = false;
            batProc.running = true;
        }
    }

    Row {
        id: statusRow
        spacing: 12
        anchors.centerIn: parent

        // Volume item with scroll & click
        Item {
            implicitWidth: volRow.implicitWidth
            implicitHeight: volRow.implicitHeight
            anchors.verticalCenter: parent.verticalCenter

            Row {
                id: volRow
                spacing: 6
                anchors.centerIn: parent

                Text {
                    text: {
                        if (root.volumeMuted) return "󰝟";
                        if (root.volumeLevel >= 60) return "󰕾";
                        if (root.volumeLevel >= 25) return "󰖀";
                        return "󰕿";
                    }
                    color: root.volumeMuted ? Theme.error : Theme.primary
                    font.family: Theme.fontMono
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.volumeMuted ? "Mute" : root.volumeLevel + "%"
                    color: Theme.cOnSurface
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
                    volProc.running = false;
                    volProc.running = true;
                }
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0) {
                        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+", "-l", "1.5"]);
                    } else if (wheel.angleDelta.y < 0) {
                        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]);
                    }
                    volProc.running = false;
                    volProc.running = true;
                }
            }
        }

        // Battery item (if present)
        Row {
            visible: root.hasBattery
            spacing: 5
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: {
                    if (root.batteryCharging) return "󰂄";
                    if (root.batteryLevel >= 90) return "󰁹";
                    if (root.batteryLevel >= 70) return "󰂀";
                    if (root.batteryLevel >= 50) return "󰁾";
                    if (root.batteryLevel >= 30) return "󰁼";
                    if (root.batteryLevel >= 15) return "󰁺";
                    return "󰂃";
                }
                color: root.batteryCharging ? Theme.tertiary : (root.batteryLevel <= 20 ? Theme.error : Theme.secondary)
                font.family: Theme.fontMono
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.batteryLevel + "%"
                color: Theme.cOnSurface
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: 1
            height: 14
            color: Theme.outlineVariant
            anchors.verticalCenter: parent.verticalCenter
        }

        // Power button
        Rectangle {
            width: 26
            height: 26
            radius: 13
            color: pwrHover.containsMouse ? Theme.errorContainer : "transparent"
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: "󰐥"
                color: pwrHover.containsMouse ? Theme.cOnErrorContainer : Theme.error
                font.family: Theme.fontMono
                font.pixelSize: 14
            }

            MouseArea {
                id: pwrHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Quickshell.execDetached(["sh", "-c", "command -v wlogout >/dev/null && wlogout -p layer-shell || hyprctl dispatch exit"]);
                }
            }
        }
    }
}
