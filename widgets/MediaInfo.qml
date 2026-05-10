import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris

import "../styles"

Item {
    id: root
    
    // 1. Identify the current player
    property var currentPlayer: {
        const players = Mpris.players.values || []

        for (const player of players) {
            if (player.playbackState === MprisPlaybackState.Playing) {
                return player
            }
        }

        return players.length > 0 ? players[0] : null
    }

    // 2. Track the active playing state
    property bool isPlaying: currentPlayer && currentPlayer.playbackState === MprisPlaybackState.Playing

    // 3. Keep visible as long as ANY player exists, even if paused
    visible: currentPlayer !== null
    
    // 4. Define dimensions without the Pill background
    implicitWidth: Math.max(200, mediaText.implicitWidth)
    implicitHeight: 32 // Maintains vertical alignment with the TopBar
    
    // 5. Interactive play/pause controls
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (currentPlayer) {
                currentPlayer.playPause()
            }
        }
    }

    Text {
        id: mediaText
        anchors.centerIn: parent

        text: {
            if (!currentPlayer) {
                return "\uf001 No media"
            }

            const artist = currentPlayer.trackArtist || "Unknown Artist"
            const title = currentPlayer.trackTitle || "Unknown Title"
            
            // Hardcode the music note icon to remain constant
            return "\uf001  " + title + "  - " + artist
        }
        
        // Dim the text color when playback is paused
        color: isPlaying ? Theme.text : Theme.textDim

        font.pixelSize: 12
        font.family: "JetBrainsMono Nerd Font"
        
        // Prevent text from overflowing its container
        elide: Text.ElideRight
        width: parent.width
        
        // Smooth color transition
        Behavior on color {
            ColorAnimation { duration: Theme.fastAnim }
        }
    }
}