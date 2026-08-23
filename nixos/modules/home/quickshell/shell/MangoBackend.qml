import Quickshell.Io
import QtQuick

// Reactive mango state fed by persistent mmsg watch streams.
// No polling: the compositor pushes JSON on every change.
Item {
  id: root

  property var monitors: []          // [{ monitor, tags: [{index,is_active,is_urgent,layout,client_count}] }]

  // Tags for a given monitor name (fallback: first monitor).
  function tagsFor(monitorName) {
    for (let i = 0; i < root.monitors.length; i++) {
      const m = root.monitors[i]
      if (m.monitor === monitorName) return m.tags ? m.tags : []
    }
    return root.monitors.length > 0 ? root.monitors[0].tags : []
  }

  // Fire a one-shot mmsg dispatch (tag clicks etc.).
  function dispatch(args) {
    dispatchProc.command = args
    dispatchProc.running = true
  }

  Process {
    id: dispatchProc
    running: false
  }

  WatchStream {
    topic: "all-tags"
    onJsonReceived: obj => {
      if (!obj || typeof obj !== "object") return
      root.monitors = Array.isArray(obj.all_tags) ? obj.all_tags : []
    }
  }

}
