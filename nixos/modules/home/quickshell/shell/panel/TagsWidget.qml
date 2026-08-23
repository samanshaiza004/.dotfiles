import QtQuick
import "../components"
import "../style"

// Mango tag buttons for this panel's screen. Click switches the tag.
Item {
  id: root

  Theme {
    id: theme
  }

  required property var backend
  required property string screenName

  implicitWidth: row.implicitWidth
  implicitHeight: theme.controlSize

  property var tags: root.backend.tagsFor(root.screenName)

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 4

    Repeater {
      model: root.tags

      delegate: TaskButton {
        required property var modelData

        label: modelData.index
        checked: modelData.is_active
        urgent: modelData.is_urgent
        minWidth: 22
        paddingX: 5
        labelSize: theme.textSize

        onClicked: root.backend.dispatch(["mmsg", "dispatch", "view," + modelData.index])
      }
    }
  }
}