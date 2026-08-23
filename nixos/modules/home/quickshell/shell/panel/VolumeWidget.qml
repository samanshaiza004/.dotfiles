import QtQuick
import "../components"
import "../menus"
import "../style"

// Default audio sink volume/mute, live via Pipewire. A control with
// hover/pressed treatment that opens the native volume menu.
Item {
  id: root

  Theme {
    id: theme
  }

  required property var tooltip
  required property var panelWindow
  required property var closeOthers
  required property var audioService

  implicitWidth: label.implicitWidth + 12
  implicitHeight: theme.controlSize

  function closePopup() {
    volumePopup.close()
  }

  ButtonFrame {
    id: button
    anchors.fill: parent

    onClicked: {
      if (volumePopup.visible) volumePopup.close()
      else {
        root.closeOthers()
        volumePopup.open()
      }
    }
  }

  Text {
    id: label
    anchors.centerIn: button
    font.pixelSize: theme.textSize
    color: root.audioService.muted ? theme.textMuted
          : button.hovered ? theme.textPrimary
          : theme.textSecondary
    text: root.audioService.muted ? "\u266A muted" : "\u266A " + root.audioService.volumePercent
  }

  VolumeMenu {
    id: volumePopup
    target: button
    panelWindow: root.panelWindow
    audioService: root.audioService
  }
}
