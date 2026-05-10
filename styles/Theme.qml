pragma Singleton

import QtQuick

QtObject {

    // =========================
    // COLORS
    // =========================

    // Main backgrounds
    readonly property color background: "#111111"
    readonly property color surface: "#1c1c1f"

    // Accent colors
    readonly property color primary: "#cba6f7"
    readonly property color secondary: "#89b4fa"

    // Text
    readonly property color text: "#ffffff"
    readonly property color textDim: "#a1a1aa"

    // Borders
    readonly property color border: "#2a2a2e"

    // =========================
    // SIZING
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