import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import ".."

PanelWindow {
    id: root

    visible: false
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        active: root.visible
        windows: [root]
        onCleared: root.close()
    }

    property date displayedDate: new Date()
    property date today: new Date()

    function toggle() {
        if (root.visible) close();
        else open();
    }

    function open() {
        root.today = new Date();
        root.displayedDate = new Date();
        root.visible = true;
    }

    function close() {
        root.visible = false;
    }

    function prevMonth() {
        const d = new Date(root.displayedDate);
        d.setMonth(d.getMonth() - 1);
        root.displayedDate = d;
    }

    function nextMonth() {
        const d = new Date(root.displayedDate);
        d.setMonth(d.getMonth() + 1);
        root.displayedDate = d;
    }

    function resetToday() {
        root.displayedDate = new Date();
    }

    // Dismiss on background click
    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    Item {
        focus: root.visible
        Keys.onEscapePressed: root.close()
    }

    // Calendar Card anchored right below top center bar
    Rectangle {
        id: card
        width: 340
        anchors.top: parent.top
        anchors.topMargin: 54
        anchors.horizontalCenter: parent.horizontalCenter
        implicitHeight: calCol.implicitHeight + 32
        radius: Theme.radiusLg
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.92)
        border.color: Theme.outlineVariant
        border.width: 1

        scale: root.visible ? 1.0 : 0.96
        opacity: root.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
        }

        Column {
            id: calCol
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            spacing: 14

            // 1. Month / Year Navigation Header
            Row {
                width: parent.width
                height: 36
                spacing: 8

                // Prev month button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: prevHover.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰅁"
                        color: Theme.cOnSurface
                        font.family: Theme.fontMono
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: prevHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.prevMonth()
                    }
                }

                // Month Year label
                Item {
                    width: parent.width - 32 * 2 - 8 * 3 - todayBtn.width
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: {
                            const months = [
                                "Leden", "Únor", "Březen", "Duben", "Květen", "Červen",
                                "Červenec", "Srpen", "Září", "Říjen", "Listopad", "Prosinec"
                            ];
                            return months[root.displayedDate.getMonth()] + " " + root.displayedDate.getFullYear();
                        }
                        color: Theme.cOnSurface
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        font.bold: true
                    }
                }

                // Today button
                Rectangle {
                    id: todayBtn
                    height: 28
                    implicitWidth: todayLabel.implicitWidth + 16
                    radius: Theme.radiusFull
                    color: tdHover.containsMouse ? Theme.primary : Theme.surfaceContainerHigh
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: todayLabel
                        anchors.centerIn: parent
                        text: "Dnes"
                        color: tdHover.containsMouse ? Theme.cOnPrimary : Theme.primary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        id: tdHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.resetToday()
                    }
                }

                // Next month button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: nextHover.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰅂"
                        color: Theme.cOnSurface
                        font.family: Theme.fontMono
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: nextHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.nextMonth()
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.outlineVariant
                opacity: 0.5
            }

            // 2. Day-of-week Headers
            Row {
                width: parent.width
                spacing: 0

                readonly property var dayNames: ["Po", "Út", "St", "Čt", "Pá", "So", "Ne"]

                Repeater {
                    model: parent.dayNames

                    Item {
                        width: parent.width / 7
                        height: 24

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: (index >= 5) ? Theme.primary : Theme.outline
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }
            }

            // 3. Days Grid
            Grid {
                id: daysGrid
                width: parent.width
                columns: 7
                spacing: 0

                readonly property var daysData: {
                    const list = [];
                    const year = root.displayedDate.getFullYear();
                    const month = root.displayedDate.getMonth();

                    // First day of month (0=Sun, 1=Mon, ..., 6=Sat)
                    const firstDayRaw = new Date(year, month, 1).getDay();
                    const firstDayIdx = (firstDayRaw + 6) % 7; // Convert to Mon=0 ... Sun=6

                    // Days in current month
                    const daysInMonth = new Date(year, month + 1, 0).getDate();
                    // Days in prev month
                    const daysInPrevMonth = new Date(year, month, 0).getDate();

                    // Trailing days from prev month
                    for (let i = firstDayIdx - 1; i >= 0; i--) {
                        list.push({
                            day: daysInPrevMonth - i,
                            isCurrentMonth: false,
                            isToday: false
                        });
                    }

                    // Current month days
                    const todayYear = root.today.getFullYear();
                    const todayMonth = root.today.getMonth();
                    const todayDate = root.today.getDate();

                    for (let d = 1; d <= daysInMonth; d++) {
                        const isToday = (year === todayYear && month === todayMonth && d === todayDate);
                        list.push({
                            day: d,
                            isCurrentMonth: true,
                            isToday: isToday
                        });
                    }

                    // Leading days from next month
                    const remaining = (7 - (list.length % 7)) % 7;
                    for (let n = 1; n <= remaining; n++) {
                        list.push({
                            day: n,
                            isCurrentMonth: false,
                            isToday: false
                        });
                    }

                    return list;
                }

                Repeater {
                    model: daysGrid.daysData

                    Item {
                        width: daysGrid.width / 7
                        height: 36

                        Rectangle {
                            anchors.centerIn: parent
                            width: 30
                            height: 30
                            radius: 15
                            color: modelData.isToday ? Theme.primary : (dayHover.containsMouse && modelData.isCurrentMonth ? Theme.surfaceContainerHighest : "transparent")

                            Text {
                                anchors.centerIn: parent
                                text: String(modelData.day)
                                color: {
                                    if (modelData.isToday) return Theme.cOnPrimary;
                                    if (!modelData.isCurrentMonth) return Theme.outlineVariant;
                                    return Theme.cOnSurface;
                                }
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: modelData.isToday
                            }

                            MouseArea {
                                id: dayHover
                                anchors.fill: parent
                                hoverEnabled: modelData.isCurrentMonth
                            }
                        }
                    }
                }
            }
        }
    }
}
