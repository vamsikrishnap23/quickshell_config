import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland

import "../styles"
import "../components"

Pill {
    implicitWidth: row.implicitWidth + 18

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                required property var modelData

                width: modelData.active ? 18 : 8
                height: 8

                radius: 999

                color: modelData.active
                    ? Theme.primary
                    : Qt.rgba(1,1,1,0.10)

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.fastAnim
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        Hyprland.dispatch(
                            "workspace " + modelData.id
                        )
                    }
                }
            }
        }
    }
}