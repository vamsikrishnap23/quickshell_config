import Quickshell
import QtQuick
import Quickshell.Io

import "./modules"
import "./state"

ShellRoot {
    TopBar {}
    Powermenu {}
    ControlCenter{}
    WallpaperSwitcher {}

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

    IpcHandler {
        target: "wallpaper"
        function toggle() {
            GlobalState.showWallpaperSwitcher = !GlobalState.showWallpaperSwitcher
        }
    }
}