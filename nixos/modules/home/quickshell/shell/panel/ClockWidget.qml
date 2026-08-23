import QtQuick
import "../components"
import "../menus"
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
  required property var calendarModel

  implicitWidth: label.implicitWidth + 16
  implicitHeight: theme.controlSize

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
    text: Qt.formatDateTime(root.calendarModel.now, "h:mm")
  }

  CalendarMenu {
    id: clockPopup
    target: button
    panelWindow: root.panelWindow
    calendarModel: root.calendarModel
  }
}
