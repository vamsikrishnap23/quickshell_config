pragma Singleton
import QtQuick

QtObject {

    // =========================
    // COLORS (DYNAMIC)
    // =========================

    // Main backgrounds
    property color background: "#111111"
    property color surface: "#1c1c1f"

    // Accent colors
    property color primary: "#cba6f7"
    property color secondary: "#89b4fa"

    // Text
    property color text: "#ffffff"
    property color textDim: "#a1a1aa"

    // Borders
    property color border: "#2a2a2e"

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