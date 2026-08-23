import QtQuick
import "../components"
import "../style"

// Network status: wifi SSID / ethernet / offline. Polls nmcli every 10s.
// Coherent hover/pressed treatment with a classic tooltip on hover.
Item {
  id: root

  Theme {
    id: theme
  }

  required property var tooltip

  implicitWidth: label.implicitWidth + 12
  implicitHeight: theme.controlSize

  property string status: ""
  property bool _sawConnected: false

  readonly property string tooltipText: {
    if (root.status === "") return "No network connection"
    return "Network: " + root.status
  }

  ButtonFrame {
    id: button
    anchors.fill: parent

    onHoveredChanged: {
      if (!enabled) return
      if (hovered) root.tooltip.showFor(button, root.tooltipText)
      else root.tooltip.hide()
    }
  }

  Text {
    id: label
    anchors.centerIn: button
    font.pixelSize: theme.textSize
    color: root.status === "" ? theme.textFaint
         : button.hovered ? theme.textPrimary
         : theme.textSecondary
    text: root.status
  }

  NmcliPoll {
    onPollStarted: {
      root._sawConnected = false
    }
    onResult: line => root.parse(line)
    onPollDone: {
      if (!root._sawConnected) root.status = ""
    }
  }

  function parse(line) {
    // TYPE:STATE:CONNECTION
    const parts = line.split(":")
    if (parts.length < 2) return
    const type = parts[0]
    const state = parts[1]
    if (state !== "connected") return
    const conn = parts.length > 2 ? parts[2] : ""
    if (type === "wifi") {
      root._sawConnected = true
      root.status = conn === "" ? "wifi" : "wifi " + conn
    } else if (type === "ethernet") {
      root._sawConnected = true
      if (root.status.indexOf("wifi") !== 0) {
        root.status = conn === "" ? "eth" : "eth " + conn
      }
    }
  }
}