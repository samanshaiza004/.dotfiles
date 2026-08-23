import QtQuick
import Quickshell.Widgets
import "../style"

// Reusable tray-item button: icon plus hover/pressed treatment, an optional
// shared tooltip, and primary/secondary activation. No tray logic lives here —
// the owner wires activation behavior to the SystemTray model, so this stays a
// pure visual primitive.
ButtonFrame {
  id: root

  Theme {
    id: theme
  }

  property string iconSource: ""
  property string tooltipText: ""
  property var tooltip: null
  property int iconSize: 16

  signal primaryActivated
  signal secondaryActivated

  implicitWidth: theme.controlSize
  implicitHeight: theme.controlSize

  content: IconImage {
    anchors.centerIn: parent
    source: root.iconSource
    asynchronous: true
    implicitSize: root.iconSize
  }

  onHoveredChanged: {
    if (!root.enabled) return
    if (root.hovered) {
      if (root.tooltip) root.tooltip.showFor(root, root.tooltipText)
    } else {
      if (root.tooltip) root.tooltip.hide()
    }
  }

  onClicked: root.primaryActivated()
  onRightClicked: root.secondaryActivated()
}