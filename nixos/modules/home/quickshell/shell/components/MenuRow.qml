import QtQuick
import "../style"

// Compact menu row with the same physical button treatment as the panel.
Item {
  id: root

  Theme { id: theme }

  property string label: ""
  property string detail: ""
  property bool selected: false
  property bool interactive: true
  signal clicked

  implicitWidth: 220
  implicitHeight: 25

  ButtonFrame {
    anchors.fill: parent
    enabled: root.interactive
    checked: root.selected
    onClicked: root.clicked()

    Row {
      anchors.fill: parent
      anchors.leftMargin: 8
      anchors.rightMargin: 8
      spacing: 8

      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - detailLabel.implicitWidth - parent.spacing
        elide: Text.ElideRight
        color: root.selected ? theme.textPrimary : theme.textSecondary
        font.pixelSize: theme.textSize
        text: root.label
      }

      Text {
        id: detailLabel
        anchors.verticalCenter: parent.verticalCenter
        color: theme.textMuted
        font.pixelSize: theme.textSize
        text: root.detail
      }
    }
  }
}
