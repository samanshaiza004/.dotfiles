import Quickshell
import Quickshell.Wayland
import QtQuick
import "../style"

// Reusable popup/menu surface for wlroots compositors.
//
// Quickshell's PopupWindow is an xdg_popup, which wlroots rejects when the
// parent is a layer-shell panel ("the popup is not an xdg_popup"), so this
// uses a real floating layer surface instead: positioned above everything with
// no exclusive zone, never focusable, and anchored via margins at the target's
// on-screen coordinates.
//
// The body uses the Surface material: glass gradient, strong soft shadow,
// clear outer border, inset highlight, small radius — slightly deeper than the
// panel. The compositor draws the drop shadow (layer_shadows is global), so
// the surface itself renders no QML shadow.
PanelWindow {
  id: root

  Theme {
    id: theme
  }

  default property alias content: surfaceContent.data

  // Item to position the popup under, plus the panel window used to map
  // coordinates. The popup centers itself horizontally over the target and
  // appears `gap` pixels below it.
  property Item target: null
  property var panelWindow: null
  property int gap: 6

  property color topColor: theme.surfaceGradTop
  property color bottomColor: theme.surfaceGradBottom
  property real radius: theme.surfaceRadius
  property int padding: 8

  function open() {
    root.visible = true
    root.reposition()
  }

  function close() {
    root.visible = false
  }

  WlrLayershell.namespace: "late2000s-popup"
  exclusiveZone: 0
  focusable: false
  color: "transparent"
  screen: root.panelWindow ? root.panelWindow.screen : null

  anchors {
    left: true
    top: true
  }

  implicitWidth: surfaceContent.childrenRect.width + root.padding * 2
  implicitHeight: surfaceContent.childrenRect.height + root.padding * 2

  function reposition() {
    if (!root.target || !root.panelWindow) return
    const scr = root.panelWindow.screen
    if (!scr) return
    const pos = root.target.mapToItem(root.panelWindow.contentItem, 0, root.target.height)
    root.margins.left = Math.round(scr.x + pos.x + root.target.width / 2 - root.width / 2)
    root.margins.top = Math.round(scr.y + pos.y + root.gap)
  }

  onVisibleChanged: if (root.visible) root.reposition()
  onWidthChanged: if (root.visible) root.reposition()
  onHeightChanged: if (root.visible) root.reposition()
  onTargetChanged: if (root.visible) root.reposition()
  onPanelWindowChanged: if (root.visible) root.reposition()

  Surface {
    id: body
    anchors.fill: parent
    radius: root.radius
    topColor: root.topColor
    bottomColor: root.bottomColor
    borderColor: theme.surfaceBorder
    topHighlight: theme.surfaceTopHighlight
    bottomShadow: theme.surfaceBottomShadow

    content: Item {
      id: surfaceContent
      anchors.fill: parent
      anchors.margins: root.padding
    }
  }
}