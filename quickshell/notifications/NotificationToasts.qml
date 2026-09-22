import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import ".."

PanelWindow {
    id: root

    color: "transparent"

    anchors {
        top: true
        right: true
    }

    margins.top: 56
    margins.right: 12
    implicitWidth: 380
    implicitHeight: Math.min(600, toastsCol.implicitHeight)

    WlrLayershell.layer: WlrLayer.Overlay

    NotificationServer {
        id: notifServer
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true

        onNotification: (notification) => {
            // Check if DND is active from control center
            if (controlCenter && controlCenter.dndActive && notification.urgency !== NotificationUrgency.Critical) {
                // In DND, still track for history, but don't popup or auto-dismiss
                return;
            }
            notification.tracked = true;
        }
    }

    Column {
        id: toastsCol
        width: parent.width
        spacing: 10

        Repeater {
            model: notifServer.trackedNotifications

            delegate: Rectangle {
                id: toastCard
                width: toastsCol.width
                implicitHeight: cardContent.implicitHeight + 20
                radius: Theme.radiusMd
                color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.92)
                border.color: modelData.urgency === NotificationUrgency.Critical ? Theme.error : Theme.outlineVariant
                border.width: modelData.urgency === NotificationUrgency.Critical ? 2 : 1
                clip: true

                // Slide & fade in animation
                opacity: 0
                x: 40
                Component.onCompleted: {
                    animIn.start();
                }

                ParallelAnimation {
                    id: animIn
                    NumberAnimation { target: toastCard; property: "opacity"; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: toastCard; property: "x"; to: 0; duration: 220; easing.type: Easing.OutCubic }
                }

                // Auto-dismiss timer (6 seconds, unless critical)
                Timer {
                    id: autoDismiss
                    interval: 6000
                    running: modelData.urgency !== NotificationUrgency.Critical
                    onTriggered: {
                        dismissAnim.start();
                    }
                }

                ParallelAnimation {
                    id: dismissAnim
                    NumberAnimation { target: toastCard; property: "opacity"; to: 0.0; duration: 180; easing.type: Easing.InCubic }
                    NumberAnimation { target: toastCard; property: "x"; to: 60; duration: 180; easing.type: Easing.InCubic }
                    onFinished: modelData.dismiss()
                }

                Column {
                    id: cardContent
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    spacing: 8

                    // Header row: Icon, App Name, Close button
                    Row {
                        width: parent.width
                        height: 24
                        spacing: 8

                        // App icon / category
                        Image {
                            width: 18
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter
                            source: modelData.appIcon ? Quickshell.iconPath(modelData.appIcon, true) : ""
                            visible: source !== ""
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            visible: !modelData.appIcon
                            text: "󰂚"
                            color: Theme.primary
                            font.family: Theme.fontMono
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.appName || "Oznámení"
                            color: Theme.outline
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 24 - 18 - 8 - 8
                            elide: Text.ElideRight
                        }

                        // Close button
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: closeHover.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: Theme.cOnSurfaceVariant
                                font.family: Theme.fontMono
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: closeHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: dismissAnim.start()
                            }
                        }
                    }

                    // Summary & Body
                    Column {
                        width: parent.width
                        spacing: 3

                        Text {
                            text: modelData.summary || ""
                            color: Theme.cOnSurface
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            font.bold: true
                            wrapMode: Text.Wrap
                            width: parent.width
                            visible: text.length > 0
                        }

                        Text {
                            text: modelData.body || ""
                            color: Theme.cOnSurfaceVariant
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                            width: parent.width
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }
                    }

                    // Actions row
                    Row {
                        width: parent.width
                        spacing: 6
                        visible: modelData.actions && modelData.actions.length > 0

                        Repeater {
                            model: modelData.actions

                            delegate: Rectangle {
                                height: 26
                                implicitWidth: actLabel.implicitWidth + 16
                                radius: Theme.radiusSm
                                color: actHover.containsMouse ? Theme.primary : Theme.surfaceContainerHighest
                                border.color: Theme.outlineVariant
                                border.width: 1

                                Text {
                                    id: actLabel
                                    anchors.centerIn: parent
                                    text: modelData.text || "Akce"
                                    color: actHover.containsMouse ? Theme.cOnPrimary : Theme.cOnSurface
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                MouseArea {
                                    id: actHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        modelData.invoke();
                                        toastCard.dismissAnim.start();
                                    }
                                }
                            }
                        }
                    }
                }

                // Click on body to invoke default action
                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: {
                        if (modelData.actions) {
                            for (const act of modelData.actions) {
                                if (act.identifier === "default") {
                                    act.invoke();
                                    break;
                                }
                            }
                        }
                        dismissAnim.start();
                    }
                }
            }
        }
    }
}
