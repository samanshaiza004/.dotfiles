import QtQuick

// Network status: wifi SSID / ethernet / offline. Polls nmcli every 10s.
Item {
  id: root

  implicitWidth: text.implicitWidth
  implicitHeight: 24

  property string status: ""
  property bool _sawConnected: false

  Text {
    id: text
    anchors.centerIn: parent
    font.pixelSize: 11
    color: root.status === "" ? "#6b665b" : "#d8d2c2"
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
