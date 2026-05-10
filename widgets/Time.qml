import QtQuick

import "../styles"
import "../components"

Pill {
    implicitWidth: timeText.implicitWidth + 16

    Text {
        id: timeText

        anchors.centerIn: parent

        text: Qt.formatTime(new Date(), "hh:mm")
        color: Theme.text

        font.pixelSize: 12
        font.family: "JetBrainsMono Nerd Font"
    }

    Timer {
        running: true
        repeat: true
        interval: 5000

        onTriggered: {
            timeText.text = Qt.formatTime(new Date(), "hh:mm")
        }
    }
}
