pragma Singleton

import QtQuick

QtObject {
    // =========================
    // COLORS
    // =========================

    readonly property color background: "#11111bee"
    readonly property color surface: "#1e1e2ecc"

    readonly property color primary: "#cba6f7"
    readonly property color secondary: "#89b4fa"

    readonly property color text: "#f5e0dc"
    readonly property color textDim: "#a6adc8"

    readonly property color border: "#313244"

    // =========================
    // SIZING
    // =========================

    readonly property int radius: 18
    readonly property int gap: 12
    readonly property int padding: 12

    // =========================
    // BAR
    // =========================

    readonly property int barHeight: 42

    // =========================
    // ANIMATIONS
    // =========================

    readonly property int fastAnim: 120
    readonly property int normalAnim: 220
}