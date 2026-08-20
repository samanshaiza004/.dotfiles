import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// Top panel on the primary (largest) screen.
PanelWindow {
  id: root

  required property var backend

  anchors {
    left: true
    right: true
    top: true
  }
  implicitHeight: 32
  exclusiveZone: 32
  color: "#1c1812"
  screen: root.mainScreen()

  function mainScreen() {
    let best = null
    for (let i = 0; i < Quickshell.screens.length; i++) {
      const s = Quickshell.screens[i]
      if (best === null || s.width * s.height > best.width * best.height) best = s
    }
    return best
  }

  // 1px accent line on bottom edge
  Rectangle {
    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
    height: 1
    color: "#c9b890"
    opacity: 0.35
  }

  RowLayout {
    anchors {
      fill: parent
      leftMargin: 10
      rightMargin: 12
    }
    spacing: 14

    TagsWidget {
      backend: root.backend
      screenName: root.screen ? root.screen.name : ""
    }

    FocusedAppWidget {
      backend: root.backend
    }

    Item {
      Layout.fillWidth: true
    }

    TrayWidget {}

    VolumeWidget {}

    NetworkWidget {}

    ClockWidget {}
  }
}
