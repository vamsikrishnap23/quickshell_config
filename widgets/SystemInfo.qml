import QtQuick
import QtQml
import QtQuick.Controls
import Quickshell.Networking
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth

import "../styles"
import "../components"

Row {
    id: root
    spacing: 10

    // Core Properties
    property var sink: Pipewire.defaultAudioSink || Pipewire.preferredDefaultAudioSink || null
    property var sinkAudio: sink ? sink.audio : null
    property var battery: UPower.displayDevice
    property bool applyingBluetoothSnap: false

    function normalizedVolume(raw) {
        if (raw === undefined || raw === null) {
            return 0
        }
        return raw <= 1.5 ? raw : raw / 100
    }

    function currentSinkVolumeNormalized() {
        if (!sinkAudio) {
            return 0
        }

        let rawVol = sinkAudio.volume
        if (
            (rawVol === 0 || rawVol === undefined)
            && sinkAudio.volumes
            && sinkAudio.volumes.length > 0
        ) {
            let total = 0
            for (let i = 0; i < sinkAudio.volumes.length; i++) {
                total += sinkAudio.volumes[i]
            }
            rawVol = total / sinkAudio.volumes.length
        }

        return Math.max(0, normalizedVolume(rawVol))
    }

    function maybeSnapBluetoothVolumeTo5Percent() {
        if (!sinkAudio || applyingBluetoothSnap) {
            return
        }

        // Only snap when an audio Bluetooth device is currently connected.
        if (!connectedBluetoothAudioName()) {
            return
        }

        const current = currentSinkVolumeNormalized()
        const snapped = Math.max(0, Math.min(1.5, Math.round(current * 20) / 20))

        if (Math.abs(current - snapped) < 0.005) {
            return
        }

        applyingBluetoothSnap = true
        sinkAudio.volume = snapped
        Qt.callLater(function() {
            root.applyingBluetoothSnap = false
            root.updateVolumeLabel()
        })
    }

    function resolveDefaultSink() {
        return Pipewire.defaultAudioSink || Pipewire.preferredDefaultAudioSink || null
    }

    function connectedBluetoothAudioName() {
        const bDevices = Bluetooth.devices?.values || []
        for (let i = 0; i < bDevices.length; i++) {
            const bDevice = bDevices[i]
            if (!bDevice.connected) {
                continue
            }

            const bIcon = (bDevice.icon || "").toLowerCase()
            if (
                bIcon.includes("audio")
                || bIcon.includes("headset")
                || bIcon.includes("headphone")
                || bIcon.includes("speaker")
            ) {
                return bDevice.deviceName || bDevice.name || "Bluetooth"
            }
        }

        return ""
    }

    function updateVolumeLabel() {
        if (!sinkAudio) {
            volumeLabelText = "󰖁  --%"
            return
        }

        let rawVol = sinkAudio.volume
        if (
            (rawVol === 0 || rawVol === undefined)
            && sinkAudio.volumes
            && sinkAudio.volumes.length > 0
        ) {
            let total = 0
            for (let i = 0; i < sinkAudio.volumes.length; i++) {
                total += sinkAudio.volumes[i]
            }
            rawVol = total / sinkAudio.volumes.length
        }

        rawVol = rawVol !== undefined ? rawVol : 0
        const pct = Math.min(
            150,
            Math.max(0, Math.round(rawVol <= 1.5 ? rawVol * 100 : rawVol))
        )
        const icon = sinkAudio.muted ? "󰖁" : "󰕾"
        const btName = connectedBluetoothAudioName()

        volumeLabelText = btName
            ? `${icon}  ${pct}%  ${btName}`
            : `${icon}  ${pct}%`
    }

    // Pipewire Node Tracker
    PwObjectTracker {
        objects: {
            const tracked = []
            if (root.sink) tracked.push(root.sink)
            if (root.sinkAudio) tracked.push(root.sinkAudio)
            return tracked
        }
    }

    Connections {
        target: Pipewire
        ignoreUnknownSignals: true

        function onDefaultAudioSinkChanged() {
            root.sink = root.resolveDefaultSink()
        }

        function onPreferredDefaultAudioSinkChanged() {
            root.sink = root.resolveDefaultSink()
        }
    }

    onSinkChanged: {
        sinkAudio = sink ? sink.audio : null
        updateVolumeLabel()
    }

    onSinkAudioChanged: updateVolumeLabel()

    Connections {
        target: root.sink
        ignoreUnknownSignals: true

        function onAudioChanged() {
            root.sinkAudio = root.sink ? root.sink.audio : null
            root.updateVolumeLabel()
        }
    }

    Connections {
        target: root.sinkAudio
        ignoreUnknownSignals: true

        function onVolumeChanged() {
            root.maybeSnapBluetoothVolumeTo5Percent()
            root.updateVolumeLabel()
        }

        function onVolumesChanged() {
            root.maybeSnapBluetoothVolumeTo5Percent()
            root.updateVolumeLabel()
        }

        function onMutedChanged() {
            root.updateVolumeLabel()
        }
    }

    Instantiator {
        model: Bluetooth.devices?.values || []
        delegate: Item {
            required property var modelData
            width: 0
            height: 0
            visible: false

            Connections {
                target: modelData
                ignoreUnknownSignals: true

                function onConnectedChanged() {
                    root.updateVolumeLabel()
                }

                function onDeviceNameChanged() {
                    root.updateVolumeLabel()
                }

                function onNameChanged() {
                    root.updateVolumeLabel()
                }

                function onIconChanged() {
                    root.updateVolumeLabel()
                }
            }
        }
    }

    Component.onCompleted: {
        sink = resolveDefaultSink()
        sinkAudio = sink ? sink.audio : null
        updateVolumeLabel()
    }

    // ==========================================
    // 1. WIFI (Declarative Watcher)
    // ==========================================
    property string wifiLabel: "󰤭  Offline"

    Instantiator {
        model: Networking.devices
        delegate: Instantiator {
            active: modelData.type === DeviceType.Wifi
            model: active ? modelData.networks : null
            delegate: QtObject {
                property bool isConnected: modelData.connected
                property string netName: modelData.name

                onIsConnectedChanged: {
                    if (isConnected) {
                        root.wifiLabel = `󰤨  ${netName || "WiFi"}`
                    } else if (root.wifiLabel === `󰤨  ${netName || "WiFi"}`) {
                        root.wifiLabel = "󰤭  Offline"
                    }
                }
                Component.onCompleted: {
                    if (isConnected) root.wifiLabel = `󰤨  ${netName || "WiFi"}`
                }
            }
        }
    }

    // ==========================================
    // 2. VOLUME (Declarative Binding)
    // ==========================================
    property string volumeLabelText: "󰖁  --%"

    // ==========================================
    // 3. BATTERY (Declarative Binding)
    // ==========================================
    property string batteryLabelText: {
        if (!battery || !battery.ready || !battery.isPresent) return "󰁹  --%"
        
        const raw = battery.percentage || 0
        const pct = Math.max(0, Math.round(raw <= 1.5 ? raw * 100 : raw))
        const charging = battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge
        const icon = charging ? "" : "󰁹"
        
        return `${icon}  ${pct}%`
    }

    // ==========================================
    // UI RENDERING
    // ==========================================
    Pill {
        implicitWidth: wifiText.implicitWidth + 16
        Text {
            id: wifiText
            anchors.centerIn: parent
            text: root.wifiLabel
            color: Theme.text
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    Pill {
        implicitWidth: volumeText.implicitWidth + 16
        Text {
            id: volumeText
            anchors.centerIn: parent
            text: root.volumeLabelText
            color: Theme.text
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    Pill {
        implicitWidth: batteryText.implicitWidth + 16
        Text {
            id: batteryText
            anchors.centerIn: parent
            text: root.batteryLabelText
            color: Theme.text
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    Pill {
        implicitWidth: 32
        Text {
            anchors.centerIn: parent
            text: "󰣇"
            color: Theme.text
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: GlobalState.showPowermenu = !GlobalState.showPowermenu
        }
    }
}