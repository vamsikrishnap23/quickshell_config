import Quickshell
import QtQuick
import Quickshell.Io

import "./modules"
import "./state"

ShellRoot {
    TopBar {}
    Powermenu {}
    ControlCenter{}

    IpcHandler {
        target: "powermenu"

        function togglePowermenu() {
            GlobalState.showPowermenu = !GlobalState.showPowermenu
        }
    }

    IpcHandler {
        target: "controlcenter"

        function toggleControlCenter() {
            GlobalState.showControlCenter = !GlobalState.showControlCenter
        }
    }
}