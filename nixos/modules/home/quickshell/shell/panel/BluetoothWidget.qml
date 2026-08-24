import Quickshell
import Quickshell.Widgets
import QtQuick
import "../components"
import "../menus"
import "../style"

// Compact Bluetooth status/control surface. Keep the panel stable when no
// adapter is present; the popup carries the full device management workflow.
Item {
  id: root

  Theme { id: theme }

  required property var bluetoothService
  required property var tooltip
  required property var panelWindow
  required property var closeOthers
  required property var popupController

  implicitWidth: theme.controlSize + (root.bluetoothService.connectedDevices.length > 0 ? 12 : 0)
  implicitHeight: theme.controlSize

  readonly property string tooltipText: {
    if (!root.bluetoothService.available) return "Bluetooth: no adapter"
    if (!root.bluetoothService.enabled) return "Bluetooth: off"
    const devices = root.bluetoothService.connectedDevices
    if (devices.length === 0) return "Bluetooth: no connected devices"
    return "Bluetooth: " + devices.map(device => root.bluetoothService.displayName(device)).join(", ")
  }

  function closePopup() {
    bluetoothPopup.close()
  }

  ButtonFrame {
    id: button
    anchors.fill: parent
    checked: root.bluetoothService.enabled && root.bluetoothService.connectedDevices.length > 0
    enabled: true

    onHoveredChanged: {
      if (!root.tooltip) return
      if (hovered) root.tooltip.showFor(button, root.tooltipText)
      else root.tooltip.hide()
    }

    onClicked: {
      if (bluetoothPopup.visible) bluetoothPopup.close()
      else {
        root.closeOthers()
        bluetoothPopup.open()
      }
    }

    content: Row {
      anchors.centerIn: parent
      spacing: 3

      IconImage {
        width: 14
        height: 14
        anchors.verticalCenter: parent.verticalCenter
        source: Quickshell.iconPath("bluetooth", "preferences-system-bluetooth")
        asynchronous: true
        opacity: !root.bluetoothService.available || !root.bluetoothService.enabled ? 0.48 : 1
      }

      Text {
        visible: root.bluetoothService.connectedDevices.length > 0
        anchors.verticalCenter: parent.verticalCenter
        color: root.bluetoothService.enabled ? theme.textSecondary : theme.textMuted
        font.pixelSize: theme.textSize
        text: root.bluetoothService.connectedDevices.length
      }
    }
  }

  BluetoothMenu {
    id: bluetoothPopup
    target: button
    panelWindow: root.panelWindow
    bluetoothService: root.bluetoothService
    popupController: root.popupController
  }
}
