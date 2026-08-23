import QtQuick
import "../style"
import "."

// Stable one-button-per-toplevel task strip. The model order comes directly
// from ToplevelManager and focus changes only affect button state.
Item {
  id: root

  required property var windowService
  required property var tooltip

  Theme { id: theme }

  property int preferredWidth: 150
  property int maximumWidth: 180
  property int minimumWidth: 38
  property int spacing: 4

  readonly property int taskCount: root.windowService.toplevels.length
  readonly property real availableTaskWidth: Math.max(0, root.width - Math.max(0, root.taskCount - 1) * root.spacing)
  readonly property real unconstrainedTaskWidth: root.taskCount > 0
    ? root.availableTaskWidth / root.taskCount : 0
  readonly property real taskWidth: root.taskCount > 0
    ? root.unconstrainedTaskWidth < root.minimumWidth
      ? root.unconstrainedTaskWidth
      : Math.min(root.maximumWidth, root.unconstrainedTaskWidth)
    : 0

  implicitWidth: root.taskCount > 0
    ? Math.min(root.preferredWidth, root.taskCount * root.maximumWidth)
    : 0
  implicitHeight: theme.controlSize
  clip: true

  Row {
    anchors.fill: parent
    spacing: root.spacing

    Repeater {
      model: root.windowService.toplevels

      TaskItem {
        required property var modelData
        width: root.taskWidth
        height: root.height
        toplevel: modelData
        windowService: root.windowService
        tooltip: root.tooltip
      }
    }
  }
}
