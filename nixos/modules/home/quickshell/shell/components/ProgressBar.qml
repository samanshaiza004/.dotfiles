import QtQuick
import QtQuick.Effects
import "../style"

// Late-2000s progress bar language: a clearly recessed track with a dark
// border, a filled region with a vertical gradient and a top specular line,
// and a soft glow at the leading edge of the fill.
Item {
  id: root

  Theme {
    id: theme
  }

  property real value: 0 // 0..1

  property color trackColor: theme.trackColor
  property color trackBorder: theme.trackBorder
  property color fillTop: theme.fillGradTop
  property color fillBottom: theme.fillGradBottom
  property color fillHighlight: theme.fillTopHighlight
  property color fillLeadingEdge: theme.fillLeadingEdge
  property color fillGlow: theme.fillGlow
  property bool glowEnabled: true
  // Pixel radius of the leading-edge glow (mapped to MultiEffect.blurMax).
  property real glowBlur: 8

  implicitWidth: 120
  implicitHeight: 10

  // Recessed track.
  Rectangle {
    id: track
    anchors.fill: parent
    radius: 3
    color: root.trackColor
    border.width: 1
    border.color: root.trackBorder

    // Inner top shadow: the upper edge of a recessed well recedes.
    Rectangle {
      anchors { left: parent.left; right: parent.right; top: parent.top }
      anchors.margins: 2
      height: 1
      color: theme.trackTopShadow
    }
  }

  // Filled region, kept inside the well.
  Item {
    id: well
    anchors.fill: track
    anchors.margins: 1
    clip: true

    Rectangle {
      id: fill
      width: parent.width * Math.max(0, Math.min(1, root.value))
      height: parent.height
      radius: 2
      gradient: Gradient {
        GradientStop { position: 0.0; color: root.fillTop }
        GradientStop { position: 1.0; color: root.fillBottom }
      }
      // Leading-edge glow applied as a layer effect on the fill itself (a
      // sibling MultiEffect with `source: fill` would draw a second copy of it).
      layer.enabled: root.glowEnabled && root.value > 0
      layer.effect: MultiEffect {
        shadowEnabled: true
        autoPaddingEnabled: false
        blurMax: Math.max(2, Math.round(root.glowBlur))
        shadowBlur: 1.0
        shadowOpacity: 0.6
        shadowColor: root.fillGlow
        shadowHorizontalOffset: 2
      }

      // Top specular highlight on the fill.
      Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        anchors.margins: 1
        height: 1
        color: root.fillHighlight
      }

      // Bright leading edge line.
      Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: 1
        color: root.fillLeadingEdge
      }
    }
  }
}