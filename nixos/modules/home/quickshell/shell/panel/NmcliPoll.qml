import Quickshell.Io
import QtQuick

// Periodic one-shot nmcli poll; emits a line per output row.
Item {
  id: root

  signal result(string line)
  signal pollStarted()
  signal pollDone()

  property int interval: 10000

  Timer {
    interval: root.interval
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.poll()
  }

  function poll() {
    root.pollStarted()
    proc.running = true
  }

  Process {
    id: proc
    command: ["nmcli", "-t", "-e", "no", "-f", "TYPE,STATE,CONNECTION", "dev"]
    running: false
    onRunningChanged: {
      if (!proc.running) root.pollDone()
    }
    stdout: SplitParser {
      onRead: line => {
        const trimmed = line.trim()
        if (trimmed.length > 0) root.result(trimmed)
      }
    }
  }
}
