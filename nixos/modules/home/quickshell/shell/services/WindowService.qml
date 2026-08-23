import Quickshell
import Quickshell.Wayland
import QtQuick

// Native Wayland toplevel facade. Mango's IPC remains responsible for tags;
// generic window identity and actions come from foreign-toplevel-management.
Item {
  id: root

  property int windowRevision: 0
  property int metadataRevision: 0

  readonly property var toplevels: {
    const revision = root.windowRevision
    void revision

    const result = []
    for (const toplevel of ToplevelManager.toplevels.values) {
      // Modal/transient children are represented by their parent window and do
      // not get a second permanent task button.
      if (!toplevel.parent) result.push(toplevel)
    }
    return result
  }

  readonly property var activeToplevel: ToplevelManager.activeToplevel

  // Watch item-level changes that are not represented by a model reset. This
  // keeps the filtered task list reactive when a dialog is attached/detached.
  Instantiator {
    model: ToplevelManager.toplevels

    delegate: Item {
      required property var modelData

      Connections {
        target: modelData
        function onParentChanged() { root.windowRevision++ }
      }
    }
  }

  Connections {
    target: DesktopEntries
    function onApplicationsChanged() { root.metadataRevision++ }
  }

  function desktopEntry(toplevel) {
    const revision = root.metadataRevision
    void revision
    if (!toplevel || !toplevel.appId) return null

    const exact = DesktopEntries.byId(toplevel.appId)
    if (exact) return exact

    const heuristic = DesktopEntries.heuristicLookup(toplevel.appId)
    if (heuristic) return heuristic

    // heuristicLookup already checks StartupWMClass in 0.3.0, but keep a
    // small explicit fallback for entries whose casing is unusual.
    const appId = toplevel.appId.toLowerCase()
    for (const entry of DesktopEntries.applications.values) {
      if (entry.startupClass && entry.startupClass.toLowerCase() === appId) return entry
    }
    return null
  }

  function applicationName(toplevel) {
    const entry = root.desktopEntry(toplevel)
    if (entry && entry.name) return entry.name
    if (toplevel && toplevel.appId) return toplevel.appId
    return "Application"
  }

  function displayTitle(toplevel) {
    const title = toplevel && toplevel.title ? toplevel.title.trim() : ""
    if (title && (!toplevel.appId || title.toLowerCase() !== toplevel.appId.toLowerCase())) {
      return title
    }
    return root.applicationName(toplevel)
  }

  function iconFor(toplevel) {
    const entry = root.desktopEntry(toplevel)
    const icon = entry && entry.icon ? entry.icon : "application-x-executable"
    return Quickshell.iconPath(icon, "application-x-executable")
  }

  function fullTitle(toplevel) {
    const app = root.applicationName(toplevel)
    const title = root.displayTitle(toplevel)
    return title === app ? title : app + "\n" + title
  }

  function activate(toplevel) {
    if (toplevel) toplevel.activate()
  }

  function activateOrMinimize(toplevel) {
    if (!toplevel) return
    if (toplevel.minimized) {
      toplevel.minimized = false
      toplevel.activate()
    } else if (toplevel.activated) {
      toplevel.minimized = true
    } else {
      toplevel.activate()
    }
  }

  function close(toplevel) {
    if (toplevel) toplevel.close()
  }
}
