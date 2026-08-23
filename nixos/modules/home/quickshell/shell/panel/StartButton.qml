import Quickshell
import Quickshell.Widgets
import QtQuick
import "../components"
import "../style"

Item {
  id: root

  required property var launcher
  property var tooltip: null

  Theme { id: theme }

  implicitWidth: 30
  implicitHeight: theme.controlSize

  ButtonFrame {
    id: button
    anchors.fill: parent
    checked: root.launcher && (root.launcher.visible || root.launcher.closing)

    onHoveredChanged: {
      if (!root.tooltip) return
      if (hovered) root.tooltip.showFor(button, "Applications")
      else root.tooltip.hide()
    }
    onClicked: root.launcher.toggle()

    content: IconImage {
      anchors.centerIn: parent
      asynchronous: true
      width: 18
      height: 18
      source: Quickshell.iconPath("start-here", "application-x-executable")
    }
  }
}
