import Quickshell
import Quickshell.Bluetooth
import QtQml
import QtQuick

// Thin policy layer over Quickshell.Bluetooth.
//
// Native adapter/device objects remain the source of truth. This service only
// selects the default adapter, derives stable groups, and owns discovery that
// was started by the Bluetooth menu.
Item {
  id: root

  readonly property var adapters: Bluetooth.adapters ? Bluetooth.adapters.values : []
  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property bool available: !!root.adapter
  readonly property bool enabled: !!root.adapter && root.adapter.enabled
  readonly property bool discovering: !!root.adapter && root.adapter.discovering
  readonly property bool discoveryOwned: root.requestedDiscovery
  readonly property bool menuOpen: root._menuOpen

  property int modelRevision: 0
  property bool requestedDiscovery: false
  property var discoveryAdapter: null
  property bool _menuOpen: false

  readonly property var allDevices: {
    const revision = root.modelRevision
    void revision
    return Bluetooth.devices ? Bluetooth.devices.values : []
  }

  // Use Quickshell's current default adapter for Phase A. Device objects from
  // other adapters remain tracked by BlueZ but do not leak into this menu.
  readonly property var devices: {
    const revision = root.modelRevision
    void revision
    const current = root.adapter
    if (!current) return []
    return root.allDevices.filter(device => {
      if (!device) return false
      return device.adapter === current
    })
  }

  readonly property var connectedDevices: root.sortedDevices(
    root.devices.filter(device => device.connected)
  )

  readonly property var pairedDevices: root.sortedDevices(
    root.devices.filter(device => !device.connected && root.isPaired(device))
  )

  readonly property var availableDevices: root.sortedDevices(
    root.devices.filter(device => {
      if (device.connected || root.isPaired(device) || device.blocked) return false
      return !root.isAddressOnly(device)
    })
  )

  readonly property string statusText: {
    if (!root.available) return "No Bluetooth adapter"
    if (!root.enabled) return "Bluetooth off"
    if (root.connectedDevices.length === 0) return "Bluetooth ready"
    return root.connectedDevices.length === 1
      ? root.displayName(root.connectedDevices[0])
      : root.connectedDevices.length + " devices connected"
  }

  Timer {
    id: discoveryTimer
    interval: 15000
    repeat: false
    onTriggered: root.stopDiscovery()
  }

  // Keep derived arrays current when adapters/devices hotplug or BlueZ changes
  // a state that affects classification.
  Connections {
    target: Bluetooth

    function onDefaultAdapterChanged() {
      root.modelRevision++
      root.handleAdapterAvailability()
    }
  }

  Connections {
    target: Bluetooth.adapters

    function onValuesChanged() {
      root.modelRevision++
      root.handleAdapterAvailability()
    }
  }

  Connections {
    target: Bluetooth.devices

    function onValuesChanged() {
      root.modelRevision++
    }
  }

  Instantiator {
    model: Bluetooth.devices

    delegate: Item {
      required property var modelData

      Connections {
        target: modelData
        ignoreUnknownSignals: true

        function onAddressChanged() { root.modelRevision++ }
        function onNameChanged() { root.modelRevision++ }
        function onDeviceNameChanged() { root.modelRevision++ }
        function onConnectedChanged() { root.modelRevision++ }
        function onPairedChanged() { root.modelRevision++ }
        function onBondedChanged() { root.modelRevision++ }
        function onPairingChanged() { root.modelRevision++ }
        function onBatteryAvailableChanged() { root.modelRevision++ }
        function onBatteryChanged() { root.modelRevision++ }
        function onStateChanged() { root.modelRevision++ }
        function onAdapterChanged() { root.modelRevision++ }
      }
    }
  }

  Connections {
    target: root.adapter
    ignoreUnknownSignals: true

    function onEnabledChanged() {
      if (!root.enabled) root.stopDiscovery()
      else if (root.menuOpen) root.beginDiscovery()
    }

    function onDiscoveringChanged() {
      root.modelRevision++
      // BlueZ may emit its signal before the bindable property has settled.
      // Reconcile on the next turn so our own start is not mistaken for an
      // external stop.
      Qt.callLater(root.reconcileDiscovery)
    }

    function onStateChanged() {
      root.modelRevision++
      if (!root.enabled) root.stopDiscovery()
    }
  }

  Component.onDestruction: root.stopDiscovery()

  function handleAdapterAvailability() {
    if (!root.adapter) {
      root.stopDiscovery()
      return
    }

    if (root.menuOpen && root.enabled) Qt.callLater(root.beginDiscovery)
  }

  function openMenu() {
    root._menuOpen = true
    if (root.enabled) root.beginDiscovery()
  }

  function closeMenu() {
    root._menuOpen = false
    root.stopDiscovery()
  }

  function setEnabled(value) {
    if (!root.adapter) return
    if (!value) root.stopDiscovery()
    root.adapter.enabled = value
  }

  function beginDiscovery() {
    if (!root.adapter || !root.enabled || root.discovering) return false

    root.requestedDiscovery = true
    root.discoveryAdapter = root.adapter
    root.discoveryAdapter.discovering = true
    discoveryTimer.restart()
    return true
  }

  function stopDiscovery() {
    discoveryTimer.stop()
    if (!root.requestedDiscovery) {
      root.discoveryAdapter = null
      return
    }

    const current = root.discoveryAdapter || root.adapter
    root.requestedDiscovery = false
    root.discoveryAdapter = null
    if (current && current.discovering) current.discovering = false
  }

  function reconcileDiscovery() {
    if (root.requestedDiscovery && root.discoveryAdapter && root.discoveryAdapter.discovering) return
    discoveryTimer.stop()
    root.requestedDiscovery = false
    root.discoveryAdapter = null
  }

  function connect(device) {
    if (!device || device.connected || device.pairing) return
    root.stopDiscovery()
    device.connect()
  }

  function disconnect(device) {
    if (!device || !device.connected) return
    device.disconnect()
  }

  function pair(device) {
    if (!device || device.paired || device.pairing) return
    // Never keep radio discovery active while BlueZ moves into pairing.
    root.stopDiscovery()
    device.pair()
  }

  function cancelPair(device) {
    if (device && device.pairing) device.cancelPair()
  }

  function forget(device) {
    if (!device) return
    root.stopDiscovery()
    device.forget()
  }

  function trust(device, value) {
    if (device) device.trusted = value
  }

  function setWakeAllowed(device, value) {
    if (device) device.wakeAllowed = value
  }

  function launchAdvancedPairing() {
    Quickshell.execDetached(["blueman-manager"])
  }

  function isPaired(device) {
    return !!device && (device.paired || device.bonded || device.trusted)
  }

  function displayName(device) {
    if (!device) return "Unknown device"
    const name = device.name || device.deviceName || ""
    return name !== "" ? name : "Unnamed device"
  }

  function isAddressOnly(device) {
    if (!device) return true
    const name = String(device.name || device.deviceName || "").trim()
    if (name === "") return true
    const address = String(device.address || "").toUpperCase()
    return name.toUpperCase() === address
      || /^[0-9A-F]{2}([:-][0-9A-F]{2}){5}$/.test(name)
  }

  function deviceIcon(device) {
    return device && device.icon ? device.icon : "bluetooth"
  }

  function deviceType(device) {
    const icon = String(deviceIcon(device)).toLowerCase()
    if (icon.indexOf("headset") >= 0 || icon.indexOf("audio") >= 0) return "Audio device"
    if (icon.indexOf("mouse") >= 0) return "Mouse"
    if (icon.indexOf("keyboard") >= 0) return "Keyboard"
    if (icon.indexOf("phone") >= 0 || icon.indexOf("mobile") >= 0) return "Phone"
    if (icon.indexOf("game") >= 0 || icon.indexOf("controller") >= 0) return "Controller"
    return "Bluetooth device"
  }

  function stateText(device) {
    if (!device) return "Unavailable"
    if (device.pairing) return "Pairing…"
    if (device.state === BluetoothDeviceState.Connecting) return "Connecting…"
    if (device.state === BluetoothDeviceState.Disconnecting) return "Disconnecting…"
    if (device.connected) return root.deviceType(device)
    if (root.isPaired(device)) return "Paired"
    return "Available"
  }

  function batteryText(device) {
    if (!device || !device.batteryAvailable) return ""
    return Math.round(device.battery * 100) + "%"
  }

  function sortedDevices(values) {
    const devices = values ? values.slice() : []
    return devices.sort((first, second) => {
      const firstNamed = !root.isAddressOnly(first)
      const secondNamed = !root.isAddressOnly(second)
      if (firstNamed !== secondNamed) return secondNamed - firstNamed

      const firstName = root.displayName(first).toLocaleLowerCase()
      const secondName = root.displayName(second).toLocaleLowerCase()
      const byName = firstName.localeCompare(secondName)
      if (byName !== 0) return byName
      return String(first.address || "").localeCompare(String(second.address || ""))
    })
  }
}
