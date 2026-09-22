import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
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

    // State properties
    property bool wifiConnected: false
    property bool wifiEnabled: true
    property string wifiSsid: "Odpojeno"
    property bool wifiExpanded: false
    property var wifiNetworks: []

    property bool btEnabled: false
    property bool btConnected: false
    property string btName: "Vypnuto"
    property bool btExpanded: false
    property var btDevices: []

    property bool nightLightActive: false
    property bool dndActive: false

    property int volumeLevel: 50
    property bool volumeMuted: false

    property int brightnessLevel: 65

    property int batteryLevel: 100
    property bool batteryCharging: false
    property bool hasBattery: false

    property string activePowerProfile: "powersave"
    property string uptimeStr: ""

    function toggle() {
        if (root.visible) root.close();
        else root.open();
    }

    function open() {
        root.visible = true;
        root.refreshAll();
    }

    function close() {
        root.visible = false;
        root.wifiExpanded = false;
        root.btExpanded = false;
    }

    function refreshAll() {
        statusProc.running = false;
        statusProc.running = true;
        pwrProfileQueryProc.running = false;
        pwrProfileQueryProc.running = true;
        if (root.wifiExpanded) refreshWifiScan();
        if (root.btExpanded) refreshBtScan();
    }

    function refreshWifiScan() {
        wifiScanProc.running = false;
        wifiScanProc.running = true;
    }

    function refreshBtScan() {
        btScanProc.running = false;
        btScanProc.running = true;
    }

    // Process to query all status values in one fast script
    Process {
        id: statusProc
        command: [
            "bash", "-c",
            "ssid=$(nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null | awk -F: '$1==\"wifi\" && $2==\"connected\"{print $3}'); " +
            "radio=$(nmcli radio wifi 2>/dev/null || echo 'disabled'); " +
            "btpow=$(bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{print $2}'); " +
            "btdev=$(bluetoothctl info 2>/dev/null | grep 'Name:' | cut -d' ' -f2-); " +
            "nl=$(pgrep -x hyprsunset >/dev/null && echo 'on' || echo 'off'); " +
            "vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo 'Volume: 0.50'); " +
            "br=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo '50'); " +
            "up=$(uptime -p 2>/dev/null | sed 's/up //; s/ hours\\?,/h/; s/ minutes\\?/m/' || echo ''); " +
            "bat_cap=''; bat_stat=''; " +
            "if [ -d /sys/class/power_supply/BAT* ]; then " +
            "  bat_cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo ''); " +
            "  bat_stat=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1 || echo ''); " +
            "fi; " +
            "echo \"WIFI_SSID=$ssid\"; " +
            "echo \"WIFI_RADIO=$radio\"; " +
            "echo \"BT_POW=$btpow\"; " +
            "echo \"BT_DEV=$btdev\"; " +
            "echo \"NL=$nl\"; " +
            "echo \"VOL=$vol\"; " +
            "echo \"BR=$br\"; " +
            "echo \"UP=$up\"; " +
            "echo \"BAT_CAP=$bat_cap\"; " +
            "echo \"BAT_STAT=$bat_stat\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const textData = this.text ? this.text.trim() : "";
                if (!textData) return;

                const lines = textData.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    const l = lines[i];
                    if (l.startsWith("WIFI_SSID=")) {
                        const val = l.substring(10).trim();
                        root.wifiConnected = (val.length > 0);
                        root.wifiSsid = val.length > 0 ? val : "Odpojeno";
                    } else if (l.startsWith("WIFI_RADIO=")) {
                        root.wifiEnabled = (l.substring(11).trim() === "enabled");
                        if (!root.wifiEnabled) root.wifiSsid = "Vypnuto";
                    } else if (l.startsWith("BT_POW=")) {
                        root.btEnabled = (l.substring(7).trim() === "yes");
                        if (!root.btEnabled) root.btName = "Vypnuto";
                    } else if (l.startsWith("BT_DEV=")) {
                        const val = l.substring(7).trim();
                        root.btConnected = (val.length > 0);
                        if (root.btConnected) root.btName = val;
                        else if (root.btEnabled) root.btName = "Zapnuto";
                    } else if (l.startsWith("NL=")) {
                        root.nightLightActive = (l.substring(3).trim() === "on");
                    } else if (l.startsWith("VOL=")) {
                        const raw = l.substring(4);
                        root.volumeMuted = raw.indexOf("[MUTED]") !== -1;
                        const m = raw.match(/Volume:\s+([\d\.]+)/);
                        if (m) root.volumeLevel = Math.round(parseFloat(m[1]) * 100);
                    } else if (l.startsWith("BR=")) {
                        const val = parseInt(l.substring(3).trim(), 10);
                        if (!isNaN(val)) root.brightnessLevel = val;
                    } else if (l.startsWith("UP=")) {
                        root.uptimeStr = l.substring(3).trim();
                    } else if (l.startsWith("BAT_CAP=")) {
                        const cap = l.substring(8).trim();
                        if (cap.length > 0 && !isNaN(parseInt(cap, 10))) {
                            root.hasBattery = true;
                            root.batteryLevel = parseInt(cap, 10);
                        } else {
                            root.hasBattery = false;
                        }
                    } else if (l.startsWith("BAT_STAT=")) {
                        root.batteryCharging = (l.substring(9).trim() === "Charging");
                    }
                }
            }
        }
    }

    // Process to scan Wi-Fi networks
    Process {
        id: wifiScanProc
        command: ["bash", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null | awk -F: '$1!=\"\" && !seen[$1]++ {print $1\":\"$2\":\"$3}' | head -n 6"]
        stdout: StdioCollector {
            onStreamFinished: {
                const textData = this.text ? this.text.trim() : "";
                if (!textData) {
                    root.wifiNetworks = [];
                    return;
                }
                const lines = textData.split("\n");
                const list = [];
                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(":");
                    if (parts.length >= 2 && parts[0].length > 0) {
                        list.push({
                            ssid: parts[0],
                            signal: parseInt(parts[1], 10) || 50,
                            security: parts[2] || ""
                        });
                    }
                }
                root.wifiNetworks = list;
            }
        }
    }

    // Process to scan paired Bluetooth devices
    Process {
        id: btScanProc
        command: ["bash", "-c", "bluetoothctl devices 2>/dev/null | head -n 6"]
        stdout: StdioCollector {
            onStreamFinished: {
                const textData = this.text ? this.text.trim() : "";
                if (!textData) {
                    root.btDevices = [];
                    return;
                }
                const lines = textData.split("\n");
                const list = [];
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i].trim();
                    const m = line.match(/^Device\s+([0-9A-Fa-f:]+)\s+(.+)$/);
                    if (m) {
                        list.push({
                            mac: m[1],
                            name: m[2]
                        });
                    }
                }
                root.btDevices = list;
            }
        }
    }

    // Power Profile Query Process
    Process {
        id: pwrProfileQueryProc
        command: ["bash", "-c", "if command -v powerprofilesctl >/dev/null 2>&1; then powerprofilesctl get 2>/dev/null; else cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'powersave'; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = this.text ? this.text.trim() : "powersave";
                if (val.indexOf("performance") !== -1) root.activePowerProfile = "performance";
                else if (val.indexOf("balanced") !== -1) root.activePowerProfile = "balanced";
                else root.activePowerProfile = "powersave";
            }
        }
    }

    // Refresh timer when open
    Timer {
        interval: 3000
        repeat: true
        running: root.visible
        onTriggered: root.refreshAll()
    }

    // Actions
    function toggleWifi() {
        const cmd = root.wifiEnabled ? "nmcli radio wifi off" : "nmcli radio wifi on";
        Quickshell.execDetached(["bash", "-c", cmd]);
        root.wifiEnabled = !root.wifiEnabled;
        if (!root.wifiEnabled) {
            root.wifiConnected = false;
            root.wifiSsid = "Vypnuto";
            root.wifiExpanded = false;
        }
        delayRefresh.start();
    }

    function connectWifi(ssid) {
        Quickshell.execDetached(["bash", "-c", "nmcli dev wifi connect '" + ssid + "' 2>/dev/null || true"]);
        delayRefresh.start();
    }

    function toggleBluetooth() {
        const cmd = root.btEnabled ? "bluetoothctl power off" : "bluetoothctl power on";
        Quickshell.execDetached(["bash", "-c", cmd]);
        root.btEnabled = !root.btEnabled;
        if (!root.btEnabled) {
            root.btConnected = false;
            root.btName = "Vypnuto";
            root.btExpanded = false;
        }
        delayRefresh.start();
    }

    function toggleBtDevice(mac) {
        Quickshell.execDetached(["bash", "-c", "if bluetoothctl info " + mac + " 2>/dev/null | grep -q 'Connected: yes'; then bluetoothctl disconnect " + mac + "; else bluetoothctl connect " + mac + "; fi"]);
        delayRefresh.start();
    }

    function toggleNightLight() {
        if (root.nightLightActive) {
            Quickshell.execDetached(["killall", "hyprsunset"]);
            root.nightLightActive = false;
        } else {
            Quickshell.execDetached(["bash", "-c", "setsid hyprsunset -t 4500 </dev/null >/dev/null 2>&1 &"]);
            root.nightLightActive = true;
        }
        delayRefresh.start();
    }

    function toggleDnd() {
        root.dndActive = !root.dndActive;
    }

    function setPowerProfile(mode) {
        root.activePowerProfile = mode;
        const cmd = "if command -v powerprofilesctl >/dev/null 2>&1; then powerprofilesctl set " + mode + "; fi";
        Quickshell.execDetached(["bash", "-c", cmd]);
        delayRefresh.start();
    }

    function setVolume(pct) {
        root.volumeLevel = pct;
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct + "%"]);
    }

    function toggleMute() {
        root.volumeMuted = !root.volumeMuted;
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }

    function setBrightness(pct) {
        root.brightnessLevel = pct;
        Quickshell.execDetached(["brightnessctl", "set", pct + "%"]);
    }

    Timer {
        id: delayRefresh
        interval: 600
        repeat: false
        onTriggered: root.refreshAll()
    }

    // Dismiss on background click
    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    // Escape to close
    Item {
        focus: root.visible
        Keys.onEscapePressed: root.close()
    }

    // Main Card (Frosted Glass Island)
    Rectangle {
        id: card
        width: 380
        anchors.top: parent.top
        anchors.topMargin: 54
        anchors.right: parent.right
        anchors.rightMargin: 12
        height: Math.min(780, cardCol.implicitHeight + 36)
        radius: Theme.radiusLg
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.90)
        border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.5)
        border.width: 1
        clip: true

        // Smooth animations
        opacity: root.visible ? 1.0 : 0.0
        scale: root.visible ? 1.0 : 0.96
        y: root.visible ? 0 : -14
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        // Prevent click-through
        MouseArea {
            anchors.fill: parent
        }

        Flickable {
            id: flick
            anchors.fill: parent
            anchors.margins: 16
            contentWidth: width
            contentHeight: cardCol.implicitHeight
            clip: true

            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
            }

            Column {
                id: cardCol
                width: parent.width
                spacing: 14

                // 1. Header: User Info & Actions
                Row {
                    width: parent.width
                    height: 40
                    spacing: 10

                    // Avatar badge
                    Rectangle {
                        width: 40
                        height: 40
                        radius: Theme.radiusMd
                        color: Theme.primaryContainer
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "󰄛"
                            color: Theme.cOnPrimaryContainer
                            font.family: Theme.fontMono
                            font.pixelSize: 20
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 40 - 10 - headerActions.width - 10
                        spacing: 1

                        Text {
                            text: "sedly"
                            color: Theme.cOnSurface
                            font.family: Theme.fontFamily
                            font.pixelSize: 15
                            font.bold: true
                        }

                        Text {
                            text: root.uptimeStr.length > 0 ? ("Běh: " + root.uptimeStr) : "sedlyho-dell"
                            color: Theme.outline
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                    }

                    // Header Action Buttons
                    Row {
                        id: headerActions
                        spacing: 6
                        anchors.verticalCenter: parent.verticalCenter

                        // Cheatsheet button
                        Rectangle {
                            width: 34
                            height: 34
                            radius: 17
                            color: cheatBtnMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                            border.color: Theme.outlineVariant
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "󰌌"
                                color: Theme.primary
                                font.family: Theme.fontMono
                                font.pixelSize: 15
                            }

                            MouseArea {
                                id: cheatBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.close();
                                    cheatsheet.open();
                                }
                            }
                        }

                        // Lock button
                        Rectangle {
                            width: 34
                            height: 34
                            radius: 17
                            color: lockBtnMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                            border.color: Theme.outlineVariant
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "󰌾"
                                color: Theme.cOnSurface
                                font.family: Theme.fontMono
                                font.pixelSize: 14
                            }

                            MouseArea {
                                id: lockBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.close();
                                    Quickshell.execDetached(["loginctl", "lock-session"]);
                                }
                            }
                        }

                        // Power / Logout button
                        Rectangle {
                            width: 34
                            height: 34
                            radius: 17
                            color: pwrBtnMouse.containsMouse ? Theme.errorContainer : Theme.surfaceContainerHigh
                            border.color: pwrBtnMouse.containsMouse ? Theme.error : Theme.outlineVariant
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "󰐥"
                                color: pwrBtnMouse.containsMouse ? Theme.cOnErrorContainer : Theme.error
                                font.family: Theme.fontMono
                                font.pixelSize: 14
                            }

                            MouseArea {
                                id: pwrBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.close();
                                    Quickshell.execDetached(["sh", "-c", "command -v wlogout >/dev/null && wlogout -p layer-shell || hyprctl dispatch exit"]);
                                }
                            }
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

                // 2. Quick Toggles Grid (2x2)
                Grid {
                    width: parent.width
                    columns: 2
                    spacing: 10

                    // Wi-Fi Toggle
                    QuickToggle {
                        width: Math.floor((parent.width - 10) / 2)
                        icon: root.wifiConnected ? "󰖩" : (root.wifiEnabled ? "󰖪" : "󰖪")
                        title: "Wi-Fi"
                        subtitle: root.wifiSsid
                        active: root.wifiConnected
                        expandable: true
                        expanded: root.wifiExpanded
                        onClicked: root.toggleWifi()
                        onChevronClicked: {
                            root.wifiExpanded = !root.wifiExpanded;
                            if (root.wifiExpanded) root.refreshWifiScan();
                        }
                    }

                    // Bluetooth Toggle
                    QuickToggle {
                        width: Math.floor((parent.width - 10) / 2)
                        icon: root.btConnected ? "󰂱" : (root.btEnabled ? "󰂯" : "󰂲")
                        title: "Bluetooth"
                        subtitle: root.btName
                        active: root.btConnected || root.btEnabled
                        activeColor: Theme.secondary
                        cOnActiveColor: Theme.cOnSecondary
                        expandable: true
                        expanded: root.btExpanded
                        onClicked: root.toggleBluetooth()
                        onChevronClicked: {
                            root.btExpanded = !root.btExpanded;
                            if (root.btExpanded) root.refreshBtScan();
                        }
                    }

                    // Night Light Toggle
                    QuickToggle {
                        width: Math.floor((parent.width - 10) / 2)
                        icon: "󰛨"
                        title: "Noční světlo"
                        subtitle: root.nightLightActive ? "4500K" : "Vypnuto"
                        active: root.nightLightActive
                        activeColor: Theme.tertiary
                        cOnActiveColor: Theme.cOnTertiary
                        onClicked: root.toggleNightLight()
                    }

                    // DND Toggle
                    QuickToggle {
                        width: Math.floor((parent.width - 10) / 2)
                        icon: root.dndActive ? "󰂛" : "󰂚"
                        title: "Režim nerušit"
                        subtitle: root.dndActive ? "Aktivní" : "Vypnuto"
                        active: root.dndActive
                        activeColor: Theme.error
                        cOnActiveColor: Theme.cOnError
                        onClicked: root.toggleDnd()
                    }
                }

                // 2a. Wi-Fi Networks Flyout (if expanded)
                Rectangle {
                    visible: root.wifiExpanded
                    width: parent.width
                    implicitHeight: wifiCol.implicitHeight + 16
                    radius: Theme.radiusMd
                    color: Theme.surfaceContainerHigh
                    border.color: Theme.outlineVariant
                    border.width: 1
                    clip: true

                    Column {
                        id: wifiCol
                        anchors.top: parent.top
                        anchors.topMargin: 8
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        spacing: 6

                        Row {
                            width: parent.width
                            height: 22

                            Text {
                                text: "Dostupné sítě Wi-Fi"
                                color: Theme.primary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item { width: parent.width - 120 - 40; height: 1 }

                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: scanHover.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰑐"
                                    color: Theme.primary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 12
                                }

                                MouseArea {
                                    id: scanHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.refreshWifiScan()
                                }
                            }
                        }

                        Repeater {
                            model: root.wifiNetworks

                            delegate: Rectangle {
                                width: wifiCol.width
                                height: 32
                                radius: Theme.radiusSm
                                color: netHover.containsMouse ? Theme.surfaceContainerHighest : "transparent"

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Text {
                                        text: modelData.signal >= 75 ? "󰖩" : (modelData.signal >= 50 ? "󰖩" : "󰖪")
                                        color: Theme.primary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 13
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.ssid
                                        color: (modelData.ssid === root.wifiSsid) ? Theme.primary : Theme.cOnSurface
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        font.bold: (modelData.ssid === root.wifiSsid)
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 60
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.security.length > 0 ? "󰌾" : ""
                                        color: Theme.outline
                                        font.family: Theme.fontMono
                                        font.pixelSize: 11
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    id: netHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.connectWifi(modelData.ssid)
                                }
                            }
                        }

                        Text {
                            visible: root.wifiNetworks.length === 0
                            text: "Skenuji okolní sítě..."
                            color: Theme.outline
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                    }
                }

                // 2b. Bluetooth Devices Flyout (if expanded)
                Rectangle {
                    visible: root.btExpanded
                    width: parent.width
                    implicitHeight: btCol.implicitHeight + 16
                    radius: Theme.radiusMd
                    color: Theme.surfaceContainerHigh
                    border.color: Theme.outlineVariant
                    border.width: 1
                    clip: true

                    Column {
                        id: btCol
                        anchors.top: parent.top
                        anchors.topMargin: 8
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        spacing: 6

                        Row {
                            width: parent.width
                            height: 22

                            Text {
                                text: "Spárovaná zařízení"
                                color: Theme.secondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Repeater {
                            model: root.btDevices

                            delegate: Rectangle {
                                width: btCol.width
                                height: 32
                                radius: Theme.radiusSm
                                color: devHover.containsMouse ? Theme.surfaceContainerHighest : "transparent"

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Text {
                                        text: "󰋋"
                                        color: Theme.secondary
                                        font.family: Theme.fontMono
                                        font.pixelSize: 13
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.name
                                        color: Theme.cOnSurface
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 40
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: devHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.toggleBtDevice(modelData.mac)
                                }
                            }
                        }

                        Text {
                            visible: root.btDevices.length === 0
                            text: "Žádná spárovaná zařízení"
                            color: Theme.outline
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
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

                // 3. Interactive Sliders Section
                Column {
                    width: parent.width
                    spacing: 8

                    // Volume Slider
                    SliderRow {
                        width: parent.width
                        icon: {
                            if (root.volumeMuted) return "󰝟";
                            if (root.volumeLevel >= 60) return "󰕾";
                            if (root.volumeLevel >= 25) return "󰖀";
                            return "󰕿";
                        }
                        value: root.volumeLevel
                        isMuted: root.volumeMuted
                        accentColor: Theme.primary
                        cOnAccent: Theme.cOnPrimary
                        onValueChangedByUser: (val) => root.setVolume(val)
                        onIconClicked: root.toggleMute()
                    }

                    // Brightness Slider
                    SliderRow {
                        width: parent.width
                        icon: root.brightnessLevel >= 60 ? "󰃠" : (root.brightnessLevel >= 30 ? "󰃟" : "󰃞")
                        value: root.brightnessLevel
                        isMuted: false
                        accentColor: Theme.tertiary
                        cOnAccent: Theme.cOnTertiary
                        onValueChangedByUser: (val) => root.setBrightness(val)
                    }
                }

                // 4. Power Profile Mode Selector
                Row {
                    width: parent.width
                    height: 36
                    spacing: 8

                    readonly property var profiles: [
                        { id: "powersave", name: "Úspora", icon: "󰌪" },
                        { id: "balanced", name: "Vyvážený", icon: "󰾆" },
                        { id: "performance", name: "Výkon", icon: "󰓅" }
                    ]

                    Repeater {
                        model: parent.profiles

                        Rectangle {
                            width: Math.floor((parent.width - 16) / 3)
                            height: 34
                            radius: Theme.radiusFull
                            readonly property bool isSelected: root.activePowerProfile === modelData.id
                            color: isSelected ? Theme.primary : (profMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh)
                            border.color: isSelected ? Theme.primary : Theme.outlineVariant
                            border.width: 1

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: modelData.icon
                                    color: parent.parent.isSelected ? Theme.cOnPrimary : Theme.primary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.name
                                    color: parent.parent.isSelected ? Theme.cOnPrimary : Theme.cOnSurface
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: parent.parent.isSelected
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: profMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.setPowerProfile(modelData.id)
                            }
                        }
                    }
                }

                // 5. Media Player Card with Album Art
                Rectangle {
                    id: mediaCard
                    width: parent.width
                    height: 74
                    radius: Theme.radiusMd
                    color: Theme.surfaceContainerHigh
                    border.color: Theme.outlineVariant
                    border.width: 1
                    visible: !!mediaPlayer.activePlayer && mediaPlayer.trackTitle.length > 0

                    Item {
                        id: mediaPlayer
                        readonly property var activePlayer: {
                            for (const p of Mpris.players.values) {
                                if (p.trackTitle && p.trackTitle.length > 0) return p;
                            }
                            return null;
                        }
                        readonly property string trackTitle: activePlayer ? activePlayer.trackTitle : ""
                        readonly property string trackArtist: activePlayer ? (activePlayer.trackArtists ? activePlayer.trackArtists.join(", ") : "") : ""
                        readonly property string trackArtUrl: activePlayer ? (activePlayer.trackArtUrl || "") : ""
                        readonly property bool isPlaying: activePlayer ? activePlayer.playbackState === MprisPlaybackState.Playing : false
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        // Music Album Art or Icon badge
                        Rectangle {
                            width: 54
                            height: 54
                            radius: Theme.radiusSm
                            color: Theme.secondaryContainer
                            clip: true
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: cardArt
                                anchors.fill: parent
                                source: mediaPlayer.trackArtUrl
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: mediaPlayer.trackArtUrl.length > 0 && status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰝚"
                                color: Theme.cOnSecondaryContainer
                                font.family: Theme.fontMono
                                font.pixelSize: 24
                                visible: !cardArt.visible
                            }
                        }

                        // Track & Artist text
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 54 - 12 - mediaControls.width - 12
                            spacing: 2

                            Text {
                                text: mediaPlayer.trackTitle
                                color: Theme.cOnSurface
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: mediaPlayer.trackArtist.length > 0 ? mediaPlayer.trackArtist : "Neznámý interpret"
                                color: Theme.outline
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        // Controls: Prev, Play/Pause, Next
                        Row {
                            id: mediaControls
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter

                            // Prev
                            Rectangle {
                                width: 28
                                height: 28
                                radius: 14
                                color: prevMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰒮"
                                    color: Theme.cOnSurface
                                    font.family: Theme.fontMono
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: prevMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (mediaPlayer.activePlayer) mediaPlayer.activePlayer.previous();
                                    }
                                }
                            }

                            // Play/Pause
                            Rectangle {
                                width: 34
                                height: 34
                                radius: 17
                                color: Theme.primary
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: mediaPlayer.isPlaying ? "󰏤" : "󰐊"
                                    color: Theme.cOnPrimary
                                    font.family: Theme.fontMono
                                    font.pixelSize: 16
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (mediaPlayer.activePlayer) mediaPlayer.activePlayer.playPause();
                                    }
                                }
                            }

                            // Next
                            Rectangle {
                                width: 28
                                height: 28
                                radius: 14
                                color: nextMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰒭"
                                    color: Theme.cOnSurface
                                    font.family: Theme.fontMono
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: nextMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (mediaPlayer.activePlayer) mediaPlayer.activePlayer.next();
                                    }
                                }
                            }
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

                // 6. Bottom Shortcuts & Battery
                Row {
                    width: parent.width
                    height: 36
                    spacing: 8

                    // Battery status pill (if present)
                    Rectangle {
                        visible: root.hasBattery
                        height: 34
                        width: batContentRow.implicitWidth + 20
                        radius: Theme.radiusFull
                        color: Theme.surfaceContainerHighest
                        border.color: Theme.outlineVariant
                        border.width: 1

                        Row {
                            id: batContentRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: {
                                    if (root.batteryCharging) return "󰂄";
                                    if (root.batteryLevel >= 80) return "󰁹";
                                    if (root.batteryLevel >= 50) return "󰁾";
                                    if (root.batteryLevel >= 20) return "󰁼";
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
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Item {
                        // Spacer
                        width: parent.width - (root.hasBattery ? (batContentRow.implicitWidth + 20) : 0) - (3 * 34 + 3 * 8)
                        height: 1
                    }

                    // Wallpaper shortcut
                    Rectangle {
                        width: 34
                        height: 34
                        radius: 17
                        color: wallBtnMouse.containsMouse ? Theme.primaryContainer : Theme.surfaceContainerHighest
                        border.color: Theme.outlineVariant
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "󰸉"
                            color: wallBtnMouse.containsMouse ? Theme.cOnPrimaryContainer : Theme.primary
                            font.family: Theme.fontMono
                            font.pixelSize: 15
                        }

                        MouseArea {
                            id: wallBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.close();
                                wallpaperPicker.open();
                            }
                        }
                    }

                    // Dolphin shortcut
                    Rectangle {
                        width: 34
                        height: 34
                        radius: 17
                        color: dolBtnMouse.containsMouse ? Theme.primaryContainer : Theme.surfaceContainerHighest
                        border.color: Theme.outlineVariant
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "󰉋"
                            color: dolBtnMouse.containsMouse ? Theme.cOnPrimaryContainer : Theme.cOnSurface
                            font.family: Theme.fontMono
                            font.pixelSize: 15
                        }

                        MouseArea {
                            id: dolBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.close();
                                Quickshell.execDetached(["dolphin"]);
                            }
                        }
                    }

                    // Kitty shortcut
                    Rectangle {
                        width: 34
                        height: 34
                        radius: 17
                        color: termBtnMouse.containsMouse ? Theme.primaryContainer : Theme.surfaceContainerHighest
                        border.color: Theme.outlineVariant
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "󰞷"
                            color: termBtnMouse.containsMouse ? Theme.cOnPrimaryContainer : Theme.cOnSurface
                            font.family: Theme.fontMono
                            font.pixelSize: 15
                        }

                        MouseArea {
                            id: termBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.close();
                                Quickshell.execDetached(["kitty"]);
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        root.refreshAll();
    }
}
