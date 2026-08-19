import QtQuick

// Focused application title (elided).
Item {
  id: root

  required property var backend

  implicitWidth: Math.min(text.implicitWidth, 340)
  implicitHeight: 24

  Text {
    id: text
    anchors.centerIn: parent
    width: Math.min(implicitWidth, 340)
    elide: Text.ElideRight
    maximumLineCount: 1
    font.pixelSize: 11
    color: "#d8d2c2"
    text: {
      const c = root.backend.focusedClient
      if (c === null) return ""
      if (c.title) return c.title
      if (c.appid) return c.appid
      return ""
    }
  }
}
