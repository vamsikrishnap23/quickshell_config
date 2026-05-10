import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick.Controls
import Quickshell.Io
import Qt5Compat.GraphicalEffects

import "../styles"
import "../state"

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top

    anchors {
        top: true
        right: true
    }

    margins {
        top: 14
        right: 14
    }

    implicitWidth: 380
    implicitHeight: 600

    color: "transparent"
    visible: GlobalState.showControlCenter

    // Temporary states for quick toggles (to be wired to real services later)
    property bool toggleWifi: true
    property bool toggleBt: true
    property bool togglePower: false
    property bool toggleDnd: false
    property int brightnessValue: 80

    // Focus grabber for Escape key closing
    Item {
        anchors.fill: parent
        focus: root.visible
        Keys.onEscapePressed: GlobalState.showControlCenter = false
    }

    // Brightness backend
    Process {
        id: brightnessProcess
        command: ["sh", "-c", "brightnessctl -m | cut -d',' -f4 | tr -d '%'"]
        stdout: SplitParser {
            onRead: data => {
                const value = parseInt(data)
                if (!isNaN(value)) root.brightnessValue = value
            }
        }
    }
    Process { id: brightnessSetProcess }

    onVisibleChanged: {
        if (visible) brightnessProcess.running = true
    }

    // Main Panel Background
    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 28
        color: Theme.background
        border.color: Theme.border
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 24

            // =================================
            // 1. HEADER (User Profile)
            // =================================
            Item {
                width: parent.width
                height: 50 

                // Left Side: Avatar and Username
                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    // Avatar Background / Container
                    // Avatar Container
                    Item {
                        width: 50
                        height: 50

                        // 1. The actual image (hidden, used only as source for the mask)
                        Image {
                            id: avatarImage
                            anchors.fill: parent
                            source: "file:///home/vamsi/global_image/avatar.jpeg"
                            fillMode: Image.PreserveAspectCrop
                            visible: false 
                        }

                        // 2. The circle shape we want to cut out (hidden, used as mask)
                        Rectangle {
                            id: circleMask
                            anchors.fill: parent
                            radius: 25
                            visible: false
                        }

                        // 3. The effect that crops the image into the circle
                        OpacityMask {
                            anchors.fill: parent
                            source: avatarImage
                            maskSource: circleMask
                        }

                        // 4. The border ring drawn on top
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

                // Right Side: Settings & Power Buttons
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    // Settings / Layout Button
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: Theme.surface
                        border.color: Theme.border
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "󰒓" // Settings gear icon
                            color: Theme.textDim
                            font.pixelSize: 18
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            // Add logic here later for settings
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
                            text: "󰐥" // Power icon
                            color: "#f38ba8" // Redish color for power
                            font.pixelSize: 18
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Close Control Center and open your Powermenu!
                                GlobalState.showControlCenter = false
                                GlobalState.showPowermenu = true
                            }
                        }
                    }
                }
            }

            // =================================
            // 2. QUICK TOGGLES
            // =================================
            Row {
                width: parent.width
                spacing: 12

                // Wi-Fi
                Rectangle {
                    width: (parent.width - 36) / 4
                    height: 70
                    radius: 18
                    color: root.toggleWifi ? Theme.primary : Theme.surface
                    border.color: root.toggleWifi ? Theme.primary : Theme.border
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.toggleWifi ? "󰤨" : "󰤭"
                            color: root.toggleWifi ? "#111111" : Theme.text
                            font.pixelSize: 24
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.toggleWifi ? "Wi-Fi" : "Off"
                            color: root.toggleWifi ? "#111111" : Theme.textDim
                            font.pixelSize: 11
                            font.bold: root.toggleWifi
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleWifi = !root.toggleWifi
                    }
                }

                // Bluetooth
                Rectangle {
                    width: (parent.width - 36) / 4
                    height: 70
                    radius: 18
                    color: root.toggleBt ? Theme.primary : Theme.surface
                    border.color: root.toggleBt ? Theme.primary : Theme.border
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.toggleBt ? "󰂯" : "󰂲"
                            color: root.toggleBt ? "#111111" : Theme.text
                            font.pixelSize: 24
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.toggleBt ? "On" : "Off"
                            color: root.toggleBt ? "#111111" : Theme.textDim
                            font.pixelSize: 11
                            font.bold: root.toggleBt
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleBt = !root.toggleBt
                    }
                }

                // Power Profile
                Rectangle {
                    width: (parent.width - 36) / 4
                    height: 70
                    radius: 18
                    color: root.togglePower ? Theme.primary : Theme.surface
                    border.color: root.togglePower ? Theme.primary : Theme.border
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰚥"
                            color: root.togglePower ? "#111111" : Theme.text
                            font.pixelSize: 24
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.togglePower ? "Perform" : "Auto"
                            color: root.togglePower ? "#111111" : Theme.textDim
                            font.pixelSize: 11
                            font.bold: root.togglePower
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.togglePower = !root.togglePower
                    }
                }

                // DND
                Rectangle {
                    width: (parent.width - 36) / 4
                    height: 70
                    radius: 18
                    color: root.toggleDnd ? Theme.primary : Theme.surface
                    border.color: root.toggleDnd ? Theme.primary : Theme.border
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.toggleDnd ? "󰂛" : "󰂚"
                            color: root.toggleDnd ? "#111111" : Theme.text
                            font.pixelSize: 24
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.toggleDnd ? "DND" : "Notify"
                            color: root.toggleDnd ? "#111111" : Theme.textDim
                            font.pixelSize: 11
                            font.bold: root.toggleDnd
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleDnd = !root.toggleDnd
                    }
                }
            }

            // =================================
            // 3. SLIDERS (Thick iOS Style)
            // =================================
            Column {
                width: parent.width
                spacing: 16

                // Brightness Slider
                Item {
                    width: parent.width
                    height: 52 // Slightly taller for that thick look

                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2 // Perfect pill shape
                        color: Theme.surface
                        border.color: Theme.border
                        border.width: 1
                        clip: true

                        // The Fill Bar
                        Rectangle {
                            height: parent.height
                            // Math.max ensures the colored bar never shrinks smaller than a circle, 
                            // keeping the left side perfectly rounded even at 0%
                            width: Math.max(height, (root.brightnessValue / 100) * parent.width)
                            radius: height / 2
                            color: Theme.primary
                            opacity: 0.85

                            // Smooth animation when changing brightness via keyboard keys
                            Behavior on width {
                                NumberAnimation { duration: Theme.fastAnim; easing.type: Easing.OutQuad }
                            }
                        }

                        // Brightness Icon
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 18
                            text: "󰃟"
                            // Change text color to dark if the slider is filled past it, else light
                            color: (root.brightnessValue > 10) ? "#111111" : Theme.text
                            font.pixelSize: 22
                            font.family: "JetBrainsMono Nerd Font"
                            z: 2
                        }

                        // Drag & Click Logic
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            
                            function updateValue(mouse) {
                                let newPct = Math.max(0, Math.min(100, (mouse.x / width) * 100))
                                root.brightnessValue = newPct
                                brightnessSetProcess.command = ["brightnessctl", "set", Math.round(newPct) + "%"]
                                brightnessSetProcess.running = true
                            }

                            onPressed: (mouse) => updateValue(mouse)
                            onPositionChanged: (mouse) => {
                                if (mouse.buttons & Qt.LeftButton) updateValue(mouse)
                            }
                        }
                    }
                }

                // Volume Slider
                // Volume Slider
                Item {
                    id: volSliderItem
                    width: parent.width
                    height: 52

                    // Safely grab the correct sink (mirroring your SystemInfo logic)
                    property var activeSink: Pipewire.defaultAudioSink || Pipewire.preferredDefaultAudioSink || null
                    property var activeAudio: activeSink ? activeSink.audio : null
                    
                    // Extract values
                    property real volValue: activeAudio && activeAudio.volume !== undefined ? activeAudio.volume : 0
                    property bool isMuted: activeAudio && activeAudio.muted !== undefined ? activeAudio.muted : true

                    // Force QML to reactively track changes from your hardware volume keys
                    PwObjectTracker {
                        objects: {
                            const tracked = []
                            if (volSliderItem.activeSink) tracked.push(volSliderItem.activeSink)
                            if (volSliderItem.activeAudio) tracked.push(volSliderItem.activeAudio)
                            return tracked
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2
                        color: Theme.surface
                        border.color: Theme.border
                        border.width: 1
                        clip: true

                        // The Fill Bar
                        Rectangle {
                            height: parent.height
                            width: Math.max(height, Math.min(1, volSliderItem.volValue) * parent.width)
                            radius: height / 2
                            color: Theme.primary
                            opacity: 0.85

                            Behavior on width {
                                NumberAnimation { duration: Theme.fastAnim; easing.type: Easing.OutQuad }
                            }
                        }

                        // Volume Icon
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 18
                            text: (volSliderItem.isMuted || volSliderItem.volValue <= 0) ? "󰖁" : "󰕾"
                            color: (volSliderItem.volValue > 0.1) ? "#111111" : Theme.text
                            font.pixelSize: 22
                            font.family: "JetBrainsMono Nerd Font"
                            z: 2
                        }

                        // Drag & Click Logic
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            
                            function updateVolume(mouse) {
                                if (volSliderItem.activeAudio) {
                                    let newVol = Math.max(0, Math.min(1.0, mouse.x / width))
                                    volSliderItem.activeAudio.volume = newVol
                                    
                                    // Automatically unmute if you drag the slider up
                                    if (newVol > 0 && volSliderItem.activeAudio.muted) {
                                        volSliderItem.activeAudio.muted = false
                                    }
                                }
                            }

                            onPressed: (mouse) => updateVolume(mouse)
                            onPositionChanged: (mouse) => {
                                if (mouse.buttons & Qt.LeftButton) updateVolume(mouse)
                            }
                        }
                    }
                }
            }

            

            // =================================
            // 4. MEDIA CARD
            // =================================
            Rectangle {
                width: parent.width
                height: 120
                radius: 24
                color: Theme.surface
                border.color: Theme.border
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    // Cover Art Placeholder
                    Rectangle {
                        width: 88
                        height: 88
                        radius: 16
                        color: Theme.background
                        border.color: Theme.border
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "󰎆"
                            color: Theme.primary
                            font.pixelSize: 32
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    // Info & Controls
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 88 - 16
                        spacing: 12

                        Column {
                            spacing: 4
                            Text {
                                text: "Tonight, Tonight"
                                color: Theme.text
                                font.pixelSize: 16
                                font.bold: true
                                width: parent.width
                                elide: Text.ElideRight
                            }
                            Text {
                                text: "The Smashing Pumpkins"
                                color: Theme.textDim
                                font.pixelSize: 13
                                width: parent.width
                                elide: Text.ElideRight
                            }
                        }

                        Row {
                            spacing: 24
                            anchors.horizontalCenter: parent.horizontalCenter

                            Text {
                                text: "󰒮"
                                color: Theme.textDim
                                font.pixelSize: 24
                                font.family: "JetBrainsMono Nerd Font"
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                            }
                            Text {
                                text: "󰐊"
                                color: Theme.primary
                                font.pixelSize: 28
                                font.family: "JetBrainsMono Nerd Font"
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                            }
                            Text {
                                text: "󰒭"
                                color: Theme.textDim
                                font.pixelSize: 24
                                font.family: "JetBrainsMono Nerd Font"
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                            }
                        }
                    }
                }
            }
        }
    }
}