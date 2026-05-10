import QtQuick
import Quickshell
import Quickshell.Wayland

import "../styles"
import "../state"
import "../widgets"

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top

    // 1. Stretch the invisible window to cover the entire screen
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: GlobalState.showControlCenter

    // 2. Background click-catcher: Closes the panel if you click outside
    MouseArea {
        anchors.fill: parent
        onClicked: GlobalState.showControlCenter = false
        
        // Focus grabber for Escape key closing
        focus: root.visible
        Keys.onEscapePressed: GlobalState.showControlCenter = false
    }

    // Main Panel Background
    Rectangle {
        id: panel
        
        // 3. Move the dimensions down to the panel itself
        width: 380
        height: 600

        // 4. Anchor the panel back to the top-right corner
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 14
            rightMargin: 14
        }

        radius: 28
        color: Theme.background
        border.color: Theme.border
        border.width: 1

        // 5. Click Trap: Prevents clicks *inside* the panel from hitting the background and closing it
        MouseArea {
            anchors.fill: parent
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            CCProfile {}
            CCToggles {}
            CCSliders {}
            CCMedia {}
        }
    }
}