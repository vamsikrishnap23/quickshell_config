import QtQuick
import Quickshell
import Qt5Compat.GraphicalEffects

import "../styles"
import "../state"

Item {
    width: parent.width
    height: 50

    // Left Side: Avatar and Username
    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        // Avatar Container
        Item {
            width: 50
            height: 50

            Image {
                id: avatarImage
                anchors.fill: parent
                source: "file:///home/vamsi/global_image/avatar.jpeg"
                fillMode: Image.PreserveAspectCrop
                visible: false
            }

            Rectangle {
                id: circleMask
                anchors.fill: parent
                radius: 25
                visible: false
            }

            OpacityMask {
                anchors.fill: parent
                source: avatarImage
                maskSource: circleMask
            }

            Rectangle {
                anchors.fill: parent
                radius: 25
                color: "transparent"
                border.color: Theme.border
                border.width: 1
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Quickshell.env("USER")
            color: Theme.text
            font.pixelSize: 22
            font.bold: true
        }
    }

    // Right Side: Settings, Light/Dark, & Power Buttons
    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        // Settings Button
        Rectangle {
            width: 36
            height: 36
            radius: 18
            color: Theme.surface
            border.color: Theme.border
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "󰒓"
                color: Theme.textDim
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
            }
        }

        // NEW: Light/Dark Mode Toggle Button
        Rectangle {
            width: 36
            height: 36
            radius: 18
            color: Theme.surface
            border.color: Theme.border
            border.width: 1

            Text {
                anchors.centerIn: parent
                // 󰖔 = Moon (Dark mode active) | 󰖨 = Sun (Light mode active)
                text: GlobalState.isDarkMode ? "󰖔" : "󰖨" 
                color: Theme.text
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // Instantly flips the entire UI!
                    GlobalState.isDarkMode = !GlobalState.isDarkMode
                }
            }
        }

        // Power Button
        Rectangle {
            width: 36
            height: 36
            radius: 18
            color: Theme.surface
            border.color: Theme.border
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "󰐥"
                color: "#f38ba8"
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    GlobalState.showControlCenter = false
                    GlobalState.showPowermenu = true
                }
            }
        }
    }
}