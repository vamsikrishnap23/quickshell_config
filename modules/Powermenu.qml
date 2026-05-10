import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

import "../styles"
import "../state"
import "../components"

PanelWindow {
    id: root
    
    // System commands
    Process { id: cmdShutdown; command: ["systemctl", "poweroff"] }
    Process { id: cmdReboot; command: ["systemctl", "reboot"] }
    Process { id: cmdLogout; command: ["hyprctl", "dispatch", "exit"] }
    Process { id: cmdLock; command: ["hyprlock"] }
    Process { id: cmdSleep; command: ["systemctl", "suspend"] }


    // Timers
    Timer {
        id: lockTimer
        interval: Theme.normalAnim
        repeat: false
        onTriggered: cmdLock.running = true
    }

    Timer {
        id: sleepTimer
        interval: Theme.normalAnim
        repeat: false
        onTriggered: cmdSleep.running = true
    }

    Timer {
        id: logoutTimer
        interval: Theme.normalAnim
        repeat: false
        onTriggered: cmdLogout.running = true
    }

    Timer {
        id: rebootTimer
        interval: Theme.normalAnim
        repeat: false
        onTriggered: cmdReboot.running = true
    }

    Timer {
        id: shutdownTimer
        interval: Theme.normalAnim
        repeat: false
        onTriggered: cmdShutdown.running = true
    }
    
    // Force the window to cover the entire screen
    anchors {
        top: true; bottom: true
        left: true; right: true
    }
    
    // Dark, semi-transparent background
    color: Qt.rgba(0, 0, 0, 0.75)
    
    // Listen to our global state
    visible: GlobalState.showPowermenu

    // Clicking anywhere in the background OR pressing Escape closes the menu
    MouseArea {
        anchors.fill: parent
        onClicked: GlobalState.showPowermenu = false
        
        focus: true
        Keys.onEscapePressed: {
            GlobalState.showPowermenu = false
        }
    }


    Column {
        id: menuContainer
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        // Slide in animation
        Behavior on x {
            NumberAnimation {
                duration: Theme.normalAnim
                easing.type: Easing.OutCubic
            }
        }

        x: GlobalState.showPowermenu ? 0 : 120
        opacity: GlobalState.showPowermenu ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.normalAnim }
        }

        // Dark pill background
        Rectangle {
            id: pillBackground
            width: 90
            implicitHeight: buttonColumn.implicitHeight + 30
            radius: 45
            color: Theme.background
            border.color: Theme.border
            border.width: 1

            Column {
                id: buttonColumn
                anchors.fill: parent
                anchors.topMargin: 15
                anchors.bottomMargin: 15
                spacing: 0

                // Lock Button
                Rectangle {
                    width: 60
                    height: 60
                    radius: 30
                    color: root.lockHover ? Theme.primary : Theme.surface
                    border.color: root.lockHover ? Theme.primary : Theme.border
                    border.width: 1.5
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on color { ColorAnimation { duration: Theme.fastAnim } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰌾"
                        color: root.lockHover ? Qt.rgba(0, 0, 0, 1) : Theme.text
                        font.pixelSize: 28
                        font.family: "JetBrainsMono Nerd Font"
                        Behavior on color { ColorAnimation { duration: Theme.fastAnim } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            GlobalState.showPowermenu = false
                            lockTimer.start()
                        }
                        onEntered: root.lockHover = true
                        onExited: root.lockHover = false
                        cursorShape: Qt.PointingHandCursor
                    }

                    ToolTip.visible: root.lockHover
                    ToolTip.text: "Lock"
                    ToolTip.delay: 300
                }

                Item { width: 1; height: 8 }

                // Sleep Button
                Rectangle {
                    width: 60
                    height: 60
                    radius: 30
                    color: root.sleepHover ? Theme.primary : Theme.surface
                    border.color: root.sleepHover ? Theme.primary : Theme.border
                    border.width: 1.5
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on color { ColorAnimation { duration: Theme.fastAnim } }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: root.sleepHover ? Qt.rgba(0, 0, 0, 1) : Theme.text
                        font.pixelSize: 28
                        font.family: "JetBrainsMono Nerd Font"
                        Behavior on color { ColorAnimation { duration: Theme.fastAnim } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            GlobalState.showPowermenu = false
                            sleepTimer.start()
                        }
                        onEntered: root.sleepHover = true
                        onExited: root.sleepHover = false
                        cursorShape: Qt.PointingHandCursor
                    }

                    ToolTip.visible: root.sleepHover
                    ToolTip.text: "Sleep"
                    ToolTip.delay: 300
                }

                Item { width: 1; height: 8 }

                // Logout Button
                Rectangle {
                    width: 60
                    height: 60
                    radius: 30
                    color: root.logoutHover ? Theme.primary : Theme.surface
                    border.color: root.logoutHover ? Theme.primary : Theme.border
                    border.width: 1.5
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on color { ColorAnimation { duration: Theme.fastAnim } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰍃"
                        color: root.logoutHover ? Qt.rgba(0, 0, 0, 1) : Theme.text
                        font.pixelSize: 28
                        font.family: "JetBrainsMono Nerd Font"
                        Behavior on color { ColorAnimation { duration: Theme.fastAnim } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            GlobalState.showPowermenu = false
                            logoutTimer.start()
                        }
                        onEntered: root.logoutHover = true
                        onExited: root.logoutHover = false
                        cursorShape: Qt.PointingHandCursor
                    }

                    ToolTip.visible: root.logoutHover
                    ToolTip.text: "Logout"
                    ToolTip.delay: 300
                }

                Item { width: 1; height: 8 }

                // Reboot Button
                Rectangle {
                    width: 60
                    height: 60
                    radius: 30
                    color: root.rebootHover ? Theme.primary : Theme.surface
                    border.color: root.rebootHover ? Theme.primary : Theme.border
                    border.width: 1.5
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on color { ColorAnimation { duration: Theme.fastAnim } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰜉"
                        color: root.rebootHover ? Qt.rgba(0, 0, 0, 1) : Theme.text
                        font.pixelSize: 28
                        font.family: "JetBrainsMono Nerd Font"
                        Behavior on color { ColorAnimation { duration: Theme.fastAnim } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            GlobalState.showPowermenu = false
                            rebootTimer.start()
                        }
                        onEntered: root.rebootHover = true
                        onExited: root.rebootHover = false
                        cursorShape: Qt.PointingHandCursor
                    }

                    ToolTip.visible: root.rebootHover
                    ToolTip.text: "Reboot"
                    ToolTip.delay: 300
                }

                Item { width: 1; height: 8 }

                // Shutdown Button
                Rectangle {
                    width: 60
                    height: 60
                    radius: 30
                    color: root.shutdownHover ? Theme.primary : Theme.surface
                    border.color: root.shutdownHover ? Theme.primary : Theme.border
                    border.width: 1.5
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on color { ColorAnimation { duration: Theme.fastAnim } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰐥"
                        color: root.shutdownHover ? Qt.rgba(0, 0, 0, 1) : Theme.text
                        font.pixelSize: 28
                        font.family: "JetBrainsMono Nerd Font"
                        Behavior on color { ColorAnimation { duration: Theme.fastAnim } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            GlobalState.showPowermenu = false
                            shutdownTimer.start()
                        }
                        onEntered: root.shutdownHover = true
                        onExited: root.shutdownHover = false
                        cursorShape: Qt.PointingHandCursor
                    }

                    ToolTip.visible: root.shutdownHover
                    ToolTip.text: "Shutdown"
                    ToolTip.delay: 300
                }
            }
            ToolTip.visible: root.shutdownHover
            ToolTip.text: "Shutdown"
            ToolTip.delay: 300
        }
    }

    // Hover state properties
    property bool lockHover: false
    property bool sleepHover: false
    property bool logoutHover: false
    property bool rebootHover: false
    property bool shutdownHover: false
}