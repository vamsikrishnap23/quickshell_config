import Quickshell
import QtQuick

import "../widgets"

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    color: "transparent"

    implicitHeight: 48

    LeftSection {
        anchors {
            top: parent.top
            left: parent.left
            topMargin: 8
            leftMargin: 18
        }
    }

    MediaInfo {
        id: mediaInfo
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 8
        }
    }

    SystemInfo {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 8
            rightMargin: 18
        }
    }
}