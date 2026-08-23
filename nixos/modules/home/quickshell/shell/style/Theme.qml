import QtQuick
import "../services" as Services

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
  readonly property int popupOpenDuration: 400
  readonly property int popupCloseDuration: 300

  function alpha(color, opacity) {
    return Qt.rgba(color.r, color.g, color.b, opacity)
  }

  // ---- Text -----------------------------------------------------------
  readonly property color textPrimary: "#E9E6DF"
  readonly property color textSecondary: "#B8B3A9"
  readonly property color textMuted: "#8A857B"
  readonly property color textFaint: "#66615A"
  readonly property color textOnActive: "#EFF4F9"
  readonly property color textOnUrgent: "#F2B49C"
  readonly property color textOnTrack: "#DCE4EC"
  readonly property color calendarWeekday: "#C9CBC9"
  readonly property color calendarDate: "#D4D3CE"

  // ---- Graphite / smoke surfaces --------------------------------------
  readonly property color graphiteDeep: "#121315"
  readonly property color graphite: "#1C1D20"
  readonly property color graphiteLight: "#26272B"
  readonly property color steel: "#33343A"
  readonly property color steelLight: "#3D3F46"

  // ---- Muted blue-gray accent (active/focused) -------------------------
  readonly property color accent: Services.ColorService.primary
  readonly property color accentBright: Services.ColorService.primaryFixed
  readonly property color accentDeep: Services.ColorService.primaryContainer
  readonly property color accentDim: Services.ColorService.secondaryContainer

  // ---- Urgent ----------------------------------------------------------
  readonly property color urgent: Services.ColorService.error
  readonly property color urgentBright: Services.ColorService.error
  readonly property color urgentDeep: Services.ColorService.errorContainer

  // ---- Panel glass ------------------------------------------------------
  readonly property color panelGradTop: root.alpha(Services.ColorService.primary, 0.12)
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

  readonly property color buttonActiveGradTop: root.alpha(Services.ColorService.primary, 0.9)
  readonly property color buttonActiveGradBottom: root.alpha(Services.ColorService.primaryContainer, 0.9)
  readonly property color buttonActiveBorder: "#FF0A0A0C"
  readonly property color buttonActiveTopHighlight: "#4AFFFFFF"
  readonly property color buttonActiveBottomShadow: "#30000000"
  readonly property color buttonActiveInnerEdge: root.alpha(Services.ColorService.primaryFixed, 0.7)
  readonly property color buttonActiveGlow: Services.ColorService.primary

  readonly property color buttonUrgentGradTop: root.alpha(Services.ColorService.error, 0.9)
  readonly property color buttonUrgentGradBottom: root.alpha(Services.ColorService.errorContainer, 0.9)
  readonly property color buttonUrgentBorder: "#FF0A0A0C"
  readonly property color buttonUrgentTopHighlight: "#4AF2B49C"
  readonly property color buttonUrgentInnerEdge: root.alpha(Services.ColorService.error, 0.7)
  readonly property color buttonUrgentGlow: Services.ColorService.error

  readonly property color buttonDisabledGradTop: "#A61E1F23"
  readonly property color buttonDisabledGradBottom: "#A618191C"
  readonly property color buttonDisabledBorder: "#FF0A0A0C"

  // ---- Recessed tracks / progress --------------------------------------
  readonly property color trackColor: "#E6101113"
  readonly property color trackBorder: "#FF070708"
  readonly property color trackTopShadow: "#40000000"
  readonly property color trackInnerTop: "#14FFFFFF"
  readonly property color fillGradTop: root.alpha(Services.ColorService.primary, 0.94)
  readonly property color fillGradBottom: root.alpha(Services.ColorService.primaryContainer, 0.94)
  readonly property color fillTopHighlight: "#5CFFFFFF"
  readonly property color fillLeadingEdge: Services.ColorService.primaryFixed
  readonly property color fillGlow: Services.ColorService.primary

  // ---- Tooltip -----------------------------------------------------------
  readonly property color tooltipBase: "#F4F1EB"
  readonly property color tooltipBorder: "#FF1A1A1C"
  readonly property color tooltipText: "#1A1A1C"
  readonly property color tooltipShadow: "#40000000"
  readonly property int tooltipRadius: 2

  // ---- Focused app title -------------------------------------------------
  readonly property color focusedAppText: "#C9C4BA"
}
