import QtQuick
import QtQuick.Controls

import "../styles"
import "../components"

Row {
    spacing: 10

    Repeater {
        model: [
            "󰤨",
            "",
            "󰁹",
            "󰣇"
        ]

        delegate: Pill {
            implicitWidth: 36

            Text {
                anchors.centerIn: parent

                text: modelData
                color: Theme.text

                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }
}