import Quickshell
import QtQuick
import "../style"

// Reusable popup/menu surface anchored natively to the panel via PopupWindow
// (an xdg_popup). Verified working on the pinned Mango (813acaf / 0.16.1) +
// Quickshell 0.3.0: the surface is created, configured, and rendered, and the
// compositor performs edge correction.
//
// Vertical authority is the bottom of the panel; horizontal authority is the
// triggering control. Coordinates stay panel-local — no global monitor origins.
//
// grabFocus is intentionally left false: enabling it makes Qt try to create a
// grabbing xdg_popup, which the layer-shell panel parent rejects on this stack
// ("Cannot attach popup ... as the popup is not an xdg_popup"). Outside-click
// dismissal is instead handled by the panel's click catcher + button toggle.
PopupWindow {
  id: root

  Theme {
    id: theme
  }

  default property alias content: surfaceContent.data

  // Triggering control (horizontal authority) and the panel window the popup
  // anchors to (vertical authority + anchor surface).
  property Item target: null
  property var panelWindow: null
  property int gap: 2
  property int screenPadding: 6

  property color topColor: theme.surfaceGradTop
  property color bottomColor: theme.surfaceGradBottom
  property real radius: theme.surfaceRadius
  property int padding: 8

  function open() {
    root.visible = true
  }

  function close() {
    root.visible = false
  }

  color: "transparent"
  implicitWidth: surfaceContent.childrenRect.width + root.padding * 2 + body.shadowPad * 2
  implicitHeight: surfaceContent.childrenRect.height + root.padding * 2 + body.shadowPadTop + body.shadowPad

  anchor {
    window: root.panelWindow
    edges: Edges.Bottom
    gravity: Edges.Bottom
    adjustment: PopupAdjustment.Slide | PopupAdjustment.Flip
    onAnchoring: {
      if (!root.target || !root.panelWindow) return
      const pos = root.target.mapToItem(root.panelWindow.contentItem, root.target.width / 2, 0)
      let cx = pos.x
      const scr = root.panelWindow.screen
      if (scr) {
        cx = Math.max(
          root.screenPadding + root.width / 2,
          Math.min(cx, scr.width - root.width / 2 - root.screenPadding)
        )
      }
      // gravity Bottom places the popup's top at the anchor rect's bottom edge.
      anchor.rect.x = Math.round(cx - 1)
      anchor.rect.y = Math.round(root.panelWindow.height) + root.gap - 1
      anchor.rect.width = 2
      anchor.rect.height = 1
    }
  }

  onVisibleChanged: if (root.visible) root.anchor.updateAnchor()
  onTargetChanged: if (root.visible) root.anchor.updateAnchor()
  onPanelWindowChanged: if (root.visible) root.anchor.updateAnchor()

  Surface {
    id: body
    anchors.fill: parent
    radius: root.radius
    topColor: root.topColor
    bottomColor: root.bottomColor
    borderColor: theme.surfaceBorder
    topHighlight: theme.surfaceTopHighlight
    bottomShadow: theme.surfaceBottomShadow
    shadowEnabled: true
    shadowBlur: 24
    shadowOpacity: 0.7
    shadowOffsetY: 4
    // No room above the card so the popup hugs the panel; shadow lives below/sides.
    shadowPadTop: 0

    content: Item {
      id: surfaceContent
      anchors.fill: parent
      anchors.margins: root.padding
    }
  }
}