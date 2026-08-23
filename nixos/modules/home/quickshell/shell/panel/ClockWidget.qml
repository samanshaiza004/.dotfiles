import QtQuick
import "../components"
import "../style"

// Clock with a small popup showing the date — the same surface language as the
// rest of the shell, proving the reusable popup primitive.
Item {
  id: root

  Theme {
    id: theme
  }

  required property var panelWindow
  required property var closeOthers

  implicitWidth: label.implicitWidth + 16
  implicitHeight: theme.controlSize

  property var now: new Date()

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.now = new Date()
  }

  function closePopup() {
    clockPopup.close()
  }

  ButtonFrame {
    id: button
    anchors.fill: parent

    onClicked: {
      if (clockPopup.visible) clockPopup.close()
      else {
        root.closeOthers()
        clockPopup.open()
      }
    }
  }

  Text {
    id: label
    anchors.centerIn: button
    font.pixelSize: theme.textSizeLarge
    font.bold: true
    color: button.hovered ? theme.textPrimary : theme.textSecondary
    text: Qt.formatDateTime(root.now, "h:mm")
  }

  Popup {
    id: clockPopup
    target: button
    panelWindow: root.panelWindow

    content: Column {
      spacing: 6

      Text {
        text: Qt.formatDateTime(root.now, "dddd")
        color: theme.textMuted
        font.pixelSize: theme.textSize
      }

      Text {
        text: Qt.formatDateTime(root.now, "h:mm")
        color: theme.textOnActive
        font.pixelSize: 26
        font.bold: true
      }

      Text {
        text: Qt.formatDateTime(root.now, "MMMM d, yyyy")
        color: theme.textSecondary
        font.pixelSize: theme.textSize
      }
    }
  }
}