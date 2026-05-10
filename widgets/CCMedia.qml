import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects

import "../styles"

Item {
    id: root
    width:  parent.width
    height: 118

    // ── Active player ─────────────────────────────────────────────────────
    property var player: {
        const list = Mpris.players.values || []
        return list.find(p => p.playbackState === MprisPlaybackState.Playing)
               ?? list[0]
               ?? null
    }

    property bool isPlaying: player?.playbackState === MprisPlaybackState.Playing
                             ?? false

    // Quickshell exposes position / length in SECONDS (not microseconds)
    property real length:   player?.length   ?? 0
    property real position: 0                         // driven by animation below

    property string artUrl: player?.metadata?.["mpris:artUrl"] ?? ""

    // ── Smooth position interpolation — no polling ────────────────────────
    //   Seeded from the player on every meaningful state change.
    //   NumberAnimation advances at real-time pace (duration = remaining ms).

    function syncPosition() {
        posAnim.stop()
        if (!player) { position = 0; return }
        position = player.position
        if (isPlaying && length > 0) {
            const remaining = length - position
            if (remaining > 0.5) {
                posAnim.to       = length
                posAnim.duration = Math.round(remaining * 1000)
                posAnim.start()
            }
        }
    }

    NumberAnimation {
        id:          posAnim
        target:      root
        property:    "position"
        easing.type: Easing.Linear
        running:     false
    }

    // React to state changes without a polling timer
    onPlayerChanged:    syncPosition()
    onIsPlayingChanged: syncPosition()
    onLengthChanged:    syncPosition()

    Connections {
        target:  root.player
        enabled: root.player !== null
        function onPositionChanged()     { root.syncPosition() }  // seek
        function onPlaybackStateChanged(){ root.syncPosition() }  // external pause/play
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    function formatTime(secs) {
        if (!secs || secs <= 0) return "0:00"
        const s = Math.floor(secs)
        const m = Math.floor(s / 60)
        const r = s % 60
        return `${m}:${r < 10 ? "0" : ""}${r}`
    }

    // ── Card ──────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius:       20
        color:        Theme.surface
        border.color: Theme.border
        border.width: 1
        clip:         true

        // Blurred album-art backdrop
        Image {
            id:           bgArt
            anchors.fill: parent
            source:       root.artUrl
            fillMode:     Image.PreserveAspectCrop
            asynchronous: true
            cache:        false
            visible:      status === Image.Ready
            opacity:      0.15
        }
        FastBlur {
            anchors.fill: bgArt
            source:       bgArt
            radius:       90
            visible:      bgArt.visible
        }
        Rectangle {
            anchors.fill: parent
            color:        "#A0000000"
        }

        // ── TOP ROW: art · info · play button ────────────────────────────
        Item {
            id:      topRow
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 14 }
            height:  76

            // Album art
            Rectangle {
                id:     artBox
                width:  68; height: 68
                radius: 12
                color:  Qt.rgba(1, 1, 1, 0.07)
                clip:   true
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id:           albumArt
                    anchors.fill: parent
                    source:       root.artUrl
                    fillMode:     Image.PreserveAspectCrop
                    asynchronous: true
                    cache:        false
                    visible:      status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    visible:          !albumArt.visible
                    text:             "󰎆"
                    color:            Theme.textDim
                    font.pixelSize:   28
                    font.family:      "JetBrainsMono Nerd Font"
                }
            }

            // Track info
            Column {
                anchors {
                    left:           artBox.right;  leftMargin:     12
                    right:          playBtn.left;  rightMargin:    12
                    verticalCenter: parent.verticalCenter
                }
                spacing: 4

                Text {
                    width:          parent.width
                    text:           root.player?.trackTitle ?? "Nothing Playing"
                    color:          Theme.text
                    font.pixelSize: 15
                    font.bold:      true
                    elide:          Text.ElideRight
                }

                Text {
                    width:          parent.width
                    text:           root.player?.trackArtist ?? ""
                    color:          Theme.textDim
                    font.pixelSize: 12
                    elide:          Text.ElideRight
                    visible:        text !== ""
                }

                // Time — only rendered when a real duration is known
                Text {
                    visible:        root.player !== null && root.length > 0
                    text:           root.formatTime(root.position) + " / "
                                    + root.formatTime(root.length)
                    color:          Theme.textDim
                    font.pixelSize: 11
                    font.family:    "JetBrainsMono Nerd Font"
                }
            }

            // Circular play / pause button
            Rectangle {
                id:     playBtn
                width:  40; height: 40
                radius: 20
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                color: playHover.containsMouse
                       ? Qt.lighter(Theme.primary, 1.12) : Theme.primary
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text:           root.isPlaying ? "󰏤" : "󰐊"
                    color:          "#111111"
                    font.pixelSize: 18
                    font.family:    "JetBrainsMono Nerd Font"
                }

                MouseArea {
                    id:           playHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    if (root.player) root.player.togglePlaying()
                }
            }
        }

        // ── BOTTOM ROW: prev · progress pill · next ───────────────────────
        Item {
            anchors {
                top:          topRow.bottom; topMargin:    4
                bottom:       parent.bottom; bottomMargin: 12
                left:         parent.left;   leftMargin:   14
                right:        parent.right;  rightMargin:  14
            }

            // Previous button
            Rectangle {
                id:     prevBtn
                width:  36; height: 36
                radius: 10
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                color: prevHover.containsMouse ? Qt.rgba(1,1,1,0.10) : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text:           "󰒮"
                    color:          prevHover.containsMouse ? Theme.text : Theme.textDim
                    font.pixelSize: 18
                    font.family:    "JetBrainsMono Nerd Font"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                MouseArea {
                    id:           prevHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    if (root.player) root.player.previous()
                }
            }

            // Next button
            Rectangle {
                id:     nextBtn
                width:  36; height: 36
                radius: 10
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                color: nextHover.containsMouse ? Qt.rgba(1,1,1,0.10) : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text:           "󰒭"
                    color:          nextHover.containsMouse ? Theme.text : Theme.textDim
                    font.pixelSize: 18
                    font.family:    "JetBrainsMono Nerd Font"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                MouseArea {
                    id:           nextHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    if (root.player) root.player.next()
                }
            }

            // Smooth pill progress bar
            Item {
                anchors {
                    left:           prevBtn.right; leftMargin:  8
                    right:          nextBtn.left;  rightMargin: 8
                    verticalCenter: parent.verticalCenter
                }
                height: 20

                // Track background
                Rectangle {
                    id:      progressTrack
                    width:   parent.width
                    height:  5
                    radius:  3
                    color:   Qt.rgba(1, 1, 1, 0.13)
                    anchors.verticalCenter: parent.verticalCenter

                    // Played fill
                    Rectangle {
                        height: parent.height
                        radius: parent.radius
                        color:  Theme.primary
                        width:  root.length > 0
                                ? (root.position / root.length) * parent.width
                                : 0
                    }

                    // Playhead dot
                    Rectangle {
                        visible: root.player !== null
                        width:   10; height: 10
                        radius:  5
                        color:   Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.length > 0
                           ? Math.max(0, (root.position / root.length) * parent.width - 5)
                           : -5
                    }
                }

                // Wider invisible hit area for easy seeking
                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        if (root.player && root.length > 0) {
                            const pct = Math.max(0, Math.min(1, mouse.x / width))
                            root.player.position = pct * root.length
                            root.syncPosition()
                        }
                    }
                }
            }
        }
    }
}
