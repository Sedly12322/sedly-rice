import QtQuick
import ".."

Item {
    id: root

    height: 40
    width: parent.width

    property string icon: "󰕾"
    property int value: 50
    property bool isMuted: false
    property color accentColor: Theme.primary
    property color cOnAccent: Theme.cOnPrimary

    signal valueChangedByUser(int newValue)
    signal iconClicked()

    Row {
        anchors.fill: parent
        spacing: 10

        // Left Icon button
        Rectangle {
            id: iconBtn
            width: 36
            height: 36
            radius: Theme.radiusFull
            anchors.verticalCenter: parent.verticalCenter
            color: iconMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: root.isMuted ? Theme.error : (iconMouse.containsMouse ? root.accentColor : Theme.cOnSurface)
                font.family: Theme.fontMono
                font.pixelSize: 18
            }

            MouseArea {
                id: iconMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.iconClicked()
            }
        }

        // Draggable Slider Track
        Rectangle {
            id: track
            width: parent.width - 36 - 10 - 42 - 10
            height: 20
            radius: Theme.radiusFull
            color: Theme.surfaceContainerHighest
            anchors.verticalCenter: parent.verticalCenter
            clip: true

            // Filled progress
            Rectangle {
                id: fillBar
                height: parent.height
                width: Math.max(0, Math.min(track.width, track.width * (root.value / 100.0)))
                radius: Theme.radiusFull
                color: root.isMuted ? Theme.outline : root.accentColor

                Behavior on width {
                    enabled: !sliderMouse.pressed
                    NumberAnimation { duration: 100 }
                }
            }

            MouseArea {
                id: sliderMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function updatePos(mouseX) {
                    const clampedX = Math.max(0, Math.min(track.width, mouseX));
                    const pct = Math.round((clampedX / track.width) * 100);
                    root.valueChangedByUser(pct);
                }

                onPressed: (mouse) => updatePos(mouse.x)
                onPositionChanged: (mouse) => {
                    if (pressed) updatePos(mouse.x);
                }
                onWheel: (wheel) => {
                    const step = 5;
                    if (wheel.angleDelta.y > 0) {
                        root.valueChangedByUser(Math.min(100, root.value + step));
                    } else if (wheel.angleDelta.y < 0) {
                        root.valueChangedByUser(Math.max(0, root.value - step));
                    }
                }
            }
        }

        // Percentage label
        Text {
            width: 42
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
            text: root.isMuted ? "Mute" : root.value + "%"
            color: root.isMuted ? Theme.error : Theme.cOnSurface
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
        }
    }
}
