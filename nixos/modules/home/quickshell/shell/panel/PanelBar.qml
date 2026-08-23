import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../components"
import "../style"
import "../taskbar"

// Top panel on the primary (largest) screen.
//
// Compositor side (Mango) owns the wallpaper blur + the layer shadow. This QML
// side only adds the translucent glass tint, gradient, borders and highlights
// on top, so the compositor effect stays visible through the surface. The
// layer surface is explicitly namespaced "late2000s-panel" so Mango rules can
// target it.
PanelWindow {
  id: root

  Theme {
    id: theme
  }

  required property var backend
  required property var audioService
  required property var networkService
  required property var calendarModel
  required property var windowService
  required property var popupController
  required property var launcher

  WlrLayershell.namespace: "late2000s-panel"

  anchors {
    left: true
    right: true
    top: true
  }
  implicitHeight: theme.panelHeight
  exclusiveZone: theme.panelHeight
  color: "transparent"
  screen: root.mainScreen()

  function mainScreen() {
    let best = null
    for (let i = 0; i < Quickshell.screens.length; i++) {
      const s = Quickshell.screens[i]
      if (best === null || s.width * s.height > best.width * best.height) best = s
    }
    return best
  }

  function closePopups() {
    if (root.launcher && root.launcher.visible) root.launcher.closeImmediately()
    root.popupController.closeAll()
  }

  readonly property alias launcherButton: startButton

  // Classic desktop tooltip, shared by every control in the panel.
  Tooltip {
    id: tooltip
    panelWindow: root
  }

  // Translucent glass surface. The gradient carries its own alpha so the
  // compositor blur reads through the panel.
  Surface {
    anchors.fill: parent
    radius: 0
    topColor: theme.panelGradTop
    bottomColor: theme.panelGradBottom
    borderColor: theme.panelBottomEdge
    topHighlight: theme.panelTopHighlight
    bottomShadow: theme.panelBottomShadow
  }

  // Clicking empty panel space dismisses an open popup (outside-click close).
  MouseArea {
    anchors.fill: parent
    z: 0
    onClicked: root.closePopups()
  }

  RowLayout {
    anchors {
      fill: parent
      leftMargin: 10
      rightMargin: 12
    }
    spacing: 10
    z: 1

    StartButton {
      id: startButton
      launcher: root.launcher
      tooltip: tooltip
    }

    TagsWidget {
      id: tagsWidget
      backend: root.backend
      screenName: root.screen ? root.screen.name : ""
    }

    TaskStrip {
      id: taskStrip
      Layout.fillWidth: true
      Layout.minimumWidth: 0
      windowService: root.windowService
      tooltip: tooltip
    }

    TrayWidget {
      tooltip: tooltip
    }

    VolumeWidget {
      id: volumeWidget
      tooltip: tooltip
      panelWindow: root
      closeOthers: root.closePopups
      audioService: root.audioService
      popupController: root.popupController
    }

    NetworkWidget {
      id: networkWidget
      panelWindow: root
      closeOthers: root.closePopups
      networkService: root.networkService
      popupController: root.popupController
    }

    ClockWidget {
      id: clockWidget
      panelWindow: root
      closeOthers: root.closePopups
      calendarModel: root.calendarModel
      popupController: root.popupController
    }
  }
}
