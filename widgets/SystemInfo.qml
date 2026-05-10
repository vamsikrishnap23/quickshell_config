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

    // Pipewire Node Tracker
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
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
    property string volumeLabelText: {
        if (!sinkAudio) return "󰖁  --%"

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
        
        return btName ? `${icon}  ${pct}%  ${btName}` : `${icon}  ${pct}%`
    }

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