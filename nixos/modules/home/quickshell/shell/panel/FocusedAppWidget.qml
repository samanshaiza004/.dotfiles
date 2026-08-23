import QtQuick
import "../style"

// Focused application title (elided). Kept as an information surface rather
// than a control: restrained type, a faint divider, nothing shouty.
Item {
  id: root

  Theme {
    id: theme
  }

  required property var backend

  implicitWidth: Math.min(text.implicitWidth, 340)
  implicitHeight: theme.controlSize

  // Faint vertical divider separating the tag controls from app info.
  Rectangle {
    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
    anchors.topMargin: 4
    anchors.bottomMargin: 4
    width: 1
    color: "#26FFFFFF"
  }

  Text {
    id: text
    anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
    width: Math.min(implicitWidth, 332)
    elide: Text.ElideRight
    maximumLineCount: 1
    font.pixelSize: theme.textSize
    color: root.backend.focusedClient ? theme.focusedAppText : theme.textFaint
    text: {
      const c = root.backend.focusedClient
      if (c === null) return ""
      if (c.title) return c.title
      if (c.appid) return c.appid
      return ""
    }
  }
}