import Quickshell
import QtQuick
import "../style"

Item {
  id: root

  required property var catalog
  required property int selectedIndex
  property var tooltip: null

  signal activated(int index)
  signal hovered(int index)

  Theme { id: theme }

  ListView {
    id: list
    anchors.fill: parent
    clip: true
    currentIndex: root.selectedIndex
    spacing: 3
    boundsBehavior: Flickable.StopAtBounds

    model: ScriptModel {
      values: root.catalog ? root.catalog.results : []
      objectProp: "id"
    }

    delegate: AppRow {
      required property var modelData
      required property int index
      width: list.width
      entry: modelData
      rowIndex: index
      selected: index === root.selectedIndex
      tooltip: root.tooltip
      onActivated: root.activated(index)
      onHovered: root.hovered(index)
    }

    onCurrentIndexChanged: {
      if (currentIndex >= 0) positionViewAtIndex(currentIndex, ListView.Contain)
    }
  }

  Text {
    anchors.centerIn: parent
    color: theme.textMuted
    font.pixelSize: theme.textSize
    text: root.catalog && root.catalog.query !== "" ? "No matching applications" : "No applications found"
    visible: root.catalog && root.catalog.results.length === 0
  }

  function ensureSelectedVisible() {
    if (root.selectedIndex >= 0) list.positionViewAtIndex(root.selectedIndex, ListView.Contain)
  }
}
