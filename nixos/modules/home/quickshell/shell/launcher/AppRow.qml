import Quickshell
import Quickshell.Widgets
import QtQuick
import "../components"
import "../style"

Item {
  id: root

  required property var entry
  required property int rowIndex
  property bool selected: false
  property var tooltip: null

  signal activated(int index)
  signal hovered(int index)

  implicitHeight: 48

  ButtonFrame {
    id: button
    anchors.fill: parent
    checked: root.selected

    onHoveredChanged: {
      if (hovered) root.hovered(root.rowIndex)
      if (root.tooltip) {
        if (hovered) root.tooltip.showFor(button, root.entry.name)
        else root.tooltip.hide()
      }
    }
    onClicked: root.activated(root.rowIndex)

    content: Row {
      anchors.fill: parent
      anchors.leftMargin: 8
      anchors.rightMargin: 8
      spacing: 8

      IconImage {
        width: 28
        height: 28
        anchors.verticalCenter: parent.verticalCenter
        asynchronous: true
        source: Quickshell.iconPath(root.entry.icon, "application-x-executable")
      }

      Column {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 36
        spacing: 1

        Text {
          width: parent.width
          color: theme.textPrimary
          elide: Text.ElideRight
          font.bold: root.selected
          font.pixelSize: theme.textSizeLarge
          text: root.entry.name
        }

        Text {
          visible: root.entry.genericName !== ""
          width: parent.width
          color: theme.textMuted
          elide: Text.ElideRight
          font.pixelSize: theme.textSize
          text: root.entry.genericName
        }
      }
    }
  }

  Theme { id: theme }
}
