import QtQuick
import QtQuick.Effects
import "../style"

// Drag-enabled version of the shell's recessed progress language.
Item {
  id: root

  Theme { id: theme }

  property real value: 0
  property bool dragging: false
  property real _dragValue: 0
  signal valueMoved(real value)

  implicitWidth: 170
  implicitHeight: 18

  readonly property real displayValue: root.dragging ? root._dragValue
                                                       : Math.max(0, Math.min(1, root.value))

  Rectangle {
    id: track
    anchors.fill: parent
    anchors.topMargin: 4
    anchors.bottomMargin: 4
    radius: 3
    color: theme.trackColor
    border.width: 1
    border.color: theme.trackBorder

    Rectangle {
      anchors { left: parent.left; right: parent.right; top: parent.top }
      anchors.margins: 2
      height: 1
      color: theme.trackTopShadow
    }
  }

  Item {
    id: well
    anchors.fill: track
    anchors.margins: 1
    clip: true

    Rectangle {
      id: fill
      width: parent.width * root.displayValue
      height: parent.height
      radius: 2
      gradient: Gradient {
        GradientStop { position: 0; color: theme.fillGradTop }
        GradientStop { position: 1; color: theme.fillGradBottom }
      }
      layer.enabled: root.displayValue > 0
      layer.effect: MultiEffect {
        shadowEnabled: true
        autoPaddingEnabled: false
        blurMax: 7
        shadowBlur: 1
        shadowOpacity: 0.55
        shadowColor: theme.fillGlow
        shadowHorizontalOffset: 2
      }

      Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        anchors.margins: 1
        height: 1
        color: theme.fillTopHighlight
      }
    }
  }

  Rectangle {
    x: track.x + track.width * root.displayValue - width / 2
    y: 1
    width: 8
    height: root.height - 2
    radius: 2
    color: root.dragging ? theme.accentBright : theme.accent
    border.width: 1
    border.color: theme.fillLeadingEdge
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    function updateValue(x) {
      root._dragValue = Math.max(0, Math.min(1, x / root.width))
      root.valueMoved(root._dragValue)
    }

    onPressed: mouse => {
      root.dragging = true
      updateValue(mouse.x)
    }
    onPositionChanged: mouse => {
      if (pressed) updateValue(mouse.x)
    }
    onReleased: root.dragging = false
    onCanceled: root.dragging = false
  }
}
