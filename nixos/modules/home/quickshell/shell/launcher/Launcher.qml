import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import "../components"
import "../style"

// Small application launcher owned by Quickshell. The IPC handler is the
// compositor-facing toggle; desktop entries remain the application source.
PanelWindow {
  id: root

  required property var panelWindow
  required property var popupController

  Theme { id: theme }

  visible: false
  screen: root.panelWindow ? root.panelWindow.screen : null
  color: "transparent"
  exclusiveZone: 0

  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "late-2000s-launcher"
  WlrLayershell.keyboardFocus: root.visible
    ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  function toggle() {
    if (root.visible) root.close()
    else root.open()
  }

  function open() {
    root.popupController.closeAll()
    root.visible = true
    Qt.callLater(() => search.forceActiveFocus())
  }

  function close() {
    root.visible = false
  }

  function matches(entry) {
    if (!entry) return false
    const query = root.query.trim().toLowerCase()
    if (query === "") return true
    const haystack = [entry.name, entry.genericName, entry.id, entry.comment]
      .filter(value => value)
      .join(" ")
      .toLowerCase()
    return haystack.indexOf(query) >= 0
  }

  function entryLabel(entry) {
    if (!entry) return "Application"
    return entry.name || entry.genericName || entry.id || "Application"
  }

  function launch(entry) {
    if (!entry) return
    entry.execute()
    root.close()
  }

  function launchFirstMatch() {
    for (const entry of DesktopEntries.applications.values) {
      if (root.matches(entry)) {
        root.launch(entry)
        return
      }
    }
  }

  readonly property string query: search.text
  readonly property int matchCount: {
    let count = 0
    for (const entry of DesktopEntries.applications.values) {
      if (root.matches(entry)) count++
    }
    return count
  }

  IpcHandler {
    target: "launcher"
    function toggle(): void { root.toggle() }
  }

  Item {
    id: keySurface
    anchors.fill: parent
    focus: root.visible

    Keys.onEscapePressed: root.close()

    MouseArea {
      anchors.fill: parent
      z: 0
      onClicked: root.close()
    }

    Surface {
      id: card
      anchors.centerIn: parent
      width: Math.min(560, parent.width - 32)
      height: Math.min(460, parent.height - 32)
      z: 1
      radius: theme.surfaceRadius + 1
      shadowEnabled: true
      shadowBlur: 30
      shadowOpacity: 0.8

      content: Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Row {
          width: parent.width
          height: 28
          spacing: 7

          IconImage {
            width: 22
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            source: Quickshell.iconPath("start-here", "application-x-executable")
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            color: theme.textOnActive
            font.pixelSize: theme.textSizeLarge
            font.bold: true
            text: "Applications"
          }
        }

        Rectangle {
          width: parent.width
          height: 32
          color: theme.trackColor
          border.width: 1
          border.color: theme.trackBorder

          TextInput {
            id: search
            anchors.fill: parent
            anchors.leftMargin: 9
            anchors.rightMargin: 9
            color: theme.textPrimary
            font.pixelSize: theme.textSizeLarge
            selectByMouse: true
            verticalAlignment: TextInput.AlignVCenter

            Keys.onEscapePressed: root.close()
            Keys.onReturnPressed: root.launchFirstMatch()
          }

          Text {
            anchors {
              left: parent.left
              leftMargin: 9
              verticalCenter: parent.verticalCenter
            }
            color: theme.textMuted
            font.pixelSize: theme.textSizeLarge
            text: "Search applications"
            visible: search.text === ""
          }
        }

        ScrollView {
          id: appScroll
          width: parent.width
          height: parent.height - 76
          clip: true
          contentWidth: availableWidth
          ScrollBar.vertical.policy: ScrollBar.AsNeeded

          Column {
            id: appList
            width: appScroll.availableWidth
            spacing: 4

            Repeater {
              model: DesktopEntries.applications

              Item {
                required property var modelData
                readonly property bool matchesQuery: root.matches(modelData)
                width: appList.width
                height: matchesQuery ? 32 : 0
                visible: matchesQuery

                ButtonFrame {
                  anchors.fill: parent
                  onClicked: root.launch(modelData)

                  Row {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    IconImage {
                      width: 20
                      height: 20
                      anchors.verticalCenter: parent.verticalCenter
                      source: Quickshell.iconPath(
                        modelData.icon || "application-x-executable",
                        "application-x-executable"
                      )
                    }

                    Text {
                      anchors.verticalCenter: parent.verticalCenter
                      width: parent.width - 28
                      color: theme.textSecondary
                      elide: Text.ElideRight
                      font.pixelSize: theme.textSizeLarge
                      text: root.entryLabel(modelData)
                    }
                  }
                }
              }
            }
          }
        }

        Text {
          visible: root.matchCount === 0
          color: theme.textMuted
          font.pixelSize: theme.textSize
          text: "No matching applications"
        }
      }
    }
  }

  onVisibleChanged: {
    if (root.visible) {
      search.forceActiveFocus()
      search.selectAll()
    } else {
      search.text = ""
    }
  }
}
