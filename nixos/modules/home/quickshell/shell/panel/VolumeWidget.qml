import Quickshell.Services.Pipewire
import QtQuick
import "../components"
import "../style"

// Default audio sink volume/mute, live via Pipewire. A control with
// hover/pressed treatment that opens a popup showing the level on a recessed
// progress bar.
Item {
  id: root

  Theme {
    id: theme
  }

  required property var tooltip
  required property var panelWindow

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
      else volumePopup.open()
    }
  }

  Text {
    id: label
    anchors.centerIn: button
    font.pixelSize: theme.textSize
    color: root.muted ? theme.textMuted
         : button.hovered ? theme.textPrimary
         : theme.textSecondary
    text: root.muted ? "\u266A muted" : "\u266A " + root.volumePercent
  }

  readonly property real volume: {
    const sink = Pipewire.defaultAudioSink
    if (!Pipewire.ready || !sink || !sink.audio) return 0
    return sink.audio.volume
  }

  readonly property bool muted: {
    const sink = Pipewire.defaultAudioSink
    return Pipewire.ready && sink && sink.audio && sink.audio.muted
  }

  readonly property string volumePercent: {
    const sink = Pipewire.defaultAudioSink
    if (!Pipewire.ready || !sink || !sink.audio) return ""
    return Math.round(sink.audio.volume * 100) + "%"
  }

  Popup {
    id: volumePopup
    target: button
    panelWindow: root.panelWindow

    content: Column {
      spacing: 8

      Text {
        text: root.muted ? "Muted" : "Volume"
        color: theme.textOnActive
        font.pixelSize: theme.textSizeLarge
        font.bold: true
      }

      ProgressBar {
        width: 180
        value: root.muted ? 0 : root.volume
      }

      Text {
        text: root.volumePercent
        color: theme.textSecondary
        font.pixelSize: theme.textSize
      }
    }
  }
}