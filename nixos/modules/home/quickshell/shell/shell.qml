import Quickshell
import QtQml
import "panel"

// Entry point — "default" config at ~/.config/quickshell/shell.qml
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
