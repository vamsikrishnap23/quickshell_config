pragma Singleton
import QtQuick
import "../state"

QtObject {
    // Store the raw Matugen JSON object here
    property var palette: null

    // =========================
    // COLORS (DYNAMIC BINDINGS)
    // =========================

    // Automatically switches between dark and light colors when isDarkMode changes!
    property color background: palette ? palette.background[GlobalState.isDarkMode ? "dark" : "light"].color : "#111111"
    property color surface: palette ? palette.surface_container_highest[GlobalState.isDarkMode ? "dark" : "light"].color : "#1c1c1f"
    property color primary: palette ? palette.primary[GlobalState.isDarkMode ? "dark" : "light"].color : "#cba6f7"
    property color secondary: palette ? palette.secondary[GlobalState.isDarkMode ? "dark" : "light"].color : "#89b4fa"
    property color text: palette ? palette.on_background[GlobalState.isDarkMode ? "dark" : "light"].color : "#ffffff"
    property color textDim: palette ? palette.on_surface_variant[GlobalState.isDarkMode ? "dark" : "light"].color : "#a1a1aa"
    property color border: palette ? palette.outline_variant[GlobalState.isDarkMode ? "dark" : "light"].color : "#2a2a2e"

    // =========================
    // SIZING (STATIC)
    // =========================

    readonly property int radius: 18
    readonly property int gap: 12
    readonly property int padding: 12

    // =========================
    // BAR
    // =========================

    readonly property int barHeight: 38

    // =========================
    // ANIMATIONS
    // =========================

    readonly property int fastAnim: 120
    readonly property int normalAnim: 220
}