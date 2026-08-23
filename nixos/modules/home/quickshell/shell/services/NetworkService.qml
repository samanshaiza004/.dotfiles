import Quickshell.Networking
import QtQuick

// Native NetworkManager state. The watcher delegates turn per-device and
// per-network signals into one revision used by the derived panel summary.
Item {
  id: root

  readonly property var devices: Networking.devices.values
  property int stateRevision: 0

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

  readonly property string tooltipText: root.statusText === ""
    ? "No network connection" : "Network: " + root.statusText

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

  function connectNetwork(network, password) {
    if (!network) return
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
