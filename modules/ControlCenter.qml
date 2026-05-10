import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

import "../styles"
import "../state"
import "../components"

PanelWindow {
    id: root
    
    // FIX 1: Explicitly tell Wayland to float this above standard windows
    WlrLayershell.layer: WlrLayer.Top

    anchors {
        top: true
        right: true
        topMargin: Theme.barHeight + 16
        rightMargin: 18
    }

    // FIX 2: Give the Wayland surface explicit dimensions based on the container
    width: container.width
    height: container.height

    color: "transparent"
    visible: GlobalState.showControlCenter

    // FIX 3: Safely resolve the media player to prevent QML crash loops
    property var currentPlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null


    Rectangle {
        id: container
        width: 340
        implicitHeight: mainLayout.implicitHeight + 32
        radius: Theme.radius
        color: Theme.background
        border.color: Theme.border
        border.width: 1
        focus: true
        Keys.onEscapePressed: GlobalState.showControlCenter = false

        // Slide/Fade In Animations
        opacity: GlobalState.showControlCenter ? 1 : 0
        y: GlobalState.showControlCenter ? 0 : -20
        Behavior on opacity { NumberAnimation { duration: Theme.fastAnim } }
        Behavior on y { NumberAnimation { duration: Theme.fastAnim; easing.type: Easing.OutCubic } }

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 16
            spacing: 20

            // ==========================================
            // 1. QUICK TOGGLES
            // ==========================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: ["󰤨", "󰂯", "󰖔", "󰃠"] // WiFi, BT, DND, Flashlight
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        radius: 12
                        color: Theme.surface
                        border.color: Theme.border
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: Theme.text
                            font.pixelSize: 18
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }
                }
            }

            // ==========================================
            // 2. DEVICES LIST
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Devices"
                    color: Theme.textDim
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: 8
                    color: "transparent"
                    
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Text { text: "󰋋 AirPods Pro 2"; color: Theme.text; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                        Text { text: "L 80%  R 82%  Case 60%"; color: Theme.textDim; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
                    }
                }
            }

            // ==========================================
            // 3. SLIDERS (Volume & Brightness)
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text { text: "󰕾"; color: Theme.text; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                    Slider {
                        Layout.fillWidth: true
                        value: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.volume : 0
                        onMoved: {
                            if (Pipewire.defaultAudioSink) {
                                Pipewire.defaultAudioSink.audio.volume = value
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text { text: "󰃟"; color: Theme.text; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                    Slider {
                        Layout.fillWidth: true
                        value: 0.8 // Requires brightnessctl binding
                    }
                }
            }

            // ==========================================
            // 4. MEDIA CONTROLS
            // ==========================================
            Rectangle {
                Layout.fillWidth: true
                height: 80
                radius: 12
                color: Theme.surface
                border.color: Theme.border

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 56; height: 56
                        radius: 8
                        color: Theme.background
                        Text { anchors.centerIn: parent; text: "󰝚"; color: Theme.primary; font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font" }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text { 
                            text: root.currentPlayer ? root.currentPlayer.trackTitle : "No Media"
                            color: Theme.text
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text { 
                            text: root.currentPlayer ? root.currentPlayer.trackArtist : "---"
                            color: Theme.textDim
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        spacing: 8
                        Text { 
                            text: "󰒮"; color: Theme.text; font.pixelSize: 20; font.family: "JetBrainsMono Nerd Font"
                            MouseArea { anchors.fill: parent; onClicked: if(root.currentPlayer) root.currentPlayer.previous() } 
                        }
                        Text { 
                            // Dynamically switch play/pause icon based on state
                            text: root.currentPlayer && root.currentPlayer.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                            color: Theme.primary; font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font"
                            MouseArea { anchors.fill: parent; onClicked: if(root.currentPlayer) root.currentPlayer.playPause() } 
                        }
                        Text { 
                            text: "󰒭"; color: Theme.text; font.pixelSize: 20; font.family: "JetBrainsMono Nerd Font"
                            MouseArea { anchors.fill: parent; onClicked: if(root.currentPlayer) root.currentPlayer.next() } 
                        }
                    }
                }
            }
        }
    }
}