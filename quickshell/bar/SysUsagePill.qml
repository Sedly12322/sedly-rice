import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Rectangle {
    id: root
    height: 32
    radius: Theme.radiusFull
    color: Theme.surfaceContainerHigh
    opacity: Theme.islandOpacity
    border.color: Theme.outlineVariant
    border.width: 1

    implicitWidth: usageRow.implicitWidth + 20

    property int cpuPercent: 0
    property int memPercent: 0

    // Memory info
    FileView {
        id: memInfo
        path: "/proc/meminfo"
        watchChanges: false
    }

    property real prevCpuTotal: 0
    property real prevCpuIdle: 0

    Process {
        id: statProc
        command: ["cat", "/proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    const l = lines[i].trim();
                    if (l.startsWith("cpu ")) {
                        const parts = l.split(/\s+/).slice(1).map(Number);
                        const idle = parts[3] + (parts[4] || 0);
                        const total = parts.reduce((a, b) => a + b, 0);

                        if (root.prevCpuTotal > 0) {
                            const diffTotal = total - root.prevCpuTotal;
                            const diffIdle = idle - root.prevCpuIdle;
                            if (diffTotal > 0) {
                                root.cpuPercent = Math.max(0, Math.min(100, Math.round((1 - diffIdle / diffTotal) * 100)));
                            }
                        }
                        root.prevCpuTotal = total;
                        root.prevCpuIdle = idle;
                        break;
                    }
                }
            }
        }
    }

    function updateStats() {
        // Update Mem
        memInfo.reload();
        const memText = memInfo.text();
        if (memText) {
            const mTotal = memText.match(/MemTotal:\s+(\d+)/);
            const mAvail = memText.match(/MemAvailable:\s+(\d+)/);
            if (mTotal && mAvail) {
                const total = parseInt(mTotal[1], 10);
                const avail = parseInt(mAvail[1], 10);
                root.memPercent = Math.round((1 - avail / total) * 100);
            }
        }

        // Update CPU
        statProc.running = false;
        statProc.running = true;
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.updateStats()
    }

    Row {
        id: usageRow
        spacing: 10
        anchors.centerIn: parent

        // CPU
        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "󰻠"
                color: root.cpuPercent > 80 ? Theme.error : Theme.primary
                font.family: Theme.fontMono
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.cpuPercent + "%"
                color: Theme.cOnSurface
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: 1
            height: 12
            color: Theme.outlineVariant
            anchors.verticalCenter: parent.verticalCenter
        }

        // RAM
        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "󰍛"
                color: root.memPercent > 85 ? Theme.error : Theme.secondary
                font.family: Theme.fontMono
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.memPercent + "%"
                color: Theme.cOnSurface
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
