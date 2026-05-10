import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick.Controls
import Quickshell.Io

import "../styles"
import "../state"

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top

    property int brightnessValue: 80

    anchors {
        top: true
        right: true
    }

    margins {
        top: 6
        right: 8
    }

    implicitWidth: 360
    implicitHeight: 520

    color: "transparent"

    visible: GlobalState.showControlCenter

    Item {
        anchors.fill: parent
        focus: root.visible

        Keys.onEscapePressed: {
            GlobalState.showControlCenter = false
        }
    }

    Process {
        id: brightnessProcess

        command: [
            "sh",
            "-c",
            "brightnessctl -m | cut -d',' -f4 | tr -d '%'"
        ]

        stdout: SplitParser {
            onRead: data => {
                const value = parseInt(data)

                if (!isNaN(value)) {
                    root.brightnessValue = value
                }
            }
        }
    }

    Process {
        id: brightnessSetProcess
    }

    onVisibleChanged: {
        if (visible) {
            brightnessProcess.running = true
        }
    }

    Rectangle {
        id: panel

        anchors.fill: parent

        radius: 28

        color: Theme.background

        border.color: Theme.border
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 18

            spacing: 22

            // =================================
            // HEADER
            // =================================

            Row {
                width: parent.width

                spacing: 14

                Rectangle {
                    width: 48
                    height: 48

                    radius: 24

                    color: Theme.primary

                    Text {
                        anchors.centerIn: parent

                        text: Quickshell.env("USER")
                              .charAt(0)
                              .toUpperCase()

                        color: "#000000"

                        font.bold: true
                        font.pixelSize: 20
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 2

                    Text {
                        text: Quickshell.env("USER")

                        color: Theme.text

                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        text: "Arch Linux"

                        color: Theme.textDim

                        font.pixelSize: 12
                    }
                }
            }

            // =================================
            // QUICK TOGGLES
            // =================================

            Row {
                width: parent.width

                spacing: 12

                Rectangle {
                    width: 64
                    height: 64

                    radius: 18

                    color: Theme.surface

                    border.color: Theme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent

                        text: "󰤨"

                        color: Theme.text

                        font.pixelSize: 24
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                Rectangle {
                    width: 64
                    height: 64

                    radius: 18

                    color: Theme.surface

                    border.color: Theme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent

                        text: "󰂯"

                        color: Theme.text

                        font.pixelSize: 24
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                Rectangle {
                    width: 64
                    height: 64

                    radius: 18

                    color: Theme.surface

                    border.color: Theme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent

                        text: "󰂚"

                        color: Theme.text

                        font.pixelSize: 24
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                Rectangle {
                    width: 64
                    height: 64

                    radius: 18

                    color: Theme.surface

                    border.color: Theme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent

                        text: "󰖔"

                        color: Theme.text

                        font.pixelSize: 24
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }

            // =================================
            // DEVICES
            // =================================

            Column {
                width: parent.width

                spacing: 12

                Text {
                    text: "Devices"

                    color: Theme.textDim

                    font.pixelSize: 13
                    font.bold: true
                }

                Column {
                    spacing: 8

                    Text {
                        text: "󰋋 AirPods Pro 2"

                        color: Theme.text

                        font.pixelSize: 15
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        text: "L 80%   R 82%   Case 60%"

                        color: Theme.textDim

                        font.pixelSize: 12
                    }
                }

                Column {
                    spacing: 8

                    Text {
                        text: "󰌌 Keyboard"

                        color: Theme.text

                        font.pixelSize: 15
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        text: "󰍽 Mouse"

                        color: Theme.text

                        font.pixelSize: 15
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }

            // =================================
            // SLIDERS
            // =================================

            Column {
                width: parent.width

                spacing: 16

                Text {
                    text: "󰕾 Volume"

                    color: Theme.text

                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"
                }

                Slider {
                    width: parent.width

                    from: 0
                    to: 1

                    value: Pipewire.defaultAudioSink
                        ? Pipewire.defaultAudioSink.audio.volume
                        : 0

                    onMoved: {
                        if (Pipewire.defaultAudioSink) {
                            Pipewire.defaultAudioSink.audio.volume = value
                        }
                    }

                    background: Rectangle {
                        x: parent.leftPadding
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2

                        implicitWidth: 200
                        implicitHeight: 14

                        width: parent.availableWidth
                        height: implicitHeight

                        radius: 7

                        color: Theme.surface

                        Rectangle {
                            width: parent.parent.visualPosition * parent.width
                            height: parent.height

                            radius: parent.radius

                            color: Theme.primary
                        }
                    }

                    handle: Rectangle {
                        visible: false
                    }
                }

                Text {
                    text: "󰃟 Brightness"

                    color: Theme.text

                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"
                }

                Slider {
                    width: parent.width

                    from: 0
                    to: 100

                    value: root.brightnessValue

                    onMoved: {
                        root.brightnessValue = value

                        brightnessSetProcess.command = [
                            "brightnessctl",
                            "set",
                            Math.round(value) + "%"
                        ]

                        brightnessSetProcess.running = true
                        brightnessProcess.running = true
                    }

                    background: Rectangle {
                        x: parent.leftPadding
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2

                        implicitWidth: 200
                        implicitHeight: 14

                        width: parent.availableWidth
                        height: implicitHeight

                        radius: 7

                        color: Theme.surface

                        Rectangle {
                            width: parent.parent.visualPosition * parent.width
                            height: parent.height

                            radius: parent.radius

                            color: Theme.primary
                        }
                    }

                    handle: Rectangle {
                        visible: false
                    }
                }
                }

            // =================================
            // MEDIA
            // =================================

            Column {
                width: parent.width

                spacing: 10

                Text {
                    text: "Tonight, Tonight"

                    color: Theme.text

                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: "The Smashing Pumpkins"

                    color: Theme.textDim

                    font.pixelSize: 13
                }

                Row {
                    spacing: 18

                    Text {
                        text: "󰒮"

                        color: Theme.text

                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        text: "󰐊"

                        color: Theme.primary

                        font.pixelSize: 24
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        text: "󰒭"

                        color: Theme.text

                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
        }
    }
}