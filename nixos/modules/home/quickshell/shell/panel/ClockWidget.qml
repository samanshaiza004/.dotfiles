import QtQuick

// Clock, "h:mm" (12h without AM/PM).
Item {
  id: root

  implicitWidth: text.implicitWidth
  implicitHeight: 24

  property string time: Qt.formatDateTime(new Date(), "h:mm")

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.time = Qt.formatDateTime(new Date(), "h:mm")
  }

  Text {
    id: text
    anchors.centerIn: parent
    font.pixelSize: 12
    font.bold: true
    color: "#e8e2d0"
    text: root.time
  }
}
