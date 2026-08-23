import QtQuick
import Quickshell
import Quickshell.Widgets
import "../style"

// Compact menu row with the same physical button treatment as the panel.
Item {
  id: root

  Theme { id: theme }

  property string label: ""
  property string detail: ""
  property string iconName: ""
  property string overlayIconName: ""
  property bool selected: false
  property bool interactive: true
  property string statusKind: "normal"
  signal clicked

  implicitWidth: 220
  implicitHeight: 25

  ButtonFrame {
    anchors.fill: parent
    enabled: root.interactive
    checked: root.selected || root.statusKind === "connecting"
    activeGradTop: root.statusKind === "error" ? theme.buttonUrgentGradTop : theme.buttonActiveGradTop
    activeGradBottom: root.statusKind === "error" ? theme.buttonUrgentGradBottom : theme.buttonActiveGradBottom
    activeTopHighlight: root.statusKind === "error" ? theme.buttonUrgentTopHighlight : theme.buttonActiveTopHighlight
    activeInnerEdge: root.statusKind === "error" ? theme.buttonUrgentInnerEdge : theme.buttonActiveInnerEdge
    activeGlowColor: root.statusKind === "error" ? theme.buttonUrgentGlow : theme.buttonActiveGlow
    onClicked: root.clicked()

    Row {
      anchors.fill: parent
      anchors.leftMargin: 8
      anchors.rightMargin: 8
      spacing: 8

      Item {
        id: iconFrame
        width: root.iconName !== "" ? 18 : 0
        height: 18
        anchors.verticalCenter: parent.verticalCenter
        visible: root.iconName !== ""

        IconImage {
          anchors.fill: parent
          source: Quickshell.iconPath(root.iconName)
        }

        IconImage {
          anchors { right: parent.right; bottom: parent.bottom }
          width: 10
          height: 10
          source: Quickshell.iconPath(root.overlayIconName || "emblem-locked")
          visible: root.overlayIconName !== ""
        }
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - detailLabel.implicitWidth - parent.spacing
          - (iconFrame.visible ? iconFrame.width + parent.spacing : 0)
        elide: Text.ElideRight
        color: root.statusKind === "error" ? theme.textOnUrgent
             : root.selected || root.statusKind === "connecting" ? theme.textPrimary
             : theme.textSecondary
        font.pixelSize: theme.textSize
        text: root.label
      }

      Text {
        id: detailLabel
        anchors.verticalCenter: parent.verticalCenter
        color: root.statusKind === "error" ? theme.textOnUrgent
             : root.statusKind === "connecting" ? theme.accentBright
             : theme.textMuted
        font.pixelSize: theme.textSize
        text: root.detail
      }
    }
  }
}
