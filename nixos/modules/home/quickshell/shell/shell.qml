//@ pragma UseQApplication
//@ pragma IconTheme oxygen

import Quickshell
import QtQml
import "components"
import "launcher"
import "panel"
import "services"

// Entry point — "default" config at ~/.config/quickshell/shell.qml
// UseQApplication enables Qt platform menus so StatusNotifier tray items can
// show their own menus (TrayWidget).
ShellRoot {
  id: root

  // One reactive backend shared by all widgets: mmsg watch streams.
  MangoBackend {
    id: backend
  }

  AudioService {
    id: audioService
  }

  NetworkService {
    id: networkService
  }

  CalendarModel {
    id: calendarModel
  }

  WindowService {
    id: windowService
  }

  PopupController {
    id: popupController
    panelWindow: panelBar
  }

  Launcher {
    id: launcher
    panelWindow: panelBar
    popupController: popupController
  }

  PanelBar {
    id: panelBar
    backend: backend
    audioService: audioService
    networkService: networkService
    calendarModel: calendarModel
    windowService: windowService
    popupController: popupController
  }
}
