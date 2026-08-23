pragma Singleton

import QtQuick
import QtCore
import Quickshell.Io

Item {
  id: root

  visible: false

  readonly property color primary: palette.primary
  readonly property color primaryText: palette.on_primary
  readonly property color primaryContainer: palette.primary_container
  readonly property color primaryFixed: palette.primary_fixed
  readonly property color secondaryContainer: palette.secondary_container
  readonly property color error: palette.error
  readonly property color errorText: palette.error_text
  readonly property color errorContainer: palette.error_container
  readonly property color surfaceText: palette.on_surface
  readonly property color surfaceVariantText: palette.on_surface_variant
  readonly property color surfaceBright: palette.surface_bright
  readonly property color outline: palette.outline
  readonly property color outlineVariant: palette.outline_variant

  FileView {
    id: paletteFile
    path: StandardPaths.writableLocation(StandardPaths.ConfigLocation)
      + "/quickshell/generated/palette.json"
    preload: true
    printErrors: false
    watchChanges: true
    onFileChanged: reload()

    JsonAdapter {
      id: palette
      property string primary: "#6e93c4"
      property string on_primary: "#ffffff"
      property string primary_container: "#33506e"
      property string primary_fixed: "#9cb7db"
      property string secondary_container: "#42536b"
      property string error: "#c05b3c"
      property string error_text: "#ffffff"
      property string error_container: "#3a2018"
      property string on_surface: "#e9e6df"
      property string on_surface_variant: "#b8b3a9"
      property string surface_bright: "#3d3f46"
      property string outline: "#8a857b"
      property string outline_variant: "#66615a"
    }
  }
}
