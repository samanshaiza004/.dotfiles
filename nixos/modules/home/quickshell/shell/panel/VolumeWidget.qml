import Quickshell.Services.Pipewire
import QtQuick

// Default audio sink volume/mute, live via Pipewire.
Item {
  id: root

  implicitWidth: text.implicitWidth
  implicitHeight: 24

  Text {
    id: text
    anchors.centerIn: parent
    font.pixelSize: 11
    color: {
      const sink = Pipewire.defaultAudioSink
      if (sink && sink.audio && sink.audio.muted) return "#9a9384"
      return "#d8d2c2"
    }
    text: {
      const sink = Pipewire.defaultAudioSink
      if (!Pipewire.ready || !sink || !sink.audio) return ""
      if (sink.audio.muted) return "\u266A muted"
      return "\u266A " + Math.round(sink.audio.volume * 100) + "%"
    }
  }
}
