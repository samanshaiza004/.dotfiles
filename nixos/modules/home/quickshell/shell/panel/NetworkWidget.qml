import QtQuick
import "../components"
import "../menus"
import "../style"

// Network status: native Wi-Fi / ethernet / offline state.
// Coherent hover/pressed treatment with a classic tooltip on hover.
Item {
  id: root

  Theme {
    id: theme
  }

  required property var tooltip
  required property var panelWindow
  required property var closeOthers
  required property var networkService

  implicitWidth: label.implicitWidth + 12
  implicitHeight: theme.controlSize

  function closePopup() {
    networkPopup.close()
  }

  ButtonFrame {
    id: button
    anchors.fill: parent

    onHoveredChanged: {
      if (!enabled) return
      if (hovered) root.tooltip.showFor(button, root.networkService.tooltipText)
      else root.tooltip.hide()
    }

    onClicked: {
      if (networkPopup.visible) networkPopup.close()
      else {
        root.closeOthers()
        networkPopup.open()
      }
    }
  }

  Text {
    id: label
    anchors.centerIn: button
    font.pixelSize: theme.textSize
    color: root.networkService.statusText === "" ? theme.textFaint
          : button.hovered ? theme.textPrimary
          : theme.textSecondary
    text: root.networkService.statusText
  }

  NetworkMenu {
    id: networkPopup
    target: button
    panelWindow: root.panelWindow
    networkService: root.networkService
  }
}
