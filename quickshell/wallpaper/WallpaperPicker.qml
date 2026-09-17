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

    property var allWallpapers: []
    property string currentWallpaper: ""
    property string selectedCategory: "Všechny"
    property string searchText: ""
    property bool isScanning: false
    property bool applying: false

    readonly property var filteredWallpapers: {
        const q = (root.searchText || "").trim().toLowerCase();
        const cat = root.selectedCategory;
        const list = root.allWallpapers || [];

        return list.filter(w => {
            const matchCat = (cat === "Všechny" || w.category === cat);
            const matchSearch = (q === "" || (w.name && w.name.toLowerCase().indexOf(q) !== -1));
            return matchCat && matchSearch;
        });
    }

    function toggle() {
        if (root.visible) {
            root.close();
        } else {
            root.open();
        }
    }

    function open() {
        root.visible = true;
        searchField.text = "";
        root.searchText = "";
        searchField.forceActiveFocus();
        root.refreshWallpapers();
        currentWallFile.reload();
    }

    function close() {
        root.visible = false;
    }

    function refreshWallpapers() {
        root.isScanning = true;
        scanProc.running = false;
        scanProc.running = true;
    }

    function applyWallpaper(path) {
        if (!path) return;
        root.applying = true;
        root.currentWallpaper = path;
        applyProc.command = ["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/set-wallpaper.sh", path];
        applyProc.running = false;
        applyProc.running = true;
    }

    function applyRandom() {
        if (!root.allWallpapers || root.allWallpapers.length === 0) return;
        const candidates = root.allWallpapers.filter(w => w.path !== root.currentWallpaper);
        const pool = candidates.length > 0 ? candidates : root.allWallpapers;
        const chosen = pool[Math.floor(Math.random() * pool.length)];
        if (chosen) root.applyWallpaper(chosen.path);
    }

    function openFolder() {
        Quickshell.execDetached(["dolphin", Quickshell.env("HOME") + "/Obrázky/Wallpapers"]);
    }

    // Read active wallpaper from cache
    FileView {
        id: currentWallFile
        path: Quickshell.env("HOME") + "/.cache/sedly-rice/current_wallpaper"
        watchChanges: true
        onFileChanged: root.currentWallpaper = this.text().trim()
        onLoaded: root.currentWallpaper = this.text().trim()
    }

    // Process to scan wallpapers
    Process {
        id: scanProc
        command: [
            "bash", "-c",
            "find -L \"$HOME/.config/wallpapers\" \"$HOME/Obrázky/Wallpapers\" \"$HOME/Pictures/wallpapers\" -maxdepth 4 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.avif' \\) 2>/dev/null | awk '!seen[$0]++'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const textData = this.text ? this.text.trim() : "";
                if (!textData) {
                    root.isScanning = false;
                    return;
                }
                const lines = textData.split("\n");
                const list = [];
                for (let i = 0; i < lines.length; i++) {
                    const p = lines[i].trim();
                    if (!p) continue;
                    const parts = p.split("/");
                    const filename = parts[parts.length - 1];
                    let cat = "Moje tapety";
                    if (p.indexOf("Wallpaper-Bank") !== -1) cat = "Wallpaper Bank";
                    else if (p.indexOf(".config/wallpapers") !== -1) cat = "Sedly Rice";

                    list.push({
                        path: p,
                        name: filename,
                        category: cat
                    });
                }
                root.allWallpapers = list;
                root.isScanning = false;
            }
        }
    }

    // Process to apply wallpaper
    Process {
        id: applyProc
        command: []
        onExited: (code, status) => {
            root.applying = false;
            currentWallFile.reload();
            Theme.reload();
        }
    }

    // Dismiss on background click
    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    // Dark backdrop overlay
    Rectangle {
        anchors.fill: parent
        color: "#99000000"
        opacity: root.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    // Main Modal Card
    Rectangle {
        id: card
        width: Math.min(1080, parent.width - 60)
        height: Math.min(740, parent.height - 80)
        anchors.centerIn: parent
        radius: Theme.radiusLg
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1

        scale: root.visible ? 1.0 : 0.96
        opacity: root.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        // Prevent click-through
        MouseArea {
            anchors.fill: parent
        }

        // Header Row
        Item {
            id: headerRow
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            height: 48

            Row {
                anchors.fill: parent
                spacing: 14

                // Icon badge
                Rectangle {
                    width: 44
                    height: 44
                    radius: Theme.radiusMd
                    color: Theme.primaryContainer
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰸉"
                        color: Theme.cOnPrimaryContainer
                        font.family: Theme.fontMono
                        font.pixelSize: 22
                    }
                }

                // Title & Subtitle
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    width: parent.width - 44 - 14 - searchWrap.width - 14 - actionButtons.width - 14

                    Text {
                        text: "Správce tapet"
                        color: Theme.cOnSurface
                        font.family: Theme.fontFamily
                        font.pixelSize: 19
                        font.bold: true
                    }

                    Text {
                        text: root.filteredWallpapers.length + " tapet k dispozici" + (root.applying ? " • Aplikuji tapetu..." : (root.isScanning ? " • Načítám..." : ""))
                        color: root.applying ? Theme.primary : Theme.outline
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                }

                // Search Bar
                Rectangle {
                    id: searchWrap
                    width: 240
                    height: 38
                    radius: Theme.radiusFull
                    color: Theme.surfaceContainerHighest
                    border.color: searchField.activeFocus ? Theme.primary : "transparent"
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
                            id: searchField
                            focus: true
                            width: parent.width - 28
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            color: Theme.cOnSurface
                            selectByMouse: true
                            onTextChanged: root.searchText = text

                            Text {
                                text: "Hledat tapetu..."
                                color: Theme.outline
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                visible: !searchField.text && !searchField.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Keys.onEscapePressed: root.close()
                            Keys.onReturnPressed: {
                                if (root.filteredWallpapers.length > 0) {
                                    root.applyWallpaper(root.filteredWallpapers[0].path);
                                }
                            }
                        }
                    }
                }

                // Action buttons: Random, Dolphin, Close
                Row {
                    id: actionButtons
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter

                    // Random wallpaper button
                    Rectangle {
                        width: 110
                        height: 38
                        radius: Theme.radiusFull
                        color: randomArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                        border.color: Theme.outlineVariant
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: "󰒝"
                                color: Theme.primary
                                font.family: Theme.fontMono
                                font.pixelSize: 15
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Náhodná"
                                color: Theme.cOnSurface
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: randomArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyRandom()
                        }
                    }

                    // Open in Dolphin button
                    Rectangle {
                        width: 40
                        height: 38
                        radius: Theme.radiusFull
                        color: dolphinArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                        border.color: Theme.outlineVariant
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "󰉋"
                            color: Theme.cOnSurface
                            font.family: Theme.fontMono
                            font.pixelSize: 16
                        }

                        MouseArea {
                            id: dolphinArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.openFolder()
                        }
                    }

                    // Close button
                    Rectangle {
                        width: 38
                        height: 38
                        radius: Theme.radiusFull
                        color: closeArea.containsMouse ? Theme.surfaceContainerHighest : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: Theme.cOnSurface
                            font.family: Theme.fontMono
                            font.pixelSize: 18
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.close()
                        }
                    }
                }
            }
        }

        // Category Filter Chips
        Item {
            id: categoryRow
            anchors.top: headerRow.bottom
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            height: 32

            Row {
                anchors.fill: parent
                spacing: 8

                readonly property var categories: ["Všechny", "Moje tapety", "Wallpaper Bank", "Sedly Rice"]

                Repeater {
                    model: parent.categories

                    Rectangle {
                        id: chip
                        height: 30
                        width: chipLabel.implicitWidth + 24
                        radius: Theme.radiusFull
                        color: root.selectedCategory === modelData ? Theme.primary : Theme.surfaceContainerHighest
                        border.color: root.selectedCategory === modelData ? Theme.primary : Theme.outlineVariant
                        border.width: 1

                        Text {
                            id: chipLabel
                            anchors.centerIn: parent
                            text: modelData
                            color: root.selectedCategory === modelData ? Theme.cOnPrimary : Theme.cOnSurface
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: root.selectedCategory === modelData
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectedCategory = modelData
                        }
                    }
                }
            }
        }

        // Wallpaper Grid
        Rectangle {
            id: gridWrap
            anchors.top: categoryRow.bottom
            anchors.topMargin: 14
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            radius: Theme.radiusMd
            color: Theme.surface
            border.color: Theme.outlineVariant
            border.width: 1
            clip: true

            GridView {
                id: grid
                anchors.fill: parent
                anchors.margins: 12
                cellWidth: Math.floor(grid.width / 4)
                cellHeight: 160
                clip: true
                model: root.filteredWallpapers

                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: ScrollBar.AsNeeded
                }

                delegate: Item {
                    width: grid.cellWidth
                    height: grid.cellHeight

                    readonly property bool isSelected: modelData.path === root.currentWallpaper

                    Rectangle {
                        id: tile
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: Theme.radiusMd
                        color: Theme.surfaceContainerHighest
                        border.width: isSelected ? 2.5 : (tileArea.containsMouse ? 1.5 : 1)
                        border.color: isSelected ? Theme.primary : (tileArea.containsMouse ? Theme.primaryContainer : Theme.outlineVariant)
                        clip: true

                        scale: tileArea.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        // Thumbnail Image
                        Image {
                            id: thumb
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: parent.height - 34
                            fillMode: Image.PreserveAspectCrop
                            source: "file://" + modelData.path
                            asynchronous: true
                            cache: true
                            sourceSize.width: 300
                            sourceSize.height: 170

                            Rectangle {
                                anchors.fill: parent
                                color: Theme.surfaceContainerHigh
                                visible: thumb.status !== Image.Ready
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰋩"
                                    color: Theme.outline
                                    font.family: Theme.fontMono
                                    font.pixelSize: 22
                                }
                            }
                        }

                        // Active checkmark badge
                        Rectangle {
                            visible: isSelected
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 6
                            width: 22
                            height: 22
                            radius: 11
                            color: Theme.primary

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                color: Theme.cOnPrimary
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }

                        // Filename Bar
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 34
                            color: isSelected ? Theme.primaryContainer : Theme.surfaceContainerHigh

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                verticalAlignment: Text.AlignVCenter
                                text: modelData.name
                                color: isSelected ? Theme.cOnPrimaryContainer : Theme.cOnSurface
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: isSelected
                                elide: Text.ElideMiddle
                            }
                        }

                        MouseArea {
                            id: tileArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.applyWallpaper(modelData.path);
                            }
                        }
                    }
                }

                // Empty state message
                Text {
                    anchors.centerIn: parent
                    visible: (!root.filteredWallpapers || root.filteredWallpapers.length === 0) && !root.isScanning
                    text: "Žádné tapety neodpovídají filtru"
                    color: Theme.outline
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                }
            }
        }
    }

    Component.onCompleted: {
        root.refreshWallpapers();
        currentWallFile.reload();
    }
}
