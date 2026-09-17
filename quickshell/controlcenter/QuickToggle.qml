import QtQuick
import ".."

Rectangle {
    id: root

    property string icon: "󰖩"
    property string title: "Wi-Fi"
    property string subtitle: "Vypnuto"
    property bool active: false
    property color activeColor: Theme.primary
    property color cOnActiveColor: Theme.cOnPrimary

    signal clicked()

    height: 52
    radius: Theme.radiusMd
    color: root.active 
           ? root.activeColor 
           : (toggleMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh)
    border.color: root.active ? root.activeColor : Theme.outlineVariant
    border.width: 1

    Behavior on color { ColorAnimation { duration: 140 } }
    Behavior on border.color { ColorAnimation { duration: 140 } }

    scale: toggleMouse.pressed ? 0.97 : (toggleMouse.containsMouse ? 1.01 : 1.0)
    Behavior on scale { NumberAnimation { duration: 100 } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        // Icon badge
        Rectangle {
            width: 32
            height: 32
            radius: 16
            anchors.verticalCenter: parent.verticalCenter
            color: root.active 
                   ? Qt.rgba(root.cOnActiveColor.r, root.cOnActiveColor.g, root.cOnActiveColor.b, 0.2)
                   : Theme.surfaceContainerHighest

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: root.active ? root.cOnActiveColor : Theme.primary
                font.family: Theme.fontMono
                font.pixelSize: 16
            }
        }

        // Text labels
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 32 - 10
            spacing: 1

            Text {
                text: root.title
                color: root.active ? root.cOnActiveColor : Theme.cOnSurface
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: root.subtitle
                color: root.active 
                       ? Qt.rgba(root.cOnActiveColor.r, root.cOnActiveColor.g, root.cOnActiveColor.b, 0.75)
                       : Theme.outline
                font.family: Theme.fontFamily
                font.pixelSize: 10
                elide: Text.ElideRight
                width: parent.width
            }
        }
    }

    MouseArea {
        id: toggleMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
