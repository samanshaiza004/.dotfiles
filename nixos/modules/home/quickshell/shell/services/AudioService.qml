import Quickshell.Services.Pipewire
import QtQuick

// Small stateful facade over PipeWire. Binding the active sinks is required
// before PwNode.audio exposes valid, writable volume and mute properties.
Item {
  id: root

  readonly property bool ready: Pipewire.ready
  readonly property var defaultOutput: Pipewire.defaultAudioSink
  readonly property var preferredOutput: Pipewire.preferredDefaultAudioSink
  readonly property var outputNodes: {
    const result = []
    for (const node of Pipewire.nodes.values) {
      if (root.isOutputDevice(node)) result.push(node)
    }
    return result
  }

  readonly property var trackedNodes: {
    const result = []
    if (Pipewire.defaultAudioSink) result.push(Pipewire.defaultAudioSink)
    if (Pipewire.preferredDefaultAudioSink) result.push(Pipewire.preferredDefaultAudioSink)
    return result
  }

  PwObjectTracker {
    objects: root.trackedNodes
  }

  readonly property real volume: {
    const sink = root.defaultOutput
    return sink && sink.audio ? sink.audio.volume : 0
  }

  readonly property bool muted: {
    const sink = root.defaultOutput
    return !!(sink && sink.audio && sink.audio.muted)
  }

  readonly property string volumePercent: root.ready && root.defaultOutput
    ? Math.round(root.volume * 100) + "%" : ""
  readonly property string volumeIconName: root.muted ? "audio-volume-muted"
    : root.volume < 0.34 ? "audio-volume-low"
    : root.volume < 0.67 ? "audio-volume-medium" : "audio-volume-high"

  function isOutputDevice(node) {
    return !!(node && node.audio && node.isSink && !node.isStream)
  }

  function outputName(node) {
    if (!node) return "No output"
    return node.description || node.nickname || node.name || "Unknown output"
  }

  function setVolume(value) {
    const sink = root.defaultOutput
    if (sink && sink.audio) sink.audio.volume = Math.max(0, Math.min(1, value))
  }

  function toggleMute() {
    const sink = root.defaultOutput
    if (sink && sink.audio) sink.audio.muted = !sink.audio.muted
  }

  function setDefaultOutput(node) {
    if (node) Pipewire.preferredDefaultAudioSink = node
  }
}
