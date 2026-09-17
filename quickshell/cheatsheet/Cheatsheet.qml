import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
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

    function toggle() {
        if (root.visible) {
            root.close();
        } else {
            root.open();
        }
    }

    function open() {
        searchFilter.text = "";
        root.visible = true;
        searchFilter.forceActiveFocus();
    }

    function close() {
        root.visible = false;
    }

    // Dismiss on clicking background
    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    // Modal Card
    Rectangle {
        id: card
        width: Math.min(940, parent.width - 60)
        height: Math.min(700, parent.height - 80)
        anchors.centerIn: parent
        radius: Theme.radiusLg
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1

        scale: root.visible ? 1.0 : 0.96
        opacity: root.visible ? 1.0 : 0.0

        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        // Prevent click-through
        MouseArea {
            anchors.fill: parent
        }

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // Header Row
            Row {
                width: parent.width
                spacing: 16

                // Icon badge
                Rectangle {
                    width: 44
                    height: 44
                    radius: Theme.radiusMd
                    color: Theme.primaryContainer
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰌌"
                        color: Theme.cOnPrimaryContainer
                        font.family: Theme.fontMono
                        font.pixelSize: 22
                    }
                }

                // Title & Subtitle
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    width: parent.width - 44 - 16 - searchWrap.width - 44 - 32

                    Text {
                        text: "Klávesové zkratky"
                        color: Theme.cOnSurface
                        font.family: Theme.fontFamily
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Text {
                        text: "Přehled všech aktivních zkratek v systému"
                        color: Theme.outline
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                }

                // Search Box
                Rectangle {
                    id: searchWrap
                    width: 260
                    height: 38
                    radius: Theme.radiusFull
                    color: Theme.surfaceContainerHighest
                    border.color: searchFilter.activeFocus ? Theme.primary : "transparent"
                    border.width: 1.5
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            text: "󰍉"
                            color: Theme.primary
                            font.family: Theme.fontMono
                            font.pixelSize: 15
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextInput {
                            id: searchFilter
                            width: parent.width - 30
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            color: Theme.cOnSurface
                            selectByMouse: true

                            Text {
                                text: "Hledat zkratku..."
                                color: Theme.outline
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                visible: !searchFilter.text && !searchFilter.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Keys.onEscapePressed: root.close()
                        }
                    }
                }

                // Close Button
                Rectangle {
                    width: 38
                    height: 38
                    radius: Theme.radiusFull
                    color: closeHover.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                    border.color: Theme.outlineVariant
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: Theme.cOnSurface
                        font.family: Theme.fontMono
                        font.pixelSize: 15
                    }

                    MouseArea {
                        id: closeHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }
            }

            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.outlineVariant
            }

            // Categories & Shortcuts View
            Flickable {
                id: scroller
                width: parent.width
                height: parent.height - 86
                contentWidth: width
                contentHeight: categoriesGrid.implicitHeight
                clip: true

                readonly property var categoriesData: [
                    {
                        title: "Aplikace & Nástroje",
                        icon: "󰵆",
                        items: [
                            { keys: ["SUPER", "Enter"], desc: "Terminál Kitty" },
                            { keys: ["SUPER", "T"], desc: "Terminál Kitty (alt)" },
                            { keys: ["SUPER", "W"], desc: "Webový prohlížeč Firefox" },
                            { keys: ["SUPER", "E"], desc: "Správce souborů Dolphin" },
                            { keys: ["SUPER", "C"], desc: "Editor kódu VS Code" },
                            { keys: ["SUPER"], desc: "Spouštěč aplikací (Launcher)" },
                            { keys: ["SUPER", "/"], desc: "Tento přehled zkratek" }
                        ]
                    },
                    {
                        title: "Správa oken",
                        icon: "󰖲",
                        items: [
                            { keys: ["SUPER", "Q"], desc: "Zavřít aktivní okno" },
                            { keys: ["SUPER", "F"], desc: "Přepnout fullscreen" },
                            { keys: ["SUPER", "D"], desc: "Maximalizovat okno" },
                            { keys: ["SUPER", "Alt", "Space"], desc: "Plovoucí / dlaždicové okno" },
                            { keys: ["SUPER", "P"], desc: "Připnout okno (Pin)" },
                            { keys: ["SUPER", "Šipky"], desc: "Přepnout fokus oken" },
                            { keys: ["SUPER", "Shift", "Šipky"], desc: "Přesunout okno ve směru" },
                            { keys: ["SUPER", "LMB tažení"], desc: "Přesunout okno myší" },
                            { keys: ["SUPER", "RMB tažení"], desc: "Změnit velikost okna myší" }
                        ]
                    },
                    {
                        title: "Pracovní plochy",
                        icon: "󰍹",
                        items: [
                            { keys: ["SUPER", "1..8"], desc: "Přepnout na plochu 1 až 8" },
                            { keys: ["SUPER", "Shift", "1..8"], desc: "Přesunout okno na plochu 1..8" },
                            { keys: ["SUPER", "Ctrl", "Šipky"], desc: "Předchozí / další plocha" },
                            { keys: ["SUPER", "Ctrl", "Shift", "Šipky"], desc: "Přesunout okno na předchozí / další plochu" },
                            { keys: ["SUPER", "Tab"], desc: "Následující plocha" },
                            { keys: ["SUPER", "Shift", "Tab"], desc: "Předchozí plocha" },
                            { keys: ["SUPER", "S"], desc: "Speciální plocha (Scratchpad)" },
                            { keys: ["Alt", "Shift"], desc: "Přepnout layout (US ⇄ CZ)" }
                        ]
                    },
                    {
                        title: "Systém & Média",
                        icon: "󰒓",
                        items: [
                            { keys: ["SUPER", "Shift", "D"], desc: "Přepínač profilů (Dots Switcher)" },
                            { keys: ["SUPER", "V"], desc: "Historie schránky (Cliphist)" },
                            { keys: ["SUPER", "Shift", "S"], desc: "Snímek výřezu obrazovky" },
                            { keys: ["Print"], desc: "Snímek celé obrazovky" },
                            { keys: ["Ctrl", "SUPER", "T"], desc: "Změnit tapetu + Matugen barvy" },
                            { keys: ["Ctrl", "SUPER", "R"], desc: "Restartovat Quickshell lištu" },
                            { keys: ["SUPER", "L"], desc: "Uzamknout obrazovku" },
                            { keys: ["SUPER", "Shift", "P"], desc: "Přehrát / Pozastavit hudbu" },
                            { keys: ["SUPER", "Shift", "N"], desc: "Další skladba" },
                            { keys: ["SUPER", "Shift", "B"], desc: "Předchozí skladba" }
                        ]
                    }
                ]

                Grid {
                    id: categoriesGrid
                    width: parent.width
                    columns: 2
                    spacing: 16

                    Repeater {
                        model: scroller.categoriesData

                        delegate: Rectangle {
                            id: catCard
                            width: (categoriesGrid.width - categoriesGrid.spacing) / 2
                            radius: Theme.radiusMd
                            color: Theme.surfaceContainerHighest
                            border.color: Theme.outlineVariant
                            border.width: 1
                            implicitHeight: cardCol.implicitHeight + 24

                            readonly property var filteredItems: {
                                const q = searchFilter.text.trim().toLowerCase();
                                if (q === "") return modelData.items;
                                return modelData.items.filter((item) => {
                                    const matchDesc = item.desc.toLowerCase().indexOf(q) !== -1;
                                    const matchKey = item.keys.some(k => k.toLowerCase().indexOf(q) !== -1);
                                    return matchDesc || matchKey;
                                });
                            }

                            visible: filteredItems.length > 0

                            Column {
                                id: cardCol
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 10

                                // Category Title
                                Row {
                                    spacing: 8

                                    Text {
                                        text: modelData.icon
                                        color: Theme.primary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 14
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.title
                                        color: Theme.primary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 13
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                // Items in category
                                Repeater {
                                    model: catCard.filteredItems

                                    delegate: Item {
                                        width: cardCol.width
                                        height: 26

                                        // Key badges Row
                                        Row {
                                            id: keysRow
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 4

                                            Repeater {
                                                model: modelData.keys

                                                delegate: Rectangle {
                                                    height: 22
                                                    radius: 5
                                                    color: Theme.surfaceContainer
                                                    border.color: Theme.outlineVariant
                                                    border.width: 1
                                                    implicitWidth: keyLabel.implicitWidth + 12

                                                    Text {
                                                        id: keyLabel
                                                        anchors.centerIn: parent
                                                        text: modelData
                                                        color: Theme.cOnSurface
                                                        font.family: Theme.fontMono
                                                        font.pixelSize: 11
                                                        font.bold: true
                                                    }
                                                }
                                            }
                                        }

                                        // Description
                                        Text {
                                            anchors.left: keysRow.right
                                            anchors.leftMargin: 10
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData.desc
                                            color: Theme.cOnSurface
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
