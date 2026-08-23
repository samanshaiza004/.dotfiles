import Quickshell
import QtQuick
import "../style"

// Classic desktop tooltip: a small, dense, high-contrast surface that hugs its
// target. Pale neutral base, thin dark border, tiny shadow, compact padding,
// small radius — deliberately not a Material-style popup.
//
// Uses the same native PopupWindow anchoring as Popup.qml; never grabs focus.
PopupWindow {
  id: root

  Theme {
    id: theme
  }

  property string text: ""
  property bool show: false
  property Item target: null
  property var panelWindow: null
  property int gap: 3

  function showFor(item, txt) {
    root.target = item
    root.text = txt
    root.show = true
  }

  function hide() {
    root.show = false
  }

  color: "transparent"
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

  onVisibleChanged: if (root.visible) root.anchor.updateAnchor()
  onTargetChanged: if (root.visible) root.anchor.updateAnchor()
  onPanelWindowChanged: if (root.visible) root.anchor.updateAnchor()

  anchor {
    window: root.panelWindow
    edges: Edges.Bottom
    gravity: Edges.Bottom
    adjustment: PopupAdjustment.Slide
    onAnchoring: {
      if (!root.target || !root.panelWindow) return
      const pos = root.target.mapToItem(root.panelWindow.contentItem, root.target.width / 2, root.target.height)
      const scr = root.panelWindow.screen
      let cx = pos.x
      if (scr) {
        cx = Math.max(
          4 + root.width / 2,
          Math.min(cx, scr.width - root.width / 2 - 4)
        )
      }
      // gravity Bottom places the tooltip's top at the anchor rect's bottom edge.
      anchor.rect.x = Math.round(cx - 1)
      anchor.rect.y = Math.round(pos.y) + root.gap - 1
      anchor.rect.width = 2
      anchor.rect.height = 1
    }
  }

  Surface {
    id: body
    property int padX: 7
    property int padY: 3

    width: textItem.implicitWidth + padX * 2 + shadowPad * 2
    height: textItem.implicitHeight + padY * 2 + shadowPadTop + shadowPad
    radius: theme.tooltipRadius
    topColor: theme.tooltipBase
    bottomColor: theme.tooltipBase
    borderColor: theme.tooltipBorder
    shadowEnabled: true
    shadowBlur: 10
    shadowOpacity: 0.35
    shadowOffsetY: 1
    shadowPadTop: 0

    content: Text {
      id: textItem
      anchors.centerIn: parent
      text: root.text
      color: theme.tooltipText
      font.pixelSize: theme.textSize
    }
  }
}