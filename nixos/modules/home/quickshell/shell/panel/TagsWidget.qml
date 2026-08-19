import QtQuick

// Mango tag chips for this panel's screen. Click switches the tag.
Item {
  id: root

  required property var backend
  required property string screenName

  implicitWidth: row.implicitWidth
  implicitHeight: 24

  property var tags: root.backend.tagsFor(root.screenName)

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 4

    Repeater {
      model: root.tags

      delegate: Rectangle {
        required property var modelData

        width: 22
        height: 22
        radius: 6
        color: modelData.is_active ? "#c9b890"
             : modelData.is_urgent ? "#8a3a1f"
             : "#2a251c"

        Text {
          anchors.centerIn: parent
          text: modelData.index
          color: modelData.is_active ? "#1c1812" : "#9a9384"
          font.pixelSize: 11
          font.bold: modelData.is_active
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.backend.dispatch(["mmsg", "dispatch", "view," + modelData.index])
        }
      }
    }
  }
}
