import QtQuick
import Quickshell.Widgets
import "../style"

// Task/shell-oriented control: a ButtonFrame carrying an optional icon and/or
// label, with an active state and an urgent state layered on top.
//
// The active treatment is depth + restrained glow, not a flat bright fill.
// It is deliberately free of application logic so it can later represent
// running applications in a taskbar without hard-coding anything here.
ButtonFrame {
  id: root

  Theme {
    id: theme
  }

  property string iconSource: ""
  property string label: ""
  property int iconSize: 16
  property int labelSize: theme.textSize
  property bool urgent: false
  property bool muted: false
  property bool iconOnly: false
  property int minWidth: 26
  property int paddingX: 6

  // Urgent reuses the whole active machinery with a warm treatment.
  activeGradTop: root.urgent ? theme.buttonUrgentGradTop : theme.buttonActiveGradTop
  activeGradBottom: root.urgent ? theme.buttonUrgentGradBottom : theme.buttonActiveGradBottom
  activeTopHighlight: root.urgent ? theme.buttonUrgentTopHighlight : theme.buttonActiveTopHighlight
  activeInnerEdge: root.urgent ? theme.buttonUrgentInnerEdge : theme.buttonActiveInnerEdge
  activeGlowColor: root.urgent ? theme.buttonUrgentGlow : theme.buttonActiveGlow

  implicitWidth: Math.max(row.implicitWidth + root.paddingX * 2, root.minWidth)
  implicitHeight: theme.controlSize
  opacity: root.muted ? 0.72 : 1.0

  content: Row {
    id: row
    x: root.iconOnly ? (parent.width - width) / 2 : root.paddingX
    width: root.iconOnly ? implicitWidth : Math.max(0, parent.width - root.paddingX * 2)
    anchors.verticalCenter: parent.verticalCenter
    spacing: 4

    IconImage {
      id: taskIcon
      visible: root.iconSource !== ""
      source: root.iconSource
      asynchronous: true
      width: root.iconSize
      height: root.iconSize
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      visible: root.label !== ""
      text: root.label
      width: root.iconOnly ? 0 : Math.max(0, row.width - (taskIcon.visible ? taskIcon.width + row.spacing : 0))
      elide: Text.ElideRight
      font.pixelSize: root.labelSize
      font.bold: root.checked
      color: root.urgent && root.checked ? theme.textOnUrgent
           : root.checked && root.enabled ? theme.textOnActive
           : root.muted ? theme.textMuted
           : root.enabled ? theme.textSecondary
           : theme.textFaint
      verticalAlignment: Text.AlignVCenter
    }
  }
}
