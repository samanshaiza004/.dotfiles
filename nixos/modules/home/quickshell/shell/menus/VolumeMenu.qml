import QtQuick
import Quickshell
import Quickshell.Widgets
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

        IconImage {
          anchors.centerIn: parent
          width: 18
          height: 18
          source: Quickshell.iconPath(root.audioService.volumeIconName)
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

    SectionHeader {
      width: 224
      label: "Output device"
    }

    Repeater {
      model: root.audioService.outputNodes

      MenuRow {
        required property var modelData
        width: 224
        iconName: "audio-card"
        overlayIconName: modelData === root.audioService.defaultOutput ? "checkbox" : ""
        label: root.audioService.outputName(modelData)
        selected: modelData === root.audioService.defaultOutput
        onClicked: root.audioService.setDefaultOutput(modelData)
      }
    }
  }
}
