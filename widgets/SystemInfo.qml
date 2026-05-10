import QtQuick
import QtQml
import QtQuick.Controls
import Quickshell.Networking
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import Quickshell.Io

import "../styles"
import "../components"
import "../state"

Row {
    id: root
    spacing: 10

    // Core Properties
    property var sink: Pipewire.defaultAudioSink || Pipewire.preferredDefaultAudioSink || null
    property var sinkAudio: sink ? sink.audio : null
    property var battery: UPower.displayDevice
    property bool applyingBluetoothSnap: false
    property string connectedBluetoothAudioName: ""
    property bool notificationsPresent: false
    property bool notificationsDnd: false

    

    function normalizedPercent(raw) {
        if (raw === undefined || raw === null) {
            return 0
        }
        const value = raw <= 1.5 ? raw * 100 : raw
        return Math.max(0, Math.min(100, Math.round(value)))
    }

    function wifiIconForPercent(pct) {
        if (pct <= 0) return "󰤭"
        if (pct <= 24) return "󰤟"
        if (pct <= 49) return "󰤢"
        if (pct <= 74) return "󰤥"
        return "󰤨"
    }

    function volumeIconForPercent(pct, muted) {
        if (muted || pct <= 0) return "󰖁"
        if (pct <= 33) return "󰕿"
        if (pct <= 66) return "󰖀"
        return "󰕾"
    }

    function batteryIconForPercent(pct) {
        if (pct <= 10) return ""
        if (pct <= 30) return ""
        if (pct <= 55) return ""
        if (pct <= 80) return ""
        return ""
    }

    function notificationIconForState(hasNotifications, dnd) {
        if (dnd) return "\uec08"
        if (hasNotifications) return "\ueb9a"
        return "\ueaa2"
    }

    function normalizedVolume(raw) {
        if (raw === undefined || raw === null) {
            return 0
        }
        return raw <= 1.5 ? raw : raw / 100
    }

    function effectiveVolume() {
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

        return rawVol !== undefined ? rawVol : 0
    }

    function currentSinkVolumeNormalized() {
        return Math.max(0, normalizedVolume(effectiveVolume()))
    }

    function refreshConnectedBluetoothAudioName() {
        let nextName = ""
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
                nextName = bDevice.deviceName || bDevice.name || "Bluetooth"
                break
            }
        }

        if (connectedBluetoothAudioName !== nextName) {
            connectedBluetoothAudioName = nextName
            updateVolumeLabel()
        }
    }

    function maybeSnapBluetoothVolumeTo5Percent() {
        if (!sinkAudio || applyingBluetoothSnap) {
            return
        }

        // Only snap when an audio Bluetooth device is currently connected.
        if (!connectedBluetoothAudioName) {
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

    function updateVolumeLabel() {
        if (!sinkAudio) {
            volumeLabelText = "󰖁  --%"
            return
        }

        const volume = normalizedVolume(effectiveVolume())
        const pct = Math.min(150, Math.max(0, Math.round(volume * 100)))
        const icon = volumeIconForPercent(pct, sinkAudio.muted)
        const btName = connectedBluetoothAudioName

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
                    root.refreshConnectedBluetoothAudioName()
                }

                function onDeviceNameChanged() {
                    root.refreshConnectedBluetoothAudioName()
                }

                function onNameChanged() {
                    root.refreshConnectedBluetoothAudioName()
                }

                function onIconChanged() {
                    root.refreshConnectedBluetoothAudioName()
                }

                Component.onDestruction: root.refreshConnectedBluetoothAudioName()
            }
        }
    }

    Component.onCompleted: {
        sink = resolveDefaultSink()
        sinkAudio = sink ? sink.audio : null
        refreshConnectedBluetoothAudioName()
        updateVolumeLabel()
    }

    // ==========================================
    // 1. WIFI (Event-Driven & Optimized)
    // ==========================================
    property string wifiLabel: "󰤭  Offline"

    Instantiator {
        model: Networking.devices
        
        delegate: Instantiator {
            // Filter strictly for Wi-Fi devices to save processing
            active: modelData.type === DeviceType.Wifi
            model: active ? modelData.networks : null
            
            // QtObject is purely logical. Zero visual overhead, zero polling!
            delegate: QtObject {
                id: netWatcher
                
                // 1. Reactive bindings
                property bool isConnected: modelData.connected
                property string netName: modelData.name
                property int signalPct: root.normalizedPercent(
                    modelData.strength !== undefined ? modelData.strength :
                    (modelData.signalStrength !== undefined ? modelData.signalStrength :
                    (modelData.signal !== undefined ? modelData.signal : 100))
                )

                // MEMORY: Track the name used when this specifically connected
                property string activeName: ""

                // 2. State synchronization function
                function syncState() {
                    if (isConnected) {
                        activeName = netName || "WiFi"
                        root.wifiLabel = `${root.wifiIconForPercent(signalPct)}  ${activeName}`
                    } else if (activeName !== "") {
                        // Only set to offline if THIS network was the one previously connected
                        if (root.wifiLabel.endsWith(`  ${activeName}`)) {
                            root.wifiLabel = "󰤭  Offline"
                        }
                        activeName = "" // Clear memory
                    }
                }

                // 3. Signal listeners
                onIsConnectedChanged: syncState()
                onNetNameChanged: syncState()
                onSignalPctChanged: syncState()

                Component.onCompleted: syncState()

                // SAFETY: Catch when the Wi-Fi radio is toggled off and the network is destroyed
                Component.onDestruction: {
                    if (activeName !== "" && root.wifiLabel.endsWith(`  ${activeName}`)) {
                        root.wifiLabel = "󰤭  Offline"
                    }
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
        const pct = normalizedPercent(raw)
        const charging = battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge
        const icon = charging ? "" : batteryIconForPercent(pct)
        
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
            text: ""
            color: Theme.text
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font"
        }
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: GlobalState.showControlCenter = !GlobalState.showControlCenter
        }
    }

    // 4. Notification Panel Toggle Process
    Process {
        id: notifToggleProcess
    }

    Pill {
        implicitWidth: 32
        Text {
            anchors.centerIn: parent
            text: root.notificationIconForState(root.notificationsPresent, root.notificationsDnd)
            color: Theme.text
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font"
        }
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                // Opens the SwayNC side panel
                notifToggleProcess.running = false
                notifToggleProcess.command = ["swaync-client", "-t"]
                notifToggleProcess.running = true
            }
        }
    }
}