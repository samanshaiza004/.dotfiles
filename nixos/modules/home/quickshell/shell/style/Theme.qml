import QtQuick
import "../generated" as Palette

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
  readonly property color textPrimary: Palette.MatugenColors.surfaceText
  readonly property color textSecondary: Palette.MatugenColors.surfaceVariantText
  readonly property color textMuted: Palette.MatugenColors.outline
  readonly property color textFaint: Palette.MatugenColors.outlineVariant
  readonly property color textOnActive: Palette.MatugenColors.primaryText
  readonly property color textOnUrgent: Palette.MatugenColors.errorText
  readonly property color textOnTrack: Palette.MatugenColors.surfaceVariantText
  readonly property color calendarWeekday: Palette.MatugenColors.surfaceVariantText
  readonly property color calendarDate: Palette.MatugenColors.surfaceText

  // ---- Graphite / smoke surfaces --------------------------------------
  readonly property color graphiteDeep: Palette.MatugenColors.surfaceContainerLowest
  readonly property color graphite: Palette.MatugenColors.surfaceContainerLow
  readonly property color graphiteLight: Palette.MatugenColors.surfaceContainer
  readonly property color steel: Palette.MatugenColors.surfaceContainerHigh
  readonly property color steelLight: Palette.MatugenColors.surfaceContainerHighest

  // ---- Muted blue-gray accent (active/focused) -------------------------
  readonly property color accent: Palette.MatugenColors.primary
  readonly property color accentBright: Palette.MatugenColors.primaryFixed
  readonly property color accentDeep: Palette.MatugenColors.primaryContainer
  readonly property color accentDim: Palette.MatugenColors.secondaryContainer

  // ---- Urgent ----------------------------------------------------------
  readonly property color urgent: Palette.MatugenColors.error
  readonly property color urgentBright: Palette.MatugenColors.error
  readonly property color urgentDeep: Palette.MatugenColors.errorContainer

  // ---- Panel glass ------------------------------------------------------
  readonly property color panelGradTop: root.alpha(Palette.MatugenColors.surfaceContainerHigh, 0.26)
  readonly property color panelGradBottom: root.alpha(Palette.MatugenColors.surface, 0.84)
  readonly property color panelTopHighlight: root.alpha(Palette.MatugenColors.surfaceText, 0.18)
  readonly property color panelBottomEdge: root.alpha(Palette.MatugenColors.surfaceContainerLowest, 0.95)
  readonly property color panelBottomShadow: "#33000000"

  // ---- Generic surface (popups, menus) ----------------------------------
  readonly property color surfaceGradTop: root.alpha(Palette.MatugenColors.surfaceContainerHigh, 0.55)
  readonly property color surfaceGradBottom: root.alpha(Palette.MatugenColors.surface, 0.9)
  readonly property color surfaceBorder: root.alpha(Palette.MatugenColors.outline, 0.4)
  readonly property color surfaceTopHighlight: root.alpha(Palette.MatugenColors.surfaceText, 0.22)
  readonly property color surfaceBottomShadow: "#3A000000"
  readonly property color surfaceShadow: "#000000"

  // ---- Light variant ------------------------------------------------------
  readonly property color lightSurfaceGradTop: Palette.MatugenColors.surfaceBright
  readonly property color lightSurfaceGradBottom: Palette.MatugenColors.surfaceContainerHigh
  readonly property color lightSurfaceBorder: Palette.MatugenColors.outline
  readonly property color lightSurfaceTopHighlight: root.alpha(Palette.MatugenColors.surfaceText, 0.25)
  readonly property color lightSurfaceBottomShadow: "#2E101010"

  // ---- Buttons ----------------------------------------------------------
  readonly property color buttonGradTop: root.alpha(Palette.MatugenColors.surfaceContainerHighest, 0.9)
  readonly property color buttonGradBottom: root.alpha(Palette.MatugenColors.surfaceContainerHigh, 0.9)
  readonly property color buttonBorder: root.alpha(Palette.MatugenColors.outline, 0.55)
  readonly property color buttonTopHighlight: root.alpha(Palette.MatugenColors.surfaceText, 0.19)
  readonly property color buttonBottomShadow: "#26000000"

  readonly property color buttonHoverGradTop: root.alpha(Palette.MatugenColors.primaryContainer, 0.9)
  readonly property color buttonHoverGradBottom: root.alpha(Palette.MatugenColors.surfaceContainerHigh, 0.9)
  readonly property color buttonHoverTopHighlight: root.alpha(Palette.MatugenColors.primaryText, 0.24)
  readonly property color buttonHoverBottomShadow: "#2E000000"

  readonly property color buttonPressedGradTop: root.alpha(Palette.MatugenColors.surfaceContainerLow, 0.95)
  readonly property color buttonPressedGradBottom: root.alpha(Palette.MatugenColors.surfaceContainerLowest, 0.95)
  readonly property color buttonPressedBorder: root.alpha(Palette.MatugenColors.outline, 0.7)
  readonly property color buttonPressedTopHighlight: root.alpha(Palette.MatugenColors.surfaceText, 0.05)
  readonly property color buttonPressedBottomShadow: "#4D000000"

  readonly property color buttonActiveGradTop: root.alpha(Palette.MatugenColors.primary, 0.9)
  readonly property color buttonActiveGradBottom: root.alpha(Palette.MatugenColors.primaryContainer, 0.9)
  readonly property color buttonActiveBorder: root.alpha(Palette.MatugenColors.outline, 0.55)
  readonly property color buttonActiveTopHighlight: root.alpha(Palette.MatugenColors.primaryText, 0.29)
  readonly property color buttonActiveBottomShadow: "#30000000"
  readonly property color buttonActiveInnerEdge: root.alpha(Palette.MatugenColors.primaryFixed, 0.7)
  readonly property color buttonActiveGlow: Palette.MatugenColors.primary

  readonly property color buttonUrgentGradTop: root.alpha(Palette.MatugenColors.error, 0.9)
  readonly property color buttonUrgentGradBottom: root.alpha(Palette.MatugenColors.errorContainer, 0.9)
  readonly property color buttonUrgentBorder: root.alpha(Palette.MatugenColors.outline, 0.55)
  readonly property color buttonUrgentTopHighlight: root.alpha(Palette.MatugenColors.errorText, 0.29)
  readonly property color buttonUrgentInnerEdge: root.alpha(Palette.MatugenColors.error, 0.7)
  readonly property color buttonUrgentGlow: Palette.MatugenColors.error

  readonly property color buttonDisabledGradTop: "#A61E1F23"
  readonly property color buttonDisabledGradBottom: "#A618191C"
  readonly property color buttonDisabledBorder: "#FF0A0A0C"

  // ---- Recessed tracks / progress --------------------------------------
  readonly property color trackColor: "#E6101113"
  readonly property color trackBorder: "#FF070708"
  readonly property color trackTopShadow: "#40000000"
  readonly property color trackInnerTop: "#14FFFFFF"
  readonly property color fillGradTop: root.alpha(Palette.MatugenColors.primary, 0.94)
  readonly property color fillGradBottom: root.alpha(Palette.MatugenColors.primaryContainer, 0.94)
  readonly property color fillTopHighlight: root.alpha(Palette.MatugenColors.primaryText, 0.36)
  readonly property color fillLeadingEdge: Palette.MatugenColors.primaryFixed
  readonly property color fillGlow: Palette.MatugenColors.primary

  // ---- Tooltip -----------------------------------------------------------
  readonly property color tooltipBase: Palette.MatugenColors.surfaceBright
  readonly property color tooltipBorder: Palette.MatugenColors.outline
  readonly property color tooltipText: Palette.MatugenColors.surfaceText
  readonly property color tooltipShadow: "#40000000"
  readonly property int tooltipRadius: 2

  // ---- Focused app title -------------------------------------------------
  readonly property color focusedAppText: Palette.MatugenColors.surfaceVariantText
}
