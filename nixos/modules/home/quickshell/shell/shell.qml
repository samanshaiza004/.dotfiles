//@ pragma UseQApplication

import Quickshell
import QtQml
import "panel"

// Entry point — "default" config at ~/.config/quickshell/shell.qml
// UseQApplication enables Qt platform menus so StatusNotifier tray items can
// show their own menus (TrayWidget).
ShellRoot {
  id: root

  // One reactive backend shared by all widgets: mmsg watch streams.
  MangoBackend {
    id: backend
  }

  PanelBar {
    backend: backend
  }
}
