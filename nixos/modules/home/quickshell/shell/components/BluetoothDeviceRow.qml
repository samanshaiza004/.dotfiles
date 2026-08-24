import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets
import QtQuick
import "../style"

// One Bluetooth device row shared by CONNECTED, PAIRED, and AVAILABLE groups.
// The primary action stays immediate; less common controls live behind the
// disclosure button so the list remains calm with several devices.
Item {
  id: root

  Theme { id: theme }

  required property var device
  required property var service

  property bool expanded: false
  property bool forgetArmed: false

  readonly property bool busy: root.device
    && (root.device.pairing
      || root.device.state === BluetoothDeviceState.Connecting
      || root.device.state === BluetoothDeviceState.Disconnecting)
  readonly property string actionText: {
    if (!root.device) return ""
    if (root.device.pairing) return "Cancel"
    if (root.device.state === BluetoothDeviceState.Connecting) return "Connecting…"
    if (root.device.state === BluetoothDeviceState.Disconnecting) return "Disconnecting…"
    if (root.device.connected) return "Disconnect"
    if (root.service.isPaired(root.device)) return "Connect"
    return "Pair"
  }

  signal forgetRequested(var device)

  implicitHeight: 39 + (root.expanded ? 31 : 0)
  opacity: root.enabled ? 1.0 : 0.58

  Timer {
    id: forgetTimer
    interval: 3000
    repeat: false
    onTriggered: root.forgetArmed = false
  }

  Surface {
    anchors.fill: parent
    radius: theme.controlRadius
    topColor: root.device && root.device.connected
      ? theme.alpha(theme.accentDeep, 0.42) : theme.buttonGradTop
    bottomColor: root.device && root.device.connected
      ? theme.alpha(theme.accentDeep, 0.22) : theme.buttonGradBottom
    borderColor: root.device && root.device.connected
      ? theme.alpha(theme.accentBright, 0.58) : theme.buttonBorder
    topHighlight: root.device && root.device.connected
      ? theme.alpha(theme.accentBright, 0.28) : theme.buttonTopHighlight
    bottomShadow: theme.buttonBottomShadow
  }

  Row {
    id: mainRow
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      leftMargin: 7
      rightMargin: 7
    }
    height: 38
    spacing: 7

    IconImage {
      id: icon
      width: 18
      height: 18
      anchors.verticalCenter: parent.verticalCenter
      source: Quickshell.iconPath(root.service.deviceIcon(root.device), "bluetooth")
      asynchronous: true
      opacity: root.busy ? 0.6 : 1
    }

    Column {
      width: Math.max(0, parent.width - icon.width - actionButton.width - detailsButton.width
        - parent.spacing * 3)
      anchors.verticalCenter: parent.verticalCenter
      spacing: 1

      Text {
        width: parent.width
        elide: Text.ElideRight
        color: root.device && root.device.connected ? theme.textPrimary : theme.textSecondary
        font.pixelSize: theme.textSize
        font.bold: root.device && root.device.connected
        text: root.service.displayName(root.device)
      }

      Row {
        spacing: 5

        Text {
          color: root.busy ? theme.accentBright : theme.textMuted
          font.pixelSize: theme.textSize
          text: root.service.stateText(root.device)
        }

        Text {
          visible: root.device && root.device.batteryAvailable
          color: theme.textMuted
          font.pixelSize: theme.textSize
          text: root.service.batteryText(root.device)
        }

        ProgressBar {
          visible: root.device && root.device.batteryAvailable
          width: 42
          height: 6
          anchors.verticalCenter: parent.verticalCenter
          value: root.device && root.device.batteryAvailable ? root.device.battery : 0
          glowEnabled: false
        }
      }
    }

    ButtonFrame {
      id: actionButton
      width: Math.max(54, actionLabel.implicitWidth + 12)
      height: 24
      anchors.verticalCenter: parent.verticalCenter
      enabled: root.enabled && !!root.device && (!root.busy || root.device.pairing)
      checked: root.device && root.device.connected
      onClicked: {
        if (!root.device) return
        if (root.device.pairing) root.service.cancelPair(root.device)
        else if (root.device.connected) root.service.disconnect(root.device)
        else if (root.service.isPaired(root.device)) root.service.connect(root.device)
        else root.service.pair(root.device)
      }

      Text {
        id: actionLabel
        anchors.centerIn: parent
        color: parent.enabled ? theme.textPrimary : theme.textFaint
        font.pixelSize: theme.textSize
        text: root.actionText
      }
    }

    ButtonFrame {
      id: detailsButton
      width: 22
      height: 24
      anchors.verticalCenter: parent.verticalCenter
      checked: root.expanded
      onClicked: root.expanded = !root.expanded

      IconImage {
        anchors.centerIn: parent
        width: 14
        height: 14
        source: Quickshell.iconPath(root.expanded ? "go-up" : "view-more", "configure")
      }
    }
  }

  Row {
    id: advancedRow
    anchors {
      left: parent.left
      right: parent.right
      bottom: parent.bottom
      leftMargin: 7
      rightMargin: 7
    }
    height: 30
    spacing: 5
    visible: root.expanded

    Text {
      width: Math.max(0, parent.width - trustedButton.width - wakeButton.width - forgetButton.width
        - parent.spacing * 3)
      anchors.verticalCenter: parent.verticalCenter
      elide: Text.ElideRight
      color: theme.textFaint
      font.pixelSize: 9
      text: root.device ? root.device.address : ""
    }

    ButtonFrame {
      id: trustedButton
      width: 58
      height: 22
      enabled: root.enabled
      checked: root.device && root.device.trusted
      onClicked: root.service.trust(root.device, !root.device.trusted)

      Text {
        anchors.centerIn: parent
        color: theme.textSecondary
        font.pixelSize: 9
        text: root.device && root.device.trusted ? "Trusted" : "Trust"
      }
    }

    ButtonFrame {
      id: wakeButton
      width: 52
      height: 22
      enabled: root.enabled
      checked: root.device && root.device.wakeAllowed
      onClicked: root.service.setWakeAllowed(root.device, !root.device.wakeAllowed)

      Text {
        anchors.centerIn: parent
        color: theme.textSecondary
        font.pixelSize: 9
        text: "Wake"
      }
    }

    ButtonFrame {
      id: forgetButton
      width: 58
      height: 22
      activeGradTop: theme.buttonUrgentGradTop
      activeGradBottom: theme.buttonUrgentGradBottom
      activeTopHighlight: theme.buttonUrgentTopHighlight
      activeInnerEdge: theme.buttonUrgentInnerEdge
      activeGlowColor: theme.buttonUrgentGlow
      enabled: root.enabled
      checked: root.forgetArmed
      onClicked: {
        if (!root.forgetArmed) {
          root.forgetArmed = true
          forgetTimer.restart()
        } else {
          root.forgetArmed = false
          root.forgetRequested(root.device)
        }
      }

      Text {
        anchors.centerIn: parent
        color: root.forgetArmed ? theme.textOnUrgent : theme.textSecondary
        font.pixelSize: 9
        text: root.forgetArmed ? "Confirm" : "Forget"
      }
    }
  }
}
