import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

import "../styles"
import "../state"

Column {
    id: root
    width: parent.width
    spacing: 16

    property int brightnessValue: 80

    // Fetch brightness when Control Center opens to guarantee sync
    Connections {
        target: GlobalState
        function onShowControlCenterChanged() {
            if (GlobalState.showControlCenter) brightnessProcess.running = true
        }
    }

    // 1. Fetch current brightness
    Process {
        id: brightnessProcess
        command: ["sh", "-c", "brightnessctl -m | cut -d',' -f4 | tr -d '%'"]
        stdout: SplitParser {
            onRead: data => {
                const value = parseInt(data)
                // Only apply external changes if the user isn't actively dragging the slider
                if (!isNaN(value) && !brightnessMouseArea.pressed) {
                    root.brightnessValue = value
                }
            }
        }
    }

    // 2. Zero-polling hardware event watcher
    Process {
        id: backlightWatcher
        // Listens to kernel backlight events and outputs a line on change
        command: ["udevadm", "monitor", "--subsystem-match=backlight"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                // Trigger a fetch whenever a hardware key changes the brightness
                brightnessProcess.running = true
            }
        }
    }

    // Initial fetch on load
    Component.onCompleted: brightnessProcess.running = true

    Process { id: brightnessSetProcess }

    // Brightness Slider
    Item {
        width: parent.width
        height: 52

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Theme.surface
            border.color: Theme.border
            border.width: 1
            clip: true

            Rectangle {
                height: parent.height
                width: Math.max(height, (root.brightnessValue / 100) * parent.width)
                radius: height / 2
                color: Theme.primary
                opacity: 0.85

                Behavior on width {
                    NumberAnimation { duration: Theme.fastAnim; easing.type: Easing.OutQuad }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 18
                text: "󰃟"
                color: (root.brightnessValue > 10) ? "#111111" : Theme.text
                font.pixelSize: 22
                font.family: "JetBrainsMono Nerd Font"
                z: 2
            }

            MouseArea {
                id: brightnessMouseArea
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
    Item {
        id: volSliderItem
        width: parent.width
        height: 52

        property var activeSink: Pipewire.defaultAudioSink || Pipewire.preferredDefaultAudioSink || null
        property var activeAudio: activeSink ? activeSink.audio : null
        property real volValue: activeAudio && activeAudio.volume !== undefined ? activeAudio.volume : 0
        property bool isMuted: activeAudio && activeAudio.muted !== undefined ? activeAudio.muted : true

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

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                
                function updateVolume(mouse) {
                    if (volSliderItem.activeAudio) {
                        let newVol = Math.max(0, Math.min(1.0, mouse.x / width))
                        volSliderItem.activeAudio.volume = newVol
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