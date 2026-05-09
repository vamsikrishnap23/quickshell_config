import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris

import "../styles"
import "../components"

Pill {
    id: root
    property var currentPlayer: {
        const players = Mpris.players.values || []

        for (const player of players) {
            if (player.playbackState === MprisPlaybackState.Playing) {
                return player
            }
        }

        return players.length > 0 ? players[0] : null
    }

    visible: currentPlayer
        && currentPlayer.playbackState === MprisPlaybackState.Playing
    implicitWidth: Math.max(200, mediaText.implicitWidth + 16)

    Text {
        id: mediaText

        anchors.centerIn: parent

        text: {
            if (!currentPlayer) {
                return "\uf001 No media"
            }

            const artist = currentPlayer.trackArtist || "Unknown Artist"
            const title = currentPlayer.trackTitle || "Unknown Title"
            return "\uf001  " + title + "  - " + artist
        }
        color: Theme.text

        font.pixelSize: 12
        font.family: "JetBrainsMono Nerd Font"

        elide: Text.ElideRight
        width: Math.max(1, parent.width - 16)
    }
}
