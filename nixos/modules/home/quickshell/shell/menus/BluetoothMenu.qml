import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import "../components"
import "../style"

Popup {
  id: root

  required property var bluetoothService

  Theme { id: theme }

  topColor: theme.surfaceGradTop
  bottomColor: theme.surfaceGradBottom

  function rowWidth() {
    return 304
  }

  onVisibleChanged: {
    if (visible) root.bluetoothService.openMenu()
    else root.bluetoothService.closeMenu()
  }

  content: Column {
    width: root.rowWidth()
    spacing: 7

    Row {
      width: parent.width
      height: 26
      spacing: 7

      IconImage {
        width: 18
        height: 18
        anchors.verticalCenter: parent.verticalCenter
        source: Quickshell.iconPath(
          "preferences-system-bluetooth", "preferences-system-bluetooth-inactive"
        )
        opacity: root.bluetoothService.available ? 1 : 0.45
      }

      Column {
        width: parent.width - powerButton.width - 25
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
          color: theme.textOnActive
          font.pixelSize: theme.textSizeLarge
          font.bold: true
          text: "Bluetooth"
        }

        Text {
          color: theme.textOnActiveSecondary
          font.pixelSize: 9
          text: root.bluetoothService.available
            ? (root.bluetoothService.enabled ? root.bluetoothService.statusText : "Adapter disabled")
            : "No adapter"
          elide: Text.ElideRight
          width: parent.width
        }
      }

      ButtonFrame {
        id: powerButton
        width: 52
        height: 24
        enabled: root.bluetoothService.available
        checked: root.bluetoothService.enabled
        onClicked: root.bluetoothService.setEnabled(!root.bluetoothService.enabled)

        Text {
          anchors.centerIn: parent
          color: parent.enabled ? theme.textPrimary : theme.textFaint
          font.pixelSize: theme.textSize
          text: root.bluetoothService.enabled ? "ON" : "OFF"
        }
      }
    }

    Rectangle {
      width: parent.width
      height: 1
      color: theme.trackBorder
    }

    Text {
      visible: !root.bluetoothService.available
      width: parent.width
      color: theme.textMuted
      font.pixelSize: theme.textSize
      text: "Plug in a Bluetooth adapter to manage devices."
      wrapMode: Text.WordWrap
    }

    Text {
      visible: root.bluetoothService.available && !root.bluetoothService.enabled
      width: parent.width
      color: theme.textMuted
      font.pixelSize: theme.textSize
      text: "Bluetooth is off. Paired devices remain listed below."
      wrapMode: Text.WordWrap
    }

    ScrollView {
      id: deviceScroll
      width: parent.width
      height: root.bluetoothService.available
        ? Math.min(300, Math.max(1, deviceColumn.implicitHeight)) : 1
      visible: root.bluetoothService.available
      clip: true
      contentWidth: availableWidth
      ScrollBar.vertical.policy: ScrollBar.AsNeeded

      Column {
        id: deviceColumn
        width: deviceScroll.availableWidth
        spacing: 5

        SectionHeader {
          width: parent.width
          visible: root.bluetoothService.connectedCount > 0
          label: "Connected"
          topLine: false
        }

        Repeater {
          model: root.bluetoothService.connectedDevices

          BluetoothDeviceRow {
            required property var modelData
            width: deviceColumn.width
            device: modelData
            service: root.bluetoothService
            enabled: root.bluetoothService.enabled
            onForgetRequested: device => root.bluetoothService.forget(device)
          }
        }

        SectionHeader {
          width: parent.width
          visible: root.bluetoothService.pairedCount > 0
          label: "Paired"
          topLine: root.bluetoothService.connectedCount > 0
        }

        Repeater {
          model: root.bluetoothService.pairedDevices

          BluetoothDeviceRow {
            required property var modelData
            width: deviceColumn.width
            device: modelData
            service: root.bluetoothService
            enabled: root.bluetoothService.enabled
            onForgetRequested: device => root.bluetoothService.forget(device)
          }
        }

        SectionHeader {
          width: parent.width
          visible: root.bluetoothService.enabled
            && root.bluetoothService.availableCount > 0
          label: "Available"
          topLine: root.bluetoothService.connectedCount > 0
            || root.bluetoothService.pairedCount > 0
        }

        Repeater {
          model: root.bluetoothService.availableDevices

          BluetoothDeviceRow {
            required property var modelData
            width: deviceColumn.width
            device: modelData
            service: root.bluetoothService
            enabled: root.bluetoothService.enabled
            onForgetRequested: device => root.bluetoothService.forget(device)
          }
        }

        Text {
          visible: root.bluetoothService.enabled
            && root.bluetoothService.connectedCount === 0
            && root.bluetoothService.pairedCount === 0
            && root.bluetoothService.availableCount === 0
          width: parent.width
          color: theme.textMuted
          font.pixelSize: theme.textSize
          text: root.bluetoothService.discovering
            ? "Scanning for nearby devices…"
            : "No devices found. Start a scan to look nearby."
        }
      }
    }

    Row {
      width: parent.width
      height: 26
      spacing: 6

      ButtonFrame {
        width: 90
        height: 26
        enabled: root.bluetoothService.enabled
          && (!root.bluetoothService.discovering || root.bluetoothService.discoveryOwned)
        checked: root.bluetoothService.discoveryOwned
        onClicked: {
          if (root.bluetoothService.discoveryOwned) root.bluetoothService.stopDiscovery()
          else root.bluetoothService.beginDiscovery()
        }

        Text {
          anchors.centerIn: parent
          color: parent.enabled ? theme.textSecondary : theme.textFaint
          font.pixelSize: theme.textSize
          text: root.bluetoothService.discovering ? "Stop scan" : "Scan"
        }
      }

      ButtonFrame {
        width: 130
        height: 26
        enabled: root.bluetoothService.available
        onClicked: {
          root.close()
          root.bluetoothService.launchAdvancedPairing()
        }

        Text {
          anchors.centerIn: parent
          color: parent.enabled ? theme.textSecondary : theme.textFaint
          font.pixelSize: theme.textSize
          text: "Advanced pairing…"
        }
      }
    }
  }
}
