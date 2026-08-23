import QtQuick

// Central visual vocabulary for the shell: one source of truth for the
// palette and the few dimensions that define the "late-2000s" grammar.
// The look is glass / layered graphite rather than flat modern surfaces:
//   - light source sits above the interface (bright upper edges, dark lower)
//   - depth comes from stacked 1px edges + vertical gradients, not big radii
//   - saturated color is reserved for active / focused / urgent states
QtObject {
  id: root

  // ---- Dimensions -----------------------------------------------------
  readonly property int panelHeight: 32
  readonly property int controlSize: 22
  readonly property int controlRadius: 3
  readonly property int surfaceRadius: 5
  readonly property int textSize: 11
  readonly property int textSizeLarge: 12
  readonly property int pressOffset: 1

  // ---- Text -----------------------------------------------------------
  readonly property color textPrimary: "#E9E6DF"
  readonly property color textSecondary: "#B8B3A9"
  readonly property color textMuted: "#8A857B"
  readonly property color textFaint: "#66615A"
  readonly property color textOnActive: "#EFF4F9"
  readonly property color textOnUrgent: "#F2B49C"
  readonly property color textOnTrack: "#DCE4EC"

  // ---- Graphite / smoke surfaces --------------------------------------
  readonly property color graphiteDeep: "#121315"
  readonly property color graphite: "#1C1D20"
  readonly property color graphiteLight: "#26272B"
  readonly property color steel: "#33343A"
  readonly property color steelLight: "#3D3F46"

  // ---- Muted blue-gray accent (active/focused) -------------------------
  readonly property color accent: "#6E93C4"
  readonly property color accentBright: "#9CB7DB"
  readonly property color accentDeep: "#33506E"
  readonly property color accentDim: "#42536B"

  // ---- Urgent ----------------------------------------------------------
  readonly property color urgent: "#C05B3C"
  readonly property color urgentBright: "#E07A55"
  readonly property color urgentDeep: "#3A2018"

  // ---- Panel glass ------------------------------------------------------
  readonly property color panelGradTop: "#603B3C42"
  readonly property color panelGradBottom: "#D9151619"
  readonly property color panelTopHighlight: "#2EFFFFFF"
  readonly property color panelBottomEdge: "#FF0A0A0C"
  readonly property color panelBottomShadow: "#33000000"

  // ---- Generic surface (popups, menus) ----------------------------------
  readonly property color surfaceGradTop: "#8C4A4B52"
  readonly property color surfaceGradBottom: "#E616171A"
  readonly property color surfaceBorder: "#FF0A0A0C"
  readonly property color surfaceTopHighlight: "#38FFFFFF"
  readonly property color surfaceBottomShadow: "#3A000000"
  readonly property color surfaceShadow: "#000000"

  // ---- Light variant ------------------------------------------------------
  readonly property color lightSurfaceGradTop: "#F4ECECEF"
  readonly property color lightSurfaceGradBottom: "#D8BCBCA0"
  readonly property color lightSurfaceBorder: "#FF58585E"
  readonly property color lightSurfaceTopHighlight: "#40FFFFFF"
  readonly property color lightSurfaceBottomShadow: "#2E101010"

  // ---- Buttons ----------------------------------------------------------
  readonly property color buttonGradTop: "#E6474850"
  readonly property color buttonGradBottom: "#E6292A2F"
  readonly property color buttonBorder: "#FF09090B"
  readonly property color buttonTopHighlight: "#30FFFFFF"
  readonly property color buttonBottomShadow: "#26000000"

  readonly property color buttonHoverGradTop: "#E6585A65"
  readonly property color buttonHoverGradBottom: "#E633353C"
  readonly property color buttonHoverTopHighlight: "#3CFFFFFF"
  readonly property color buttonHoverBottomShadow: "#2E000000"

  readonly property color buttonPressedGradTop: "#E6232428"
  readonly property color buttonPressedGradBottom: "#E631333A"
  readonly property color buttonPressedBorder: "#FF050506"
  readonly property color buttonPressedTopHighlight: "#0DFFFFFF"
  readonly property color buttonPressedBottomShadow: "#4D000000"

  readonly property color buttonActiveGradTop: "#E65A6E8A"
  readonly property color buttonActiveGradBottom: "#E8364460"
  readonly property color buttonActiveBorder: "#FF0A0A0C"
  readonly property color buttonActiveTopHighlight: "#4AFFFFFF"
  readonly property color buttonActiveBottomShadow: "#30000000"
  readonly property color buttonActiveInnerEdge: "#B49CB7DB"
  readonly property color buttonActiveGlow: "#6E93C4"

  readonly property color buttonUrgentGradTop: "#E65A362A"
  readonly property color buttonUrgentGradBottom: "#E8392118"
  readonly property color buttonUrgentBorder: "#FF0A0A0C"
  readonly property color buttonUrgentTopHighlight: "#4AF2B49C"
  readonly property color buttonUrgentInnerEdge: "#B4E07A55"
  readonly property color buttonUrgentGlow: "#C05B3C"

  readonly property color buttonDisabledGradTop: "#A61E1F23"
  readonly property color buttonDisabledGradBottom: "#A618191C"
  readonly property color buttonDisabledBorder: "#FF0A0A0C"

  // ---- Recessed tracks / progress --------------------------------------
  readonly property color trackColor: "#E6101113"
  readonly property color trackBorder: "#FF070708"
  readonly property color trackTopShadow: "#40000000"
  readonly property color trackInnerTop: "#14FFFFFF"
  readonly property color fillGradTop: "#F08FB4D9"
  readonly property color fillGradBottom: "#E84A7095"
  readonly property color fillTopHighlight: "#5CFFFFFF"
  readonly property color fillLeadingEdge: "#FFC7D9EC"
  readonly property color fillGlow: "#6E93C4"

  // ---- Tooltip -----------------------------------------------------------
  readonly property color tooltipBase: "#F4F1EB"
  readonly property color tooltipBorder: "#FF1A1A1C"
  readonly property color tooltipText: "#1A1A1C"
  readonly property color tooltipShadow: "#40000000"
  readonly property int tooltipRadius: 2

  // ---- Focused app title -------------------------------------------------
  readonly property color focusedAppText: "#C9C4BA"
}