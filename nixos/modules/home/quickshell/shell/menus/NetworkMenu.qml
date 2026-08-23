import Quickshell.Networking
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
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

  function wifiIcon(network) {
    return root.networkService.wifiIconName(network)
  }

  onVisibleChanged: {
    if (visible) root.networkService.setScanning(true)
    else root.networkService.setScanning(false)
  }

  content: Column {
    width: 280
    spacing: 7

    Text {
      color: theme.textOnActive
      font.pixelSize: theme.textSizeLarge
      font.bold: true
      text: root.networkService.statusText || "Network"
    }

    ScrollView {
      id: networkScroll
      width: parent.width
      height: Math.min(300, Math.max(1, networkList.implicitHeight))
      clip: true
      contentWidth: availableWidth
      ScrollBar.vertical.policy: ScrollBar.AsNeeded

      Column {
        id: networkList
        width: networkScroll.availableWidth
        spacing: 8

        Repeater {
          model: root.networkService.devices

          Column {
            id: deviceColumn
            required property var modelData
            required property int index
            width: networkList.width
            spacing: 4

            SectionHeader {
              width: parent.width
              label: deviceColumn.modelData.type === DeviceType.Wifi
                ? "Wi-Fi · " + deviceColumn.modelData.name
                : "Ethernet · " + deviceColumn.modelData.name
              topLine: deviceColumn.index > 0
            }

            MenuRow {
              width: parent.width
              visible: deviceColumn.modelData.type === DeviceType.Wired
              iconName: "network-wired"
              label: deviceColumn.modelData.connected ? "Connected" : "Disconnected"
              detail: deviceColumn.modelData.connected ? "disconnect" : ""
              selected: deviceColumn.modelData.connected
              statusKind: deviceColumn.modelData.connected ? "connected" : "normal"
              onClicked: root.networkService.disconnect(deviceColumn.modelData)
            }

            Repeater {
              model: root.networkService.sortedNetworks(deviceColumn.modelData)

              MenuRow {
                required property var modelData
                width: deviceColumn.width
                visible: deviceColumn.modelData.type === DeviceType.Wifi
                iconName: root.wifiIcon(modelData)
                overlayIconName: root.networkService.isProtected(modelData)
                  ? "emblem-locked" : ""
                label: modelData.name || "Hidden network"
                detail: root.networkService.networkDetail(modelData)
                selected: modelData.connected
                statusKind: root.networkService.networkState(modelData)
                onClicked: root.requestConnect(modelData)
              }
            }
          }
        }
      }
    }

    SectionHeader {
      width: parent.width
      visible: root.pendingNetwork !== null
      label: root.pendingNetwork ? "Authentication" : ""
      topLine: true
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
        width: 190
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
