import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

// StatusNotifier tray. Hidden when no items are registered.
Item {
  id: root

  implicitWidth: row.implicitWidth
  implicitHeight: 24

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 2

    Repeater {
      model: SystemTray.items

      delegate: Item {
        required property var modelData

        width: 22
        height: 22
        visible: modelData.icon !== "" || modelData.title !== ""

        IconImage {
          anchors {
            fill: parent
            margins: 3
          }
          source: modelData.icon
          asynchronous: true
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: modelData.activate()
        }
      }
    }
  }
}
