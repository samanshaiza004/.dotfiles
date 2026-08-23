pragma Singleton

import QtQuick

QtObject {
  readonly property color primary: "{{colors.primary.default.hex}}"
  readonly property color primaryText: "{{colors.on_primary.default.hex}}"
  readonly property color primaryContainer: "{{colors.primary_container.default.hex}}"
  readonly property color primaryContainerText: "{{colors.on_primary_container.default.hex}}"
  readonly property color primaryFixed: "{{colors.primary_fixed.default.hex}}"
  readonly property color secondary: "{{colors.secondary.default.hex}}"
  readonly property color secondaryText: "{{colors.on_secondary.default.hex}}"
  readonly property color secondaryContainer: "{{colors.secondary_container.default.hex}}"
  readonly property color tertiary: "{{colors.tertiary.default.hex}}"
  readonly property color error: "{{colors.error.default.hex}}"
  readonly property color errorText: "{{colors.on_error.default.hex}}"
  readonly property color errorContainer: "{{colors.error_container.default.hex}}"
  readonly property color surface: "{{colors.surface.default.hex}}"
  readonly property color surfaceBright: "{{colors.surface_bright.default.hex}}"
  readonly property color surfaceContainerLowest: "{{colors.surface_container_lowest.default.hex}}"
  readonly property color surfaceContainerLow: "{{colors.surface_container_low.default.hex}}"
  readonly property color surfaceContainer: "{{colors.surface_container.default.hex}}"
  readonly property color surfaceContainerHigh: "{{colors.surface_container_high.default.hex}}"
  readonly property color surfaceContainerHighest: "{{colors.surface_container_highest.default.hex}}"
  readonly property color surfaceText: "{{colors.on_surface.default.hex}}"
  readonly property color surfaceVariantText: "{{colors.on_surface_variant.default.hex}}"
  readonly property color outline: "{{colors.outline.default.hex}}"
  readonly property color outlineVariant: "{{colors.outline_variant.default.hex}}"
}
