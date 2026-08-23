import Quickshell.Services.SystemTray
import QtQuick
import "../components"
import "../style"

// StatusNotifier tray built on the TrayButton primitive. Hidden when no items
// are registered.
//
// Primary click activates the item. Secondary click opens the application's
// own menu when one exists (via the platform menu path), otherwise falls back
// to secondaryActivate so middle-ish clicks still do something useful.
Item {
  id: root

  Theme {
    id: theme
  }

  required property var tooltip

  implicitWidth: row.implicitWidth
  implicitHeight: theme.controlSize

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 2

    Repeater {
      model: SystemTray.items

      delegate: TrayButton {
        id: trayBtn

        required property var modelData

        iconSource: modelData.icon
        tooltipText: modelData.tooltipTitle !== "" ? modelData.tooltipTitle : modelData.title
        tooltip: root.tooltip
        visible: modelData.icon !== "" || modelData.title !== ""

        onPrimaryActivated: modelData.activate()

        onSecondaryActivated: {
          if (modelData.hasMenu) {
            const win = trayBtn.QsWindow.window
            const pos = trayBtn.mapToItem(win.contentItem, 0, 0)
            modelData.display(win, Math.round(pos.x), Math.round(pos.y + trayBtn.height))
          } else {
            modelData.secondaryActivate()
          }
        }
      }
    }
  }
}