import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects

import "../styles"

Item {
    id: mediaCard
    width: parent.width
    height: 165

    // Get the first playing player, or first available
    property var currentPlayer: {
        const players = Mpris.players.values || []
        if (players.length === 0) return null
        
        let playing = players.find(p => p.playbackState === MprisPlaybackState.Playing)
        return playing || players[0]
    }

    property bool isPlaying: currentPlayer && currentPlayer.playbackState === MprisPlaybackState.Playing
    property real displayPosition: currentPlayer ? currentPlayer.position : 0
    property real displayLength: currentPlayer && currentPlayer.length > 0 ? currentPlayer.length : 1
    property real breathingOpacity: 0.8
    property bool breathingUp: true

    // Breathing animation with timer
    Timer {
        id: breathingTimer
        interval: 2000
        running: mediaCard.isPlaying
        repeat: true
        onTriggered: {
            mediaCard.breathingUp = !mediaCard.breathingUp
        }
    }

    // Auto-update position when playing
    Timer {
        interval: 500
        running: mediaCard.isPlaying
        repeat: true
        onTriggered: {
            mediaCard.displayPosition = mediaCard.currentPlayer ? mediaCard.currentPlayer.position : 0
        }
    }

    function formatTime(microseconds) {
        if (!microseconds || microseconds <= 0) return "0:00"
        let totalSeconds = Math.floor(microseconds / 1000000)
        let minutes = Math.floor(totalSeconds / 60)
        let seconds = totalSeconds % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }

    Rectangle {
        anchors.fill: parent
        radius: 32
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // HEADER: Album Art + Track Info
            Row {
                width: parent.width
                spacing: 12
                height: 90

                // Album Art
                Rectangle {
                    width: 90
                    height: 90
                    radius: 10
                    color: Theme.background
                    border.color: Theme.border
                    border.width: 1
                    clip: true

                    Image {
                        id: albumArt
                        anchors.fill: parent
                        source: {
                            if (mediaCard.currentPlayer && mediaCard.currentPlayer.metadata) {
                                let url = mediaCard.currentPlayer.metadata["mpris:artUrl"]
                                return url || ""
                            }
                            return ""
                        }
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                        asynchronous: true
                        cache: false
                        opacity: mediaCard.breathingOpacity
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: 2000
                                easing.type: Easing.InOutSine
                            }
                        }
                    }

                    // Breathing opacity animation
                    PropertyAnimation {
                        target: mediaCard
                        property: "breathingOpacity"
                        from: mediaCard.breathingUp ? 0.8 : 1.0
                        to: mediaCard.breathingUp ? 1.0 : 0.8
                        duration: 2000
                        easing.type: Easing.InOutSine
                        running: mediaCard.isPlaying
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰎆"
                        color: Theme.primary
                        font.pixelSize: 36
                        font.family: "JetBrainsMono Nerd Font"
                        visible: !albumArt.visible
                    }
                }

                // Track Info
                Column {
                    width: parent.width - 90 - 12
                    height: parent.height
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    // Title
                    Text {
                        text: mediaCard.currentPlayer && mediaCard.currentPlayer.trackTitle 
                            ? mediaCard.currentPlayer.trackTitle 
                            : "No Media Playing"
                        color: Theme.text
                        font.pixelSize: 13
                        font.bold: true
                        width: parent.width
                        elide: Text.ElideRight
                        maximumLineCount: 2
                    }

                    // Artist
                    Text {
                        text: mediaCard.currentPlayer && mediaCard.currentPlayer.trackArtist 
                            ? mediaCard.currentPlayer.trackArtist 
                            : ""
                        color: Theme.textDim
                        font.pixelSize: 10
                        width: parent.width
                        elide: Text.ElideRight
                        visible: text !== ""
                    }

                    // Time Display
                    Text {
                        text: mediaCard.formatTime(mediaCard.displayPosition) + " / " + mediaCard.formatTime(mediaCard.displayLength)
                        color: Theme.textDim
                        font.pixelSize: 9
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }

            // Timeline
            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                color: Theme.background
                border.color: Theme.border
                border.width: 1

                Rectangle {
                    height: parent.height
                    radius: 3
                    color: Theme.primary
                    width: {
                        if (mediaCard.displayLength <= 0) return 0
                        let pct = mediaCard.displayPosition / mediaCard.displayLength
                        return Math.max(0, Math.min(1, pct)) * parent.width
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.Linear
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (mediaCard.currentPlayer && mediaCard.displayLength > 0) {
                            let pct = Math.max(0, Math.min(1, mouse.x / width))
                            let newPos = pct * mediaCard.displayLength
                            mediaCard.currentPlayer.position = Math.floor(newPos)
                        }
                    }
                }
            }

            // Controls
            Row {
                width: parent.width
                spacing: 6
                height: 40

                // Previous
                Rectangle {
                    width: (parent.width - 16) / 3
                    height: parent.height
                    radius: 10
                    color: (mediaCard.currentPlayer && mediaCard.currentPlayer.canGoPrevious) ? Theme.primary : Theme.surface
                    border.color: Theme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        color: (mediaCard.currentPlayer && mediaCard.currentPlayer.canGoPrevious) ? "#111111" : Theme.textDim
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: (mediaCard.currentPlayer && mediaCard.currentPlayer.canGoPrevious) ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (mediaCard.currentPlayer && mediaCard.currentPlayer.canGoPrevious) {
                                mediaCard.currentPlayer.previous()
                            }
                        }
                    }
                }

                // Play/Pause
                Rectangle {
                    width: (parent.width - 16) / 3
                    height: parent.height
                    radius: 10
                    color: (mediaCard.currentPlayer && mediaCard.currentPlayer.canTogglePlaying) ? Theme.primary : Theme.surface
                    border.color: Theme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: mediaCard.isPlaying ? "󰏤" : "󰐊"
                        color: (mediaCard.currentPlayer && mediaCard.currentPlayer.canTogglePlaying) ? "#111111" : Theme.textDim
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: (mediaCard.currentPlayer && mediaCard.currentPlayer.canTogglePlaying) ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (mediaCard.currentPlayer && mediaCard.currentPlayer.canTogglePlaying) {
                                mediaCard.currentPlayer.togglePlaying()
                            }
                        }
                    }
                }

                // Next
                Rectangle {
                    width: (parent.width - 16) / 3
                    height: parent.height
                    radius: 10
                    color: (mediaCard.currentPlayer && mediaCard.currentPlayer.canGoNext) ? Theme.primary : Theme.surface
                    border.color: Theme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        color: (mediaCard.currentPlayer && mediaCard.currentPlayer.canGoNext) ? "#111111" : Theme.textDim
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: (mediaCard.currentPlayer && mediaCard.currentPlayer.canGoNext) ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (mediaCard.currentPlayer && mediaCard.currentPlayer.canGoNext) {
                                mediaCard.currentPlayer.next()
                            }
                        }
                    }
                }
            }
        }
    }
}