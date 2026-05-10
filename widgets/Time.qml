import QtQuick

import "../styles"
import "../components"

Pill {
    implicitWidth: timeText.implicitWidth + 16

    // Function to calculate exact ms until the next minute
    function syncAndUpdateTime() {
        timeText.text = Qt.formatTime(new Date(), "hh:mm")
        
        let now = new Date()
        // Calculate exact milliseconds remaining until the clock hits :00 seconds
        let msUntilNextMinute = (60 - now.getSeconds()) * 1000 - now.getMilliseconds()
        
        // Set the timer to wake up precisely at the minute boundary
        syncTimer.interval = msUntilNextMinute
        syncTimer.restart()
    }

    Text {
        id: timeText
        anchors.centerIn: parent
        text: Qt.formatTime(new Date(), "hh:mm")
        color: Theme.text
        font.pixelSize: 12
        font.family: "JetBrainsMono Nerd Font"
    }

    Timer {
        id: syncTimer
        running: true
        repeat: false // We disable auto-repeat to manually control the interval
        onTriggered: syncAndUpdateTime()
    }

    // Initialize the sync process as soon as the widget loads
    Component.onCompleted: {
        syncAndUpdateTime()
    }
}