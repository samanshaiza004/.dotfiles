import Quickshell.Networking
import QtQuick

// Native NetworkManager state. The watcher delegates turn per-device and
// per-network signals into one revision used by the derived panel summary.
Item {
  id: root

  readonly property var devices: Networking.devices.values
  property int stateRevision: 0
  property var errorNetwork: null
  property string errorText: ""

  Instantiator {
    model: Networking.devices

    delegate: Item {
      required property var modelData

      Connections {
        target: modelData
        function onConnectedChanged() { root.stateRevision++ }
        function onStateChanged() { root.stateRevision++ }
        function onNameChanged() { root.stateRevision++ }
      }

      Instantiator {
        model: modelData.networks

        delegate: Item {
          required property var modelData

          Connections {
            target: modelData
            function onConnectedChanged() { root.stateRevision++ }
            function onStateChanged() { root.stateRevision++ }
            function onNameChanged() { root.stateRevision++ }
            function onConnectionFailed(reason) {
              root.errorNetwork = modelData
              root.errorText = ConnectionFailReason.toString(reason)
              root.stateRevision++
            }
          }
        }
      }
    }
  }

  readonly property string statusText: {
    const revision = root.stateRevision
    void revision

    for (const device of root.devices) {
      if (device.type === DeviceType.Wired && device.connected) return "eth"
    }

    for (const device of root.devices) {
      if (device.type !== DeviceType.Wifi || !device.connected) continue
      const network = root.activeNetwork(device)
      return network ? "wifi " + network.name : "wifi"
    }

    return ""
  }

  readonly property string statusIconName: {
    const revision = root.stateRevision
    void revision

    for (const device of root.devices) {
      if (device.type === DeviceType.Wired && device.connected) return "network-wired"
    }

    for (const device of root.devices) {
      if (device.type !== DeviceType.Wifi || !device.connected) continue
      return root.wifiIconName(root.activeNetwork(device))
    }

    return "network-wireless-disconnected"
  }

  function isWifiDevice(device) {
    return !!device && device.type === DeviceType.Wifi
  }

  function isWiredDevice(device) {
    return !!device && device.type === DeviceType.Wired
  }

  function activeNetwork(device) {
    if (!device) return null
    for (const network of device.networks.values) {
      if (network.connected) return network
    }
    return null
  }

  function isProtected(network) {
    return network && network.security !== WifiSecurityType.Open
  }

  function sortedNetworks(device) {
    const revision = root.stateRevision
    void revision
    if (!device) return []
    return [...device.networks.values].sort((a, b) => {
      if (a.connected !== b.connected) return b.connected - a.connected
      if (a.known !== b.known) return b.known - a.known
      return (b.signalStrength || 0) - (a.signalStrength || 0)
    })
  }

  function signalLevel(network) {
    if (!network || network.signalStrength === undefined) return 0
    return Math.max(0, Math.min(4, Math.round(network.signalStrength * 4)))
  }

  function wifiIconName(network) {
    const levels = ["00", "25", "50", "75", "100"]
    return "network-wireless-connected-" + levels[root.signalLevel(network)]
  }

  function networkState(network) {
    if (!network) return "normal"
    if (root.errorNetwork === network) return "error"
    if (network.state === ConnectionState.Connecting
        || network.state === ConnectionState.Disconnecting) return "connecting"
    if (network.connected) return "connected"
    return "normal"
  }

  function networkDetail(network) {
    const state = root.networkState(network)
    if (state === "error") return root.errorText || "failed"
    if (state === "connecting") return "connecting"
    if (state === "connected") return "connected"
    if (network && network.known) return "saved"
    return ""
  }

  function connectNetwork(network, password) {
    if (!network) return
    root.errorNetwork = null
    root.errorText = ""
    if (password !== undefined && password !== "" && network.connectWithPsk) {
      network.connectWithPsk(password)
    } else {
      network.connect()
    }
  }

  function disconnect(device) {
    if (device) device.disconnect()
  }

  function forget(network) {
    if (network) network.forget()
  }

  function setScanning(enabled) {
    for (const device of root.devices) {
      if (root.isWifiDevice(device)) device.scannerEnabled = enabled
    }
  }
}
