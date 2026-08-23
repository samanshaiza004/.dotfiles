import QtQuick
import QtQuick.Effects
import "../style"

// Interactive control built on the same layered material language as Surface.
//
// States:
//   normal   – slight physical depth (bright upper edge, dark lower edge)
//   hovered  – a bit brighter, never a jump to an unrelated color
//   pressed  – depresses: upper highlight fades, body darkens, content shifts
//              down ~1px, the inset/dark edge strengthens
//   checked  – active treatment: depth plus a restrained steel-blue glow and a
//              brighter inner edge instead of a flat colored fill
//   disabled – muted, non-interactive
Item {
  id: root

  Theme {
    id: theme
  }

  default property alias content: contentItem.data

  // --- State ---
  property bool hovered: false
  property bool pressed: false
  property bool checked: false
  property bool enabled: true

  // --- Appearance (defaults follow the state) ---
  property color activeGradTop: theme.buttonActiveGradTop
  property color activeGradBottom: theme.buttonActiveGradBottom
  property color activeBorder: theme.buttonActiveBorder
  property color activeTopHighlight: theme.buttonActiveTopHighlight
  property color activeBottomShadow: theme.buttonActiveBottomShadow
  property color activeInnerEdge: theme.buttonActiveInnerEdge
  property color activeGlowColor: theme.buttonActiveGlow

  property color gradTop: root._down ? theme.buttonPressedGradTop
      : root._active ? root.activeGradTop
      : root.hovered && root.enabled ? theme.buttonHoverGradTop
      : root.enabled ? theme.buttonGradTop : theme.buttonDisabledGradTop
  property color gradBottom: root._down ? theme.buttonPressedGradBottom
      : root._active ? root.activeGradBottom
      : root.hovered && root.enabled ? theme.buttonHoverGradBottom
      : root.enabled ? theme.buttonGradBottom : theme.buttonDisabledGradBottom
  property color borderColor: root._down ? theme.buttonPressedBorder
      : root._active ? root.activeBorder
      : root.enabled ? theme.buttonBorder : theme.buttonDisabledBorder
  property color topHighlight: root._down ? theme.buttonPressedTopHighlight
      : root._active ? root.activeTopHighlight
      : root.hovered && root.enabled ? theme.buttonHoverTopHighlight
      : theme.buttonTopHighlight
  property color bottomShadow: root._down ? theme.buttonPressedBottomShadow
      : root._active ? root.activeBottomShadow
      : root.hovered && root.enabled ? theme.buttonHoverBottomShadow
      : theme.buttonBottomShadow
  property color innerEdge: root._active ? root.activeInnerEdge : "transparent"
  property color glowColor: root.activeGlowColor
  property bool glowEnabled: true
  // Pixel radius of the active-state glow. MultiEffect expects this in blurMax.
  property real glowBlur: 5

  // --- Signals ---
  signal clicked
  signal middleClicked
  signal rightClicked

  readonly property bool _down: root.pressed && root.hovered && root.enabled
  readonly property bool _active: root.checked && root.enabled
  readonly property bool _glowing: root._active && root.glowEnabled

  implicitWidth: theme.controlSize
  implicitHeight: theme.controlSize

  // The physical material itself. The checked-state glow is a colored drop
  // shadow applied as a layer effect so the material is only rendered once
  // (a sibling MultiEffect with `source:` would draw a second copy of it).
  Surface {
    id: body
    anchors.fill: parent
    radius: theme.controlRadius
    topColor: root.gradTop
    bottomColor: root.gradBottom
    borderColor: root.borderColor
    topHighlight: root.topHighlight
    bottomShadow: root.bottomShadow
    layer.enabled: root._glowing
    layer.effect: MultiEffect {
      shadowEnabled: true
      autoPaddingEnabled: false
      blurMax: Math.max(2, Math.round(root.glowBlur))
      shadowBlur: 1.0
      shadowOpacity: 0.5
      shadowColor: root.glowColor
      shadowVerticalOffset: 1
    }
  }

  // Brighter inner edge for active/urgent states.
  Rectangle {
    anchors.fill: parent
    anchors.margins: 1
    radius: theme.controlRadius - 1
    color: "transparent"
    border.width: 1
    border.color: root.innerEdge
  }

  // Content, shifted down 1px while pressed for the tactile depress.
  Item {
    id: contentItem
    anchors.fill: parent
    y: root._down ? theme.pressOffset : 0
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    enabled: root.enabled
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onEntered: root.hovered = true
    onExited: {
      root.hovered = false
      root.pressed = false
    }
    onPressed: (mouse) => { if (mouse.button === Qt.LeftButton) root.pressed = true }
    onReleased: root.pressed = false
    onClicked: (mouse) => {
      if (mouse.button === Qt.RightButton) root.rightClicked()
      else if (mouse.button === Qt.MiddleButton) root.middleClicked()
      else root.clicked()
    }
  }
}
