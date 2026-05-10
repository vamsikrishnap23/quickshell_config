import QtQuick
import Quickshell

import "../styles"

Row {
    width: parent.width
    spacing: 12

    property bool toggleWifi: true
    property bool toggleBt: true
    property bool togglePower: false
    property bool toggleDnd: false

    // Wi-Fi
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
            onClicked: toggleWifi = !toggleWifi
        }
    }

    // Bluetooth
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
            onClicked: toggleBt = !toggleBt
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
            onClicked: toggleDnd = !toggleDnd
        }
    }
}