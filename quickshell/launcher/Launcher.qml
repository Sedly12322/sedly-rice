import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
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
        id: focusGrab
        active: root.visible
        windows: [root]
        onCleared: root.close()
    }

    onVisibleChanged: {
        if (root.visible) {
            Qt.callLater(() => searchField.forceActiveFocus());
        }
    }

    function toggle() {
        if (root.visible) {
            root.close();
        } else {
            root.open();
        }
    }

    function open() {
        searchField.text = "";
        root.visible = true;
        Qt.callLater(() => searchField.forceActiveFocus());
    }

    function close() {
        root.visible = false;
    }

    // Dismiss on background click
    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    // Centered modal card
    Rectangle {
        id: card
        width: 580
        height: 480
        anchors.centerIn: parent
        radius: Theme.radiusLg
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1

        scale: root.visible ? 1.0 : 0.95
        opacity: root.visible ? 1.0 : 0.0

        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        // Prevent click-through
        MouseArea {
            anchors.fill: parent
        }

        Column {
            id: col
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // Search Bar
            Rectangle {
                width: parent.width
                height: 46
                radius: Theme.radiusFull
                color: Theme.surfaceContainerHighest
                border.color: searchField.activeFocus ? Theme.primary : "transparent"
                border.width: 2

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: "󰍉"
                        color: Theme.primary
                        font.family: Theme.fontMono
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextInput {
                        id: searchField
                        focus: true
                        width: parent.width - 40
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        color: Theme.cOnSurface
                        selectByMouse: true

                        Text {
                            text: "Hledat aplikace..."
                            color: Theme.outline
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            visible: !searchField.text && !searchField.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Keys.onEscapePressed: root.close()
                        Keys.onDownPressed: {
                            if (appList.currentIndex < col.filteredApps.length - 1) {
                                appList.currentIndex++;
                                appList.positionViewAtIndex(appList.currentIndex, ListView.Contain);
                            }
                        }
                        Keys.onUpPressed: {
                            if (appList.currentIndex > 0) {
                                appList.currentIndex--;
                                appList.positionViewAtIndex(appList.currentIndex, ListView.Contain);
                            }
                        }
                        Keys.onReturnPressed: {
                            if (col.filteredApps.length > 0) {
                                const idx = (appList.currentIndex >= 0 && appList.currentIndex < col.filteredApps.length) ? appList.currentIndex : 0;
                                col.filteredApps[idx].execute();
                                root.close();
                            }
                        }
                    }
                }
            }

            // Application List / Grid
            readonly property var allApps: {
                const list = [];
                try {
                    const apps = DesktopEntries.applications.values;
                    for (let i = 0; i < apps.length; i++) {
                        const a = apps[i];
                        if (a && a.name && a.name.length > 0) {
                            list.push(a);
                        }
                    }
                    list.sort((a, b) => a.name.localeCompare(b.name));
                } catch (e) {
                    console.log("DesktopEntries error: " + e);
                }
                return list;
            }

            readonly property var filteredApps: {
                const q = searchField.text.trim().toLowerCase();
                if (q === "") return allApps;
                return allApps.filter((a) => {
                    const nameMatch = a.name.toLowerCase().indexOf(q) !== -1;
                    const commMatch = a.comment ? a.comment.toLowerCase().indexOf(q) !== -1 : false;
                    return nameMatch || commMatch;
                });
            }

            onFilteredAppsChanged: appList.currentIndex = 0

            ListView {
                id: appList
                width: parent.width
                height: parent.height - 60
                clip: true
                spacing: 6
                model: col.filteredApps
                currentIndex: 0

                delegate: Rectangle {
                    id: itemRow
                    width: appList.width
                    height: 48
                    radius: Theme.radiusMd
                    readonly property bool isCurrent: ListView.isCurrentItem
                    color: (isCurrent || itemHover.containsMouse) ? Theme.surfaceContainerHighest : "transparent"
                    border.color: isCurrent ? Theme.primary : "transparent"
                    border.width: isCurrent ? 1.5 : 0

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        Image {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
                            fillMode: Image.PreserveAspectFit
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 50

                            Text {
                                text: modelData.name
                                color: Theme.cOnSurface
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: modelData.comment || modelData.id || ""
                                color: Theme.outline
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                width: parent.width
                                visible: text.length > 0
                            }
                        }
                    }

                    MouseArea {
                        id: itemHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modelData.execute();
                            root.close();
                        }
                    }
                }
            }
        }
    }
}
