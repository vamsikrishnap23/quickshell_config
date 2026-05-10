import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris

import "../styles"
import "../components" // 1. Import your custom components

Pill { // 2. Change the root element from Item to Pill
    id: root
    
    // Identify the current player
    property var currentPlayer: {
        const players = Mpris.players.values || []

        for (const player of players) {
            if (player.playbackState === MprisPlaybackState.Playing) {
                return player
            }
        }

        return players.length > 0 ? players[0] : null
    }

    // Track the active playing state
    property bool isPlaying: currentPlayer && currentPlayer.playbackState === MprisPlaybackState.Playing

    // Keep visible as long as ANY player exists, even if paused
    visible: currentPlayer !== null
    
    // 3. Add padding to the width calculation so text doesn't touch the Pill edges
    implicitWidth: Math.min(350, Math.max(200, mediaText.implicitWidth + 32))

    // Interactive play/pause controls
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
        
        // 4. Force text to elide inside the Pill with proper margins and centering
        elide: Text.ElideRight
        width: parent.width - 24 
        horizontalAlignment: Text.AlignHCenter
        
        // Smooth color transition
        Behavior on color {
            ColorAnimation { duration: Theme.fastAnim }
        }
    }
}