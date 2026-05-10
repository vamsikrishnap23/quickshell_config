import QtQuick

import "../styles"
import "../components"

Pill {
    id: root
    implicitWidth: dateText.implicitWidth + 16

    // Calculates the exact milliseconds until 00:00:00
    function syncAndUpdateDate() {
        let now = new Date()
        dateText.text = Qt.formatDateTime(now, "ddd, MMM d")

        // Construct a Date object for tomorrow at midnight
        let tomorrow = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1)
        
        // Calculate delta and set timer
        let msUntilMidnight = tomorrow.getTime() - now.getTime()
        
        // Add a 1-second buffer to ensure the day has fully rolled over
        syncTimer.interval = msUntilMidnight + 1000
        syncTimer.restart()
    }

    Text {
        id: dateText
        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "ddd, MMM d")
        color: Theme.text
        font.pixelSize: 12
        font.family: "JetBrainsMono Nerd Font"
    }

    // Runs exactly once, sleeps, and then triggers the next calculation
    Timer {
        id: syncTimer
        running: true
        repeat: false
        onTriggered: syncAndUpdateDate()
    }

    Component.onCompleted: syncAndUpdateDate()
}