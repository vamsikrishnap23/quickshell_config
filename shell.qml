import Quickshell
import QtQuick
import Quickshell.Io

import "./modules"
import "./state"

ShellRoot {
    TopBar {}
    Powermenu {}

    IpcHandler {
        target: "powermenu"

        function togglePowermenu() {
            GlobalState.showPowermenu = !GlobalState.showPowermenu
        }
    }
}