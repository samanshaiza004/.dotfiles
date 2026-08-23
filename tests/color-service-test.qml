import Quickshell
import QtQuick
import "services" as Services

ShellRoot {
  property color initialColor

  Timer {
    interval: 0
    running: true
    repeat: false
    onTriggered: {
      initialColor = Services.ColorService.primary
      console.log("COLOR_INITIAL", initialColor)
    }
  }

  Timer {
    interval: 1800
    running: true
    repeat: false
    onTriggered: {
      console.log("COLOR_FINAL", Services.ColorService.primary)
      if (Services.ColorService.primary === initialColor) {
        console.log("COLOR_TEST_FAIL palette did not reload")
        Qt.exit(1)
      } else {
        console.log("COLOR_TEST_PASS")
        Qt.quit()
      }
    }
  }
}
