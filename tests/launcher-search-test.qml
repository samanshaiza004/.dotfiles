import Quickshell
import QtQuick
import "AppSearch.js" as Search

ShellRoot {
  Timer {
    interval: 0
    running: true
    repeat: false
    onTriggered: {
      const records = [
        {
          id: "firefox.desktop",
          name: "Firefox",
          genericName: "Web Browser",
          comment: "Browse the web",
          keywords: ["browser", "internet"],
          categories: ["WebBrowser"],
          category: "Internet"
        },
        {
          id: "firewall.desktop",
          name: "Firewall Configuration",
          genericName: "System Settings",
          comment: "Configure firewalls",
          keywords: ["security"],
          categories: ["System"],
          category: "System"
        },
        {
          id: "editor.desktop",
          name: "Text Editor",
          genericName: "Code Editor",
          comment: "Edit files",
          keywords: ["development"],
          categories: ["Development"],
          category: "Development"
        }
      ]

      function assert(condition, message) {
        if (!condition) {
          console.log("SEARCH_TEST_FAIL", message)
          Qt.exit(1)
        }
      }

      var results = Search.rank(records, "fire", "All Programs")
      assert(results.length === 2, "fire result count")
      assert(results[0].id === "firefox.desktop", "name prefix outranks comment")

      results = Search.rank(records, "browser", "All Programs")
      assert(results[0].id === "firefox.desktop", "keyword/generic search")

      results = Search.rank(records, "fierfox", "All Programs")
      assert(results[0].id === "firefox.desktop", "fuzzy typo search")

      results = Search.rank(records, "", "Development")
      assert(results.length === 1 && results[0].id === "editor.desktop", "category filter")

      results = Search.rank(records, "   ", "All Programs")
      assert(results[0].id === "firefox.desktop", "empty query deterministic alphabetical order")

      console.log("SEARCH_TEST_PASS")
      Qt.quit()
    }
  }
}
