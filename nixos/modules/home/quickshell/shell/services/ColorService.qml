pragma Singleton

import QtQuick
import QtCore
import Quickshell.Io

Item {
  id: root

  visible: false

  readonly property color sourceColor: palette.source_color

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
      property string source_color: "#6e93c4"
    }
  }
}
