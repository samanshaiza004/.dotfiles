import QtQuick
import "../style"

Item {
  id: root

  Theme { id: theme }

  property string label: ""
  property bool topLine: true

  implicitHeight: 21

  Rectangle {
    visible: root.topLine
    anchors { left: parent.left; right: parent.right; top: parent.top }
    height: 1
    color: theme.trackBorder
  }

  Text {
    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
    color: theme.textSecondary
    font.pixelSize: theme.textSize
    font.bold: true
    text: root.label.toUpperCase()
  }
}
