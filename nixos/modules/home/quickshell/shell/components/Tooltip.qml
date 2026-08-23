import Quickshell
import Quickshell.Wayland
import QtQuick
import "../style"

// Classic desktop tooltip: a small, dense, high-contrast surface below the
// hovered control. Pale neutral base, thin dark border, tiny shadow, compact
// padding, small radius — deliberately not a Material-style popup.
//
// Rendered as a real floating layer surface (never focusable, no exclusive
// zone); the compositor draws its small shadow.
PanelWindow {
  id: root

  Theme {
    id: theme
  }

  property string text: ""
  property bool show: false
  property Item target: null
  property var panelWindow: null
  property int gap: 4

  function showFor(item, txt) {
    root.target = item
    root.text = txt
    root.show = true
  }

  function hide() {
    root.show = false
  }

  color: "transparent"
  exclusiveZone: 0
  focusable: false
  implicitWidth: body.width
  implicitHeight: body.height

  // Classic tooltips wait a beat before appearing; hiding is immediate.
  Timer {
    id: delayTimer
    interval: 260
    onTriggered: root.visible = true
  }

  onShowChanged: {
    if (root.show) {
      delayTimer.restart()
    } else {
      delayTimer.stop()
      root.visible = false
    }
  }

  onVisibleChanged: if (root.visible) root.reposition()
  onWidthChanged: if (root.visible) root.reposition()
  onHeightChanged: if (root.visible) root.reposition()
  onTargetChanged: if (root.visible) root.reposition()
  onPanelWindowChanged: if (root.visible) root.reposition()

  function reposition() {
    if (!root.target || !root.panelWindow) return
    const scr = root.panelWindow.screen
    if (!scr) return
    const pos = root.target.mapToItem(root.panelWindow.contentItem, 0, root.target.height)
    root.margins.left = Math.round(scr.x + pos.x + root.target.width / 2 - root.width / 2)
    root.margins.top = Math.round(scr.y + pos.y + root.gap)
  }

  Surface {
    id: body
    property int padX: 7
    property int padY: 3

    width: textItem.implicitWidth + padX * 2
    height: textItem.implicitHeight + padY * 2
    radius: theme.tooltipRadius
    topColor: theme.tooltipBase
    bottomColor: theme.tooltipBase
    borderColor: theme.tooltipBorder
    shadowEnabled: false

    content: Text {
      id: textItem
      anchors.centerIn: parent
      text: root.text
      color: theme.tooltipText
      font.pixelSize: theme.textSize
    }
  }
}