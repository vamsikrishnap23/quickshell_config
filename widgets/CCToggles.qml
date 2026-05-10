import QtQuick
import Quickshell
import Quickshell.Io

import "../styles"

Row {
    width: parent.width
    spacing: 12

    property bool toggleWifi: true
    property bool toggleBt: true
    property bool togglePower: false
    property bool toggleDnd: false

    // 2. Fetch the actual Wi-Fi state on widget load
    Process {
        id: wifiStateCheck
        command: ["nmcli", "radio", "wifi"]
        running: true // Runs automatically when Control Center mounts
        stdout: SplitParser {
            onRead: data => {
                // NetworkManager returns "enabled" or "disabled"
                toggleWifi = (data.trim() === "enabled")
            }
        }
    }

    // 3. Process to handle the actual switching
    Process { 
        id: wifiToggleProcess 
    }

    Rectangle {
        width: (parent.width - 36) / 4
        height: 70
        radius: 18
        color: toggleWifi ? Theme.primary : Theme.surface
        border.color: toggleWifi ? Theme.primary : Theme.border
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 4
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                // 󰤨 = md-wifi (On) | 󰤭 = md-wifi_off (Off)
                text: toggleWifi ? "󰤨" : "󰤭"
                color: toggleWifi ? "#111111" : Theme.text
                font.pixelSize: 24
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: toggleWifi ? "Wi-Fi" : "Off"
                color: toggleWifi ? "#111111" : Theme.textDim
                font.pixelSize: 11
                font.bold: toggleWifi
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                // 4. Invert state and run the nmcli command
                toggleWifi = !toggleWifi
                wifiToggleProcess.command = ["nmcli", "radio", "wifi", toggleWifi ? "on" : "off"]
                wifiToggleProcess.running = true
            }
        }
    }

    // Bluetooth
    // 1. Fetch the actual Bluetooth state on widget load
    Process {
        id: btStateCheck
        command: ["sh", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 'on' || echo 'off'"]
        running: true // Runs automatically when Control Center mounts
        stdout: SplitParser {
            onRead: data => {
                toggleBt = (data.trim() === "on")
            }
        }
    }

    // 2. Process to handle the actual BT switching
    Process { 
        id: btToggleProcess 
    }

    // Bluetooth Button UI
    Rectangle {
        width: (parent.width - 36) / 4
        height: 70
        radius: 18
        color: toggleBt ? Theme.primary : Theme.surface
        border.color: toggleBt ? Theme.primary : Theme.border
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 4
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: toggleBt ? "󰂯" : "󰂲"
                color: toggleBt ? "#111111" : Theme.text
                font.pixelSize: 24
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: toggleBt ? "On" : "Off"
                color: toggleBt ? "#111111" : Theme.textDim
                font.pixelSize: 11
                font.bold: toggleBt
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                // 3. Invert state and run the bluetoothctl command
                toggleBt = !toggleBt
                btToggleProcess.command = ["bluetoothctl", "power", toggleBt ? "on" : "off"]
                btToggleProcess.running = true
            }
        }
    }

    // Power Profile
    Rectangle {
        width: (parent.width - 36) / 4
        height: 70
        radius: 18
        color: togglePower ? Theme.primary : Theme.surface
        border.color: togglePower ? Theme.primary : Theme.border
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 4
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "󰚥"
                color: togglePower ? "#111111" : Theme.text
                font.pixelSize: 24
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: togglePower ? "Perform" : "Auto"
                color: togglePower ? "#111111" : Theme.textDim
                font.pixelSize: 11
                font.bold: togglePower
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: togglePower = !togglePower
        }
    }

    // DND
    // 1. Fetch the actual DND state from SwayNC
    Process {
        id: dndStateCheck
        command: ["swaync-client", "-D"]
        running: true 
        stdout: SplitParser {
            onRead: data => {
                // SwayNC outputs "true" when DND is active
                toggleDnd = (data.trim() === "true")
            }
        }
    }

    // 2. Process to handle the actual DND switching
    Process { 
        id: dndToggleProcess 
    }

    // Do Not Disturb (DND) Button UI
    Rectangle {
        width: (parent.width - 36) / 4
        height: 70
        radius: 18
        color: toggleDnd ? Theme.primary : Theme.surface
        border.color: toggleDnd ? Theme.primary : Theme.border
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 4
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                // 󰂛 = md-bell_off | 󰂚 = md-bell
                text: toggleDnd ? "󰂛" : "󰂚"
                color: toggleDnd ? "#111111" : Theme.text
                font.pixelSize: 24
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: toggleDnd ? "DND" : "Notify"
                color: toggleDnd ? "#111111" : Theme.textDim
                font.pixelSize: 11
                font.bold: toggleDnd
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                // 3. Invert UI state immediately for responsiveness
                toggleDnd = !toggleDnd
                
                // 4. Run the SwayNC toggle command
                dndToggleProcess.command = ["swaync-client", "-d"]
                dndToggleProcess.running = true
            }
        }
    }
}