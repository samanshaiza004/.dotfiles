import Quickshell.Networking
import QtQuick
import "../components"
import "../style"

Popup {
  id: root

  required property var networkService
  property var pendingNetwork: null
  property string password: ""

  Theme { id: theme }

  function requestConnect(network) {
    if (!network) return
    if (root.networkService.isProtected(network) && !network.known) {
      root.pendingNetwork = network
      root.password = ""
      passwordInput.forceActiveFocus()
    } else {
      root.networkService.connectNetwork(network)
    }
  }

  onVisibleChanged: {
    if (visible) root.networkService.setScanning(true)
    else root.networkService.setScanning(false)
  }

  content: Column {
    width: 260
    spacing: 7

    Text {
      color: theme.textOnActive
      font.pixelSize: theme.textSizeLarge
      font.bold: true
      text: root.networkService.statusText || "Network"
    }

    Repeater {
      model: root.networkService.devices

      Column {
        id: deviceColumn
        required property var modelData
        width: 260
        spacing: 4

        Text {
          color: theme.textMuted
          font.pixelSize: theme.textSize
          text: deviceColumn.modelData.type === DeviceType.Wifi
            ? "Wi-Fi (" + deviceColumn.modelData.name + ")" : "Ethernet (" + deviceColumn.modelData.name + ")"
        }

        MenuRow {
          width: 260
          visible: deviceColumn.modelData.type === DeviceType.Wired
          label: deviceColumn.modelData.connected ? "Connected" : "Disconnected"
          detail: deviceColumn.modelData.connected ? "disconnect" : ""
          selected: deviceColumn.modelData.connected
          onClicked: root.networkService.disconnect(deviceColumn.modelData)
        }

        Repeater {
          model: deviceColumn.modelData.networks.values

          MenuRow {
            required property var modelData
            width: 260
            visible: deviceColumn.modelData.type === DeviceType.Wifi
            label: modelData.name || "Hidden network"
            detail: modelData.connected ? "connected"
                   : modelData.signalStrength !== undefined
                     ? Math.round(modelData.signalStrength * 100) + "%" : ""
            selected: modelData.connected
            onClicked: root.requestConnect(modelData)
          }
        }
      }
    }

    Text {
      visible: root.pendingNetwork !== null
      color: theme.textSecondary
      font.pixelSize: theme.textSize
      text: root.pendingNetwork ? "Password for " + root.pendingNetwork.name : ""
    }

    Row {
      visible: root.pendingNetwork !== null
      width: parent.width
      spacing: 6

      Rectangle {
        width: 174
        height: 26
        color: theme.trackColor
        border.width: 1
        border.color: theme.trackBorder

        TextInput {
          id: passwordInput
          anchors.fill: parent
          anchors.leftMargin: 7
          anchors.rightMargin: 7
          verticalAlignment: TextInput.AlignVCenter
          color: theme.textPrimary
          echoMode: TextInput.Password
          font.pixelSize: theme.textSize
          clip: true
          text: root.password
          onTextChanged: root.password = text
        }
      }

      ButtonFrame {
        width: 38
        height: 26
        onClicked: {
          root.networkService.connectNetwork(root.pendingNetwork, root.password)
          root.pendingNetwork = null
          root.password = ""
        }

        Text {
          anchors.centerIn: parent
          color: theme.textPrimary
          font.pixelSize: theme.textSize
          text: "Go"
        }
      }

      ButtonFrame {
        width: 38
        height: 26
        onClicked: root.pendingNetwork = null

        Text {
          anchors.centerIn: parent
          color: theme.textSecondary
          font.pixelSize: theme.textSize
          text: "X"
        }
      }
    }
  }
}
