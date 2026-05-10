import QtQuick
import Quickshell
import Quickshell.Wayland

import "../styles"
import "../state"
import "../widgets"

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top

    anchors {
        top: true
        right: true
    }

    margins {
        top: 14
        right: 14
    }

    implicitWidth: 380
    implicitHeight: 600

    color: "transparent"
    visible: GlobalState.showControlCenter

    // Focus grabber for Escape key closing
    Item {
        anchors.fill: parent
        focus: root.visible
        Keys.onEscapePressed: GlobalState.showControlCenter = false
    }

    // Main Panel Background
    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 28
        color: Theme.background
        border.color: Theme.border
        border.width: 1

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