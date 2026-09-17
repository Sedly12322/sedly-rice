import QtQuick
import Quickshell
import ".."

Rectangle {
    id: root
    height: Theme.barHeight
    radius: Theme.barRadius
    color: Theme.surfaceContainer
    opacity: Theme.islandOpacity
    border.color: Theme.outlineVariant
    border.width: 1

    implicitWidth: clockRow.implicitWidth + 28

    property string timeStr: ""
    property string dateStr: ""

    function updateTime() {
        const now = new Date();
        const h = String(now.getHours()).padStart(2, "0");
        const m = String(now.getMinutes()).padStart(2, "0");
        root.timeStr = h + ":" + m;

        const days = ["Ne", "Po", "Út", "St", "Čt", "Pá", "So"];
        const day = days[now.getDay()];
        const d = now.getDate();
        const months = ["led", "úno", "bře", "dub", "kvě", "čvn", "čvc", "srp", "zář", "říj", "lis", "pro"];
        const month = months[now.getMonth()];
        root.dateStr = day + " " + d + ". " + month;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateTime()
    }

    Row {
        id: clockRow
        spacing: 8
        anchors.centerIn: parent

        Text {
            text: "󰅐"
            color: Theme.primary
            font.family: Theme.fontMono
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.timeStr
            color: Theme.cOnSurface
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 3
            height: 3
            radius: 1.5
            color: Theme.outline
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.dateStr
            color: Theme.cOnSurfaceVariant
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
