import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

import "../styles"
import "../components"

PanelWindow {
    // Force the window to cover the entire screen
    anchors {
        top: true; bottom: true
        left: true; right: true
    }
    
    // Dark, semi-transparent background
    color: Qt.rgba(0, 0, 0, 0.75)
    
    // Listen to our global state
    visible: GlobalState.showPowermenu

    // ------------------------------------------
    // SYSTEM COMMANDS
    // ------------------------------------------
    Process { id: cmdShutdown; command: ["systemctl", "poweroff"] }
    Process { id: cmdReboot; command: ["systemctl", "reboot"] }
    Process { id: cmdLogout; command: ["hyprctl", "dispatch", "exit"] }

    // ------------------------------------------
    // UI LAYOUT
    // ------------------------------------------
    
    // Clicking anywhere in the background closes the menu
    MouseArea {
        anchors.fill: parent
        onClicked: GlobalState.showPowermenu = false
    }

    Row {
        anchors.centerIn: parent
        spacing: 30

        // Shutdown Button
        Pill {
            implicitWidth: 120; implicitHeight: 120
            Text { 
                anchors.centerIn: parent; text: "󰐥"
                color: Theme.primary; font.pixelSize: 48; font.family: "JetBrainsMono Nerd Font" 
            }
            MouseArea {
                anchors.fill: parent
                onClicked: cmdShutdown.running = true
            }
        }

        // Reboot Button
        Pill {
            implicitWidth: 120; implicitHeight: 120
            Text { 
                anchors.centerIn: parent; text: "󰑓"
                color: Theme.text; font.pixelSize: 48; font.family: "JetBrainsMono Nerd Font" 
            }
            MouseArea {
                anchors.fill: parent
                onClicked: cmdReboot.running = true
            }
        }

        // Logout Button
        Pill {
            implicitWidth: 120; implicitHeight: 120
            Text { 
                anchors.centerIn: parent; text: "󰍃"
                color: Theme.text; font.pixelSize: 48; font.family: "JetBrainsMono Nerd Font" 
            }
            MouseArea {
                anchors.fill: parent
                onClicked: cmdLogout.running = true1
            }
        }
    }
}