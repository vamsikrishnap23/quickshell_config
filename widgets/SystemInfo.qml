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
    anchors.verticalCenter: parent.verticalCenter
    spacing: 10

    property var sink: Pipewire.defaultAudioSink || Pipewire.preferredDefaultAudioSink
    property var sinkAudio: sink ? sink.audio : null
    property var battery: UPower.displayDevice

    property string wifiLabel: "\uf1eb Offline"
    property string volumeLabelText: "\uf028 --%"
    property string batteryLabelText: "\uf240 --%"

    function updateWifi() {
        const devices = Networking.devices?.values || []
        for (let i = 0; i < devices.length; i++) {
            const device = devices[i]
            if (device.type === DeviceType.Wifi) {
                const networks = device.networks?.values || []
                for (let j = 0; j < networks.length; j++) {
                    const network = networks[j]
                    if (network.connected) {
                        wifiLabel = "\uf1eb " + (network.name || "WiFi")
                        return
                    }
                }
                if (device.connected) {
                    wifiLabel = "\uf1eb WiFi"
                    return
                }
            }
        }
        wifiLabel = "\uf1eb Offline"
    }

    function updateVolume() {
        if (!sinkAudio) {
            volumeLabelText = "\uf028 --%"
            return
        }
        let raw = sinkAudio.volume
        if ((raw === 0 || raw === undefined) && sinkAudio.volumes && sinkAudio.volumes.length > 0) {
            let total = 0
            for (let i = 0; i < sinkAudio.volumes.length; i++) {
                total += sinkAudio.volumes[i]
            }
            raw = total / sinkAudio.volumes.length
        }
        const normalized = raw <= 1.5 ? raw * 100 : raw
        const pct = Math.max(0, Math.round(normalized))
        const icon = sinkAudio.muted ? "\uf6a9" : "\uf028"
        
        // Find bluetooth device if any
        let bt = ""
        const bDevices = Bluetooth.devices?.values || []
        for (let i = 0; i < bDevices.length; i++) {
            const bDevice = bDevices[i]
            if (bDevice.connected) {
                const bIcon = (bDevice.icon || "").toLowerCase()
                if (bIcon.includes("audio") || bIcon.includes("headset") || bIcon.includes("headphone") || bIcon.includes("speaker")) {
                    bt = bDevice.deviceName || bDevice.name || "Bluetooth"
                    break
                }
            }
        }
        
        volumeLabelText = bt ? icon + " " + pct + "% " + bt : icon + " " + pct + "%"
    }

    function updateBattery() {
        if (!battery || !battery.ready || !battery.isPresent) {
            batteryLabelText = "\uf240 --%"
            return
        }
        const raw = battery.percentage
        const normalized = raw <= 1.5 ? raw * 100 : raw
        const pct = Math.max(0, Math.round(normalized))
        const charging = battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge
        const icon = charging ? "\uf0e7" : "\uf240"
        batteryLabelText = icon + " " + pct + "%"
    }

    function updateAll() {
        updateWifi()
        updateVolume()
        updateBattery()
    }

    Component.onCompleted: updateAll()

    Connections {
        target: Networking.devices
        function onValuesChanged() { root.updateWifi() }
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() { root.updateVolume() }
        function onDefaultConfiguredAudioSinkChanged() { root.updateVolume() }
        function onReadyChanged() { root.updateVolume() }
    }

    Connections {
        target: root.sinkAudio
        function onVolumesChanged() { root.updateVolume() }
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
}
