import Quickshell
import Quickshell.Wayland
import QtQuick

// Shared dismissal surface for PopupWindow instances whose xdg_popup grab
// cannot be used with the pinned layer-shell/Mango stack.
Item {
  id: root

  required property var panelWindow
  property var activePopup: null
  property var openedActiveToplevel: null
  property rect popupRect: Qt.rect(0, 0, 0, 0)

  function open(popup, rect) {
    if (root.activePopup && root.activePopup !== popup) {
      const previous = root.activePopup
      root.activePopup = null
      previous.close()
    }
    root.activePopup = popup
    root.openedActiveToplevel = ToplevelManager.activeToplevel
    root.popupRect = rect
    dismissalWindow.visible = true
  }

  function update(popup, rect) {
    if (root.activePopup === popup) root.popupRect = rect
  }

  function close(popup) {
    if (root.activePopup !== popup) return
    root.activePopup = null
    root.openedActiveToplevel = null
    root.popupRect = Qt.rect(0, 0, 0, 0)
    dismissalWindow.visible = false
  }

  function closeAll() {
    const popup = root.activePopup
    root.activePopup = null
    root.openedActiveToplevel = null
    root.popupRect = Qt.rect(0, 0, 0, 0)
    dismissalWindow.visible = false
    if (popup) popup.close()
  }

  Connections {
    target: ToplevelManager
    function onActiveToplevelChanged() {
      const active = ToplevelManager.activeToplevel
      if (root.activePopup && active && active !== root.openedActiveToplevel) {
        root.closeAll()
      }
    }
  }

  PanelWindow {
    id: dismissalWindow
    visible: false
    screen: root.panelWindow ? root.panelWindow.screen : null
    color: "transparent"
    exclusiveZone: 0

    anchors {
      left: true
      right: true
      top: true
      bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "late-2000s-popup-dismissal"
    WlrLayershell.keyboardFocus: root.activePopup
      ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // The overlay receives input everywhere except the panel and active popup.
    // The latter remain interactive even though this surface is above them.
    mask: Region {
      width: dismissalWindow.width
      height: dismissalWindow.height

      Region {
        intersection: Intersection.Subtract
        width: root.panelWindow ? root.panelWindow.width : 0
        height: root.panelWindow ? root.panelWindow.height : 0
      }

      Region {
        intersection: Intersection.Subtract
        x: root.popupRect.x
        y: root.popupRect.y
        width: root.popupRect.width
        height: root.popupRect.height
      }
    }

    Item {
      id: keyboardSurface
      anchors.fill: parent
      focus: dismissalWindow.visible

      Keys.onEscapePressed: root.closeAll()

      MouseArea {
        anchors.fill: parent
        onClicked: root.closeAll()
      }

      onVisibleChanged: if (visible) forceActiveFocus()
    }
  }
}
