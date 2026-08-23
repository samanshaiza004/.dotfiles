import QtQuick
import "../components"

// Window-specific task behavior around the generic TaskButton visual.
Item {
  id: root

  required property var toplevel
  required property var windowService
  required property var tooltip

  readonly property bool iconOnly: width < 78

  implicitWidth: 120
  implicitHeight: 22

  TaskButton {
    id: taskButton
    anchors.fill: parent
    iconSource: root.windowService.iconFor(root.toplevel)
    label: root.windowService.displayTitle(root.toplevel)
    iconOnly: root.iconOnly
    checked: root.toplevel.activated
    muted: root.toplevel.minimized
    minWidth: 0
    paddingX: root.iconOnly ? 3 : 6

    onHoveredChanged: {
      if (hovered) root.tooltip.showFor(taskButton, root.windowService.fullTitle(root.toplevel))
      else root.tooltip.hide()
    }
    onClicked: root.windowService.activateOrMinimize(root.toplevel)
    onMiddleClicked: root.windowService.close(root.toplevel)
  }
}
