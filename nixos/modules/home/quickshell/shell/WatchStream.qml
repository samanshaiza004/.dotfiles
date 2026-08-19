import Quickshell.Io
import QtQuick

// One `mmsg watch <topic>` stream: newline-delimited JSON -> signals.
// Auto-restarts with a 2s backoff if the stream dies (e.g. mango restart).
Item {
  id: root

  required property string topic

  signal jsonReceived(var obj)

  Timer {
    id: restartTimer
    interval: 2000
    onTriggered: stream.running = true
  }

  Process {
    id: stream
    command: ["mmsg", "watch", root.topic]
    running: true
    onRunningChanged: {
      if (!stream.running) restartTimer.start()
    }
    stdout: SplitParser {
      onRead: line => {
        const trimmed = line.trim()
        if (trimmed.length === 0) return
        try {
          root.jsonReceived(JSON.parse(trimmed))
        } catch (e) {
          // ignore non-JSON lines
        }
      }
    }
  }
}
