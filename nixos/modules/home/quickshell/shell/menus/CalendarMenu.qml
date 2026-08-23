import QtQuick
import Quickshell
import Quickshell.Widgets
import "../components"
import "../style"

Popup {
  id: root

  required property var calendarModel

  Theme { id: theme }

  content: Column {
    width: 238
    spacing: 7

    Row {
      width: parent.width
      height: 26
      spacing: 6

      ButtonFrame {
        width: 28
        height: 26
        onClicked: root.calendarModel.showPreviousMonth()
        IconImage {
          anchors.centerIn: parent
          width: 15
          height: 15
          source: Quickshell.iconPath("go-previous")
        }
      }

      Text {
        width: parent.width - 68
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        color: theme.textOnActive
        font.pixelSize: theme.textSizeLarge
        font.bold: true
        text: root.calendarModel.monthTitle
      }

      ButtonFrame {
        width: 28
        height: 26
        onClicked: root.calendarModel.showNextMonth()
        IconImage {
          anchors.centerIn: parent
          width: 15
          height: 15
          source: Quickshell.iconPath("go-next")
        }
      }
    }

    Row {
      width: parent.width
      height: 18
      Repeater {
        model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        Text {
          width: 34
          horizontalAlignment: Text.AlignHCenter
          color: theme.calendarWeekday
          font.pixelSize: theme.textSize
          text: modelData
        }
      }
    }

    Grid {
      width: parent.width
      columns: 7
      rowSpacing: 2
      columnSpacing: 0

      Repeater {
        model: root.calendarModel.days

        Item {
          required property var modelData
          width: 34
          height: 25

          Rectangle {
            anchors.centerIn: parent
            width: 24
            height: 22
            radius: 2
            color: parent.modelData.today ? theme.accentDeep : "transparent"
            border.width: parent.modelData.today ? 1 : 0
            border.color: theme.accentBright
          }

          Text {
            anchors.centerIn: parent
            color: !parent.modelData.inMonth ? theme.textFaint
                 : parent.modelData.today ? theme.textPrimary : theme.calendarDate
            font.pixelSize: theme.textSize
            text: parent.modelData.number
          }
        }
      }
    }

    MenuRow {
      width: 238
      iconName: "view-calendar-month"
      label: "Today"
      detail: Qt.formatDateTime(root.calendarModel.now, "MMM d")
      onClicked: root.calendarModel.showCurrentMonth()
    }
  }
}
