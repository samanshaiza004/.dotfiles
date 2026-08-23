import Quickshell
import QtQuick
import "../launcher/AppSearch.js" as AppSearch

// Application identity stays in DesktopEntry. These small wrappers only cache
// searchable metadata and provide stable ids for ScriptModel delegates.
Item {
  id: root

  property var records: []
  property var results: []
  property var recordCache: ({})
  property string query: ""
  property string category: "All Programs"
  property var categories: ["All Programs"]

  readonly property var categoryOrder: [
    "Internet",
    "Development",
    "Multimedia",
    "Graphics",
    "Office",
    "Games",
    "System",
    "Utilities",
    "Other"
  ]

  function valuesOf(value) {
    if (!value) return []
    if (typeof value === "string") {
      return value.split(";").filter(function (item) { return item.trim() !== "" })
    }
    try {
      return Array.from(value).map(function (item) { return String(item) })
    } catch (error) {
      return []
    }
  }

  function categoryFor(entry) {
    var categories = valuesOf(entry.categories)
    if (categories.indexOf("WebBrowser") !== -1 || categories.indexOf("Network") !== -1) return "Internet"
    if (categories.indexOf("Development") !== -1) return "Development"
    if (categories.indexOf("AudioVideo") !== -1 || categories.indexOf("Audio") !== -1 || categories.indexOf("Video") !== -1) return "Multimedia"
    if (categories.indexOf("Graphics") !== -1) return "Graphics"
    if (categories.indexOf("Office") !== -1) return "Office"
    if (categories.indexOf("Game") !== -1) return "Games"
    if (categories.indexOf("System") !== -1 || categories.indexOf("Settings") !== -1) return "System"
    if (categories.indexOf("Utility") !== -1) return "Utilities"
    return "Other"
  }

  function syncEntries() {
    var next = []
    var seen = ({})
    var entries = DesktopEntries.applications.values || []

    // DesktopEntries already applies normal Hidden/NoDisplay semantics. Do
    // not duplicate desktop-file parsing or filesystem filtering here.
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i]
      if (!entry || !entry.id) continue

      var id = String(entry.id)
      if (seen[id]) continue
      seen[id] = true

      var record = root.recordCache[id]
      if (!record) {
        record = { id: id }
        root.recordCache[id] = record
      }

      record.entry = entry
      record.name = String(entry.name || entry.genericName || id)
      record.genericName = String(entry.genericName || "")
      record.comment = String(entry.comment || "")
      record.keywords = root.valuesOf(entry.keywords)
      record.categories = root.valuesOf(entry.categories)
      record.category = root.categoryFor(entry)
      record.icon = String(entry.icon || "application-x-executable")
      next.push(record)
    }

    next.sort(function (left, right) {
      return AppSearch.compareByName(left, right)
    })
    root.records = next

    var available = ["All Programs"]
    for (var c = 0; c < root.categoryOrder.length; c++) {
      for (var r = 0; r < next.length; r++) {
        if (next[r].category === root.categoryOrder[c]) {
          available.push(root.categoryOrder[c])
          break
        }
      }
    }
    root.categories = available
    root.refresh()
  }

  function search(nextQuery, nextCategory) {
    root.query = nextQuery || ""
    root.category = nextCategory || "All Programs"
    root.results = AppSearch.rank(root.records, root.query, root.category)
  }

  function refresh() {
    root.results = AppSearch.rank(root.records, root.query, root.category)
  }

  function launch(record) {
    if (!record || !record.entry) return false
    var entry = record.entry

    if (entry.runInTerminal) {
      if (!entry.command || entry.command.length === 0) return false
      var terminalCommand = ["ghostty", "-e"]
      for (var i = 0; i < entry.command.length; i++) terminalCommand.push(entry.command[i])
      Quickshell.execDetached({
        command: terminalCommand,
        workingDirectory: entry.workingDirectory,
      })
    } else {
      entry.execute()
    }
    return true
  }

  Connections {
    target: DesktopEntries.applications
    function onValuesChanged() { root.syncEntries() }
  }

  Component.onCompleted: root.syncEntries()
}
