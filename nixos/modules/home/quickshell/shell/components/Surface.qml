import QtQuick
import QtQuick.Effects
import "../style"

// Base material for the shell. Every panel/popup/control is built from this
// layered language instead of a single flat Rectangle:
//
//   ┌──────────────────────────────┐
//   │ 1px pale top highlight      │
//   │ ─────────────────────────── │
//   │                             │
//   │     vertical gradient       │
//   │                             │
//   └──────────────────────────────┘
//        darker lower edge
//
// Order (bottom -> top): optional soft shadow, gradient body, outer dark
// border, 1px inner top highlight, 1px inner bottom shadow, then content.
// A light source is assumed to sit above the interface.
Item {
  id: root

  Theme {
    id: theme
  }

  default property alias content: contentItem.data

  // --- Appearance ---
  property color topColor: theme.surfaceGradTop
  property color bottomColor: theme.surfaceGradBottom
  property color borderColor: theme.surfaceBorder
  property color topHighlight: theme.surfaceTopHighlight
  property color bottomShadow: theme.surfaceBottomShadow
  property real radius: theme.surfaceRadius
  property real bodyOpacity: 1.0

  // --- Shadow ---
  property bool shadowEnabled: false
  property real shadowBlur: 28
  property real shadowOpacity: 0.7
  property color shadowColor: theme.surfaceShadow
  property real shadowOffsetX: 0
  property real shadowOffsetY: 3

  // --- Light/dark variants ---
  property bool light: false

  property color effectiveTop: root.light ? theme.lightSurfaceGradTop : root.topColor
  property color effectiveBottom: root.light ? theme.lightSurfaceGradBottom : root.bottomColor
  property color effectiveBorder: root.light ? theme.lightSurfaceBorder : root.borderColor
  property color effectiveHighlight: root.light ? theme.lightSurfaceTopHighlight : root.topHighlight
  property color effectiveBottomShadow: root.light ? theme.lightSurfaceBottomShadow : root.bottomShadow

  readonly property real _shadowMargin: root.shadowEnabled ? root.shadowBlur : 0

  // Room the shadow needs around the material. Popups/menus should size their
  // window to include these; the top pad can be reduced so an attached popup's
  // card still hugs its anchor without the window overlapping the panel.
  property real shadowPad: root._shadowMargin
  property real shadowPadTop: root.shadowPad

  implicitWidth: 120
  implicitHeight: 40

  // Layered material body.
  //
  // The shadow is applied as a layer effect on the material itself. Using a
  // sibling MultiEffect with `source: material` would draw a second copy of the
  // whole material (text, bars, everything) alongside the real one; Qt
  // explicitly warns against that. A layer effect replaces the source with the
  // effect output, so there is exactly one rendering.
  Item {
    id: material
    anchors {
      fill: parent
      margins: root.shadowPad
      topMargin: root.shadowPadTop
    }
    layer.enabled: root.shadowEnabled
    layer.effect: MultiEffect {
      shadowEnabled: true
      // autoPadding is off: the caller already reserves room via shadowPad and
      // the window, so the shadow bleeding out of the material is not clipped.
      autoPaddingEnabled: false
      // root.shadowBlur is a pixel radius; MultiEffect expects blurMax (pixels)
      // + shadowBlur (0..1 normalized).
      blurMax: Math.max(2, Math.round(root.shadowBlur))
      shadowBlur: 1.0
      shadowColor: root.shadowColor
      shadowOpacity: root.shadowOpacity
      shadowHorizontalOffset: root.shadowOffsetX
      shadowVerticalOffset: root.shadowOffsetY
    }

    // Gradient body.
    Rectangle {
      id: body
      anchors.fill: parent
      radius: root.radius
      opacity: root.bodyOpacity
      gradient: Gradient {
        GradientStop { position: 0.0; color: root.effectiveTop }
        GradientStop { position: 1.0; color: root.effectiveBottom }
      }
    }

    // Outer dark border.
    Rectangle {
      anchors.fill: parent
      radius: root.radius
      color: "transparent"
      border.width: 1
      border.color: root.effectiveBorder
    }

    // 1px pale highlight across the top inner edge (upper edge catches light).
    Rectangle {
      anchors { left: parent.left; right: parent.right; top: parent.top }
      anchors.margins: root.radius > 0 ? root.radius : 0
      height: 1
      color: root.effectiveHighlight
      visible: root.radius === 0
    }

    // 1px darker inner shadow along the lower edge (lower edge recedes).
    Rectangle {
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      anchors.margins: root.radius > 0 ? root.radius : 0
      height: 1
      color: root.effectiveBottomShadow
      visible: root.radius === 0
    }

    // Content, clipped to the surface shape when corners are rounded.
    Rectangle {
      id: contentClip
      anchors.fill: parent
      radius: root.radius
      color: "transparent"
      clip: root.radius > 0

      Item {
        id: contentItem
        anchors.fill: parent
      }
    }
  }
}