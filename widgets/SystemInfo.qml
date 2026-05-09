import QtQuick
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

    // UI Labels (Using literal glyphs and double spacing)
    property string wifiLabel: "󰤭  Offline"
    property string volumeLabelText: "󰖁  --%"
    property string batteryLabelText: "󰁹  --%"

    // Pipewire Node Tracker
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    // ==========================================
    // 1. WIFI LOGIC
    // ==========================================
    function updateWifi() {
        const devices = Networking.devices?.values || []
        for (let i = 0; i < devices.length; i++) {
            const device = devices[i]
            if (device.type === DeviceType.Wifi) {
                const networks = device.networks?.values || []
                for (let j = 0; j < networks.length; j++) {
                    if (networks[j].connected) {
                        wifiLabel = `󰤨  ${networks[j].name || "WiFi"}`
                        return
                    }
                }
                if (device.connected) {
                    wifiLabel = "󰤨  WiFi"
                    return
                }
            }
        }
        wifiLabel = "󰤭  Offline"
    }

    // ==========================================
    // 2. VOLUME LOGIC
    // ==========================================
    function updateVolume() {
        if (!sinkAudio) {
            volumeLabelText = "󰖁  --%"
            return
        }

        let rawVol = sinkAudio.volume

        if ((rawVol === 0 || rawVol === undefined) && sinkAudio.volumes && sinkAudio.volumes.length > 0) {
            let total = 0
            for (let i = 0; i < sinkAudio.volumes.length; i++) {
                total += sinkAudio.volumes[i]
            }
            rawVol = total / sinkAudio.volumes.length
        }

        rawVol = rawVol !== undefined ? rawVol : 0
        const pct = Math.min(150, Math.max(0, Math.round(rawVol <= 1.5 ? rawVol * 100 : rawVol)))
        
        // Changed icons to consistent literal glyphs
        const icon = sinkAudio.muted ? "󰖁" : "󰕾"
        
        let btName = ""
        const bDevices = Bluetooth.devices?.values || []
        for (let i = 0; i < bDevices.length; i++) {
            const bDevice = bDevices[i]
            if (bDevice.connected) {
                const bIcon = (bDevice.icon || "").toLowerCase()
                if (bIcon.includes("audio") || bIcon.includes("headset") || bIcon.includes("headphone") || bIcon.includes("speaker")) {
                    btName = bDevice.deviceName || bDevice.name || "Bluetooth"
                    break
                }
            }
        }
        
        // Standardized double spacing
        volumeLabelText = btName ? `${icon}  ${pct}%  ${btName}` : `${icon}  ${pct}%`
    }

    // ==========================================
    // 3. BATTERY LOGIC
    // ==========================================
    function updateBattery() {
        if (!battery || !battery.ready || !battery.isPresent) {
            batteryLabelText = "󰁹  --%"
            return
        }
        
        const raw = battery.percentage || 0
        const pct = Math.max(0, Math.round(raw <= 1.5 ? raw * 100 : raw))
        
        const charging = battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge
        
        // Changed icons to literal glyphs
        const icon = charging ? "󰂄" : "󰁹"
        
        batteryLabelText = `${icon}  ${pct}%`
    }

    function updateAll() {
        updateWifi()
        updateVolume()
        updateBattery()
    }
    
    Component.onCompleted: updateAll()

    // ==========================================
    // SIGNAL LISTENERS
    // ==========================================
    Connections {
        target: Networking.devices
        function onValuesChanged() { root.updateWifi() }
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() { root.updateVolume() }
        function onDefaultConfiguredAudioSinkChanged() { root.updateVolume() }
    }

    Connections {
        target: root.sinkAudio
        function onVolumeChanged() { root.updateVolume() }
        function onMutedChanged() { root.updateVolume() }
    }

    Connections {
        target: root.battery
        function onPercentageChanged() { root.updateBattery() }
        function onStateChanged() { root.updateBattery() }
        function onReadyChanged() { root.updateBattery() }
        function onIsPresentChanged() { root.updateBattery() }
    }

    Connections {
        target: Bluetooth.devices
        function onValuesChanged() { root.updateVolume() }
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
            onClicked: print("Control Center clicked")
        }
    }
}1