import QtQuick
import "../components"
import "../style"

Popup {
  id: root

  required property var audioService

  Theme { id: theme }

  content: Column {
    width: 224
    spacing: 7

    Text {
      text: root.audioService.muted ? "Muted" : "Volume"
      color: theme.textOnActive
      font.pixelSize: theme.textSizeLarge
      font.bold: true
    }

    Row {
      width: parent.width
      height: 26
      spacing: 7

      ButtonFrame {
        width: 28
        height: 26
        checked: root.audioService.muted
        onClicked: root.audioService.toggleMute()

        Text {
          anchors.centerIn: parent
          color: theme.textPrimary
          font.pixelSize: theme.textSize
          text: root.audioService.muted ? "M" : "♪"
        }
      }

      Slider {
        width: 154
        height: 26
        value: root.audioService.volume
        onValueMoved: value => root.audioService.setVolume(value)
      }

      Text {
        width: 35
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignRight
        color: theme.textSecondary
        font.pixelSize: theme.textSize
        text: root.audioService.volumePercent
      }
    }

    Text {
      color: theme.textMuted
      font.pixelSize: theme.textSize
      text: "Output device"
    }

    Repeater {
      model: root.audioService.outputNodes

      MenuRow {
        required property var modelData
        width: 224
        label: root.audioService.outputName(modelData)
        selected: modelData === root.audioService.defaultOutput
        onClicked: root.audioService.setDefaultOutput(modelData)
      }
    }
  }
}
