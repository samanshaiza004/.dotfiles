import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtCore
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../components"
import "../style"

PanelWindow {
  id: root

  required property var panelWindow
  required property var popupController
  required property var appCatalog
  property var startButton: null
  property bool closing: false
  property bool launching: false
  property int selectedIndex: 0
  property string selectedCategory: "All Programs"
  property var pendingLaunch: null

  Theme { id: theme }

  visible: false
  screen: root.panelWindow ? root.panelWindow.screen : null
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore

  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "late-2000s-start-menu"
  WlrLayershell.keyboardFocus: root.visible
    ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  readonly property rect startButtonRect: {
    if (!root.startButton || !root.panelWindow || !root.panelWindow.contentItem) {
      return Qt.rect(8, 0, 30, theme.panelHeight)
    }
    var position = root.startButton.mapToItem(root.panelWindow.contentItem, 0, 0)
    return Qt.rect(position.x, position.y, root.startButton.width, root.startButton.height)
  }

  readonly property var places: [
    {
      id: "home",
      name: "Home",
      icon: "user-home",
      path: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    },
    {
      id: "computer",
      name: "Computer",
      icon: "computer",
      path: "/"
    },
    {
      id: "documents",
      name: "Documents",
      icon: "folder-documents",
      path: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
    },
    {
      id: "downloads",
      name: "Downloads",
      icon: "folder-download",
      path: StandardPaths.writableLocation(StandardPaths.DownloadLocation)
    },
    {
      id: "pictures",
      name: "Pictures",
      icon: "folder-pictures",
      path: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
    }
  ].filter(function (place) { return place.path !== "" })

  function toggle() {
    if (root.visible && !root.closing) root.close()
    else root.open()
  }

  function open() {
    enterAnimation.stop()
    exitAnimation.stop()
    root.pendingLaunch = null
    root.launching = false
    root.closing = false
    root.selectedIndex = 0
    root.selectedCategory = "All Programs"
    root.appCatalog.search("", root.selectedCategory)
    searchInput.text = ""
    card.opacity = 0
    card.scale = 0.98
    root.visible = true
    enterAnimation.restart()
    root.popupController.closeAll()
    Qt.callLater(function () {
      if (root.visible && !root.closing) searchInput.forceActiveFocus()
    })
  }

  function close() {
    if (!root.visible || root.closing) return
    root.closing = true
    searchTimer.stop()
    exitAnimation.restart()
  }

  function closeImmediately() {
    enterAnimation.stop()
    exitAnimation.stop()
    searchTimer.stop()
    launchTimer.stop()
    root.pendingLaunch = null
    root.launching = false
    root.closing = false
    root.visible = false
    searchInput.text = ""
    root.selectedIndex = 0
  }

  function selectCategory(category) {
    root.selectedCategory = category
    root.selectedIndex = 0
    root.scheduleSearch()
    searchInput.forceActiveFocus()
  }

  function scheduleSearch() {
    if (!root.visible || root.closing) return
    searchTimer.restart()
  }

  function moveSelection(delta) {
    var count = root.appCatalog.results.length
    if (count === 0) return
    root.selectedIndex = Math.max(0, Math.min(count - 1, root.selectedIndex + delta))
    appList.ensureSelectedVisible()
  }

  function movePage(delta) {
    moveSelection(delta * Math.max(1, Math.floor(appList.height / 51)))
  }

  function activateSelected() {
    if (root.launching || root.appCatalog.results.length === 0) return
    var record = root.appCatalog.results[root.selectedIndex]
    if (!record) return
    root.pendingLaunch = record
    root.launching = true
    root.close()
    launchTimer.restart()
  }

  function openPlace(place) {
    if (!place || !place.path) return
    root.close()
    Qt.callLater(function () {
      Quickshell.execDetached({ command: ["xdg-open", place.path] })
    })
  }

  IpcHandler {
    target: "launcher"
    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
  }

  Connections {
    target: root.appCatalog
    function onResultsChanged() {
      root.selectedIndex = root.appCatalog.results.length === 0
        ? 0 : Math.min(root.selectedIndex, root.appCatalog.results.length - 1)
      Qt.callLater(appList.ensureSelectedVisible)
    }
    function onCategoriesChanged() {
      if (root.appCatalog.categories.indexOf(root.selectedCategory) === -1) {
        root.selectedCategory = "All Programs"
        root.scheduleSearch()
      }
    }
  }

  Timer {
    id: searchTimer
    interval: 45
    repeat: false
    onTriggered: {
      root.selectedIndex = 0
      root.appCatalog.search(searchInput.text, root.selectedCategory)
    }
  }

  Timer {
    id: launchTimer
    interval: 130
    repeat: false
    onTriggered: {
      var record = root.pendingLaunch
      root.pendingLaunch = null
      root.launching = false
      if (record) root.appCatalog.launch(record)
    }
  }

  ParallelAnimation {
    id: enterAnimation
    NumberAnimation { target: card; property: "opacity"; from: 0; to: 1; duration: 140; easing.type: Easing.OutCubic }
    NumberAnimation { target: card; property: "scale"; from: 0.98; to: 1; duration: 140; easing.type: Easing.OutCubic }
  }

  SequentialAnimation {
    id: exitAnimation
    ParallelAnimation {
      NumberAnimation { target: card; property: "opacity"; to: 0; duration: 110; easing.type: Easing.InCubic }
      NumberAnimation { target: card; property: "scale"; to: 0.98; duration: 110; easing.type: Easing.InCubic }
    }
    ScriptAction {
      script: {
        root.visible = false
        root.closing = false
        searchInput.text = ""
        root.selectedIndex = 0
        if (!root.pendingLaunch) root.launching = false
      }
    }
  }

  mask: Region {
    width: root.width
    height: root.height

    // Leave only the real Start button clickable through the overlay. Other
    // panel clicks are intentionally consumed as outside-click dismissal.
    Region {
      intersection: Intersection.Subtract
      x: root.startButtonRect.x
      y: root.startButtonRect.y
      width: root.startButtonRect.width
      height: root.startButtonRect.height
    }
  }

  MouseArea {
    anchors.fill: parent
    z: 0
    onClicked: root.close()
  }

  Surface {
    id: card
    x: Math.max(8, Math.min(root.startButtonRect.x, root.width - width - 8))
    y: theme.panelHeight + 2
    width: Math.min(660, Math.max(280, root.width - 16))
    height: Math.min(520, Math.max(280, root.height - theme.panelHeight - 16))
    z: 1
    radius: theme.surfaceRadius + 1
    shadowEnabled: true
    shadowBlur: 30
    shadowOpacity: 0.82
    shadowPadTop: 0
    transformOrigin: Item.TopLeft
    topColor: theme.startSurfaceGradTop
    bottomColor: theme.surfaceGradBottom

    content: ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 8

      RowLayout {
        Layout.fillWidth: true
        spacing: 8

        IconImage {
          Layout.preferredWidth: 24
          Layout.preferredHeight: 24
          asynchronous: true
          source: Quickshell.iconPath("start-here", "application-x-executable")
        }

        Text {
          Layout.fillWidth: true
          color: theme.textPrimary
          font.bold: true
          font.pixelSize: theme.textSizeLarge
          text: "Applications"
        }

        Text {
          color: theme.textSecondary
          font.pixelSize: theme.textSize
          text: root.appCatalog.results.length + " results"
        }
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 34
        color: theme.trackColor
        border.color: theme.trackBorder
        border.width: 1

        TextInput {
          id: searchInput
          anchors.fill: parent
          anchors.leftMargin: 30
          anchors.rightMargin: 8
          color: theme.textPrimary
          font.pixelSize: theme.textSizeLarge
          selectByMouse: true
          selectionColor: theme.accentDeep
          selectedTextColor: theme.textOnActive
          verticalAlignment: TextInput.AlignVCenter

          onTextChanged: root.scheduleSearch()

          Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
              root.close()
              event.accepted = true
            } else if (event.key === Qt.Key_Down) {
              root.moveSelection(1)
              event.accepted = true
            } else if (event.key === Qt.Key_Up) {
              root.moveSelection(-1)
              event.accepted = true
            } else if (event.key === Qt.Key_PageDown) {
              root.movePage(1)
              event.accepted = true
            } else if (event.key === Qt.Key_PageUp) {
              root.movePage(-1)
              event.accepted = true
            } else if (event.key === Qt.Key_Home) {
              root.selectedIndex = 0
              appList.ensureSelectedVisible()
              event.accepted = true
            } else if (event.key === Qt.Key_End) {
              root.selectedIndex = Math.max(0, root.appCatalog.results.length - 1)
              appList.ensureSelectedVisible()
              event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.activateSelected()
              event.accepted = true
            }
          }
        }

        IconImage {
          anchors.left: parent.left
          anchors.leftMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          asynchronous: true
          width: 16
          height: 16
          source: Quickshell.iconPath("edit-find", "application-x-executable")
        }

        Text {
          anchors.left: parent.left
          anchors.leftMargin: 30
          anchors.verticalCenter: parent.verticalCenter
          color: theme.textMuted
          font.pixelSize: theme.textSizeLarge
          text: "Search programs..."
          visible: searchInput.text === ""
        }
      }

      Row {
        Layout.fillWidth: true
        height: 26
        spacing: 4

        Repeater {
          model: root.appCatalog.categories

          delegate: ButtonFrame {
            id: categoryButton
            required property string modelData
            required property int index
            width: categoryLabel.implicitWidth + 16
            height: 24
            checked: modelData === root.selectedCategory
            onClicked: root.selectCategory(modelData)

            Text {
              id: categoryLabel
              anchors.centerIn: parent
              color: categoryButton.checked ? theme.textOnActive : theme.textSecondary
              font.bold: categoryButton.checked
              font.pixelSize: theme.textSize
              text: modelData
            }
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: theme.surfaceBorder
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 10

        ColumnLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 5

          Text {
            color: theme.textSecondary
            font.bold: true
            font.pixelSize: theme.textSize
            text: root.selectedCategory
          }

          AppList {
            id: appList
            Layout.fillWidth: true
            Layout.fillHeight: true
            catalog: root.appCatalog
            selectedIndex: root.selectedIndex
            tooltip: tooltip
            onActivated: function (index) {
              root.selectedIndex = index
              root.activateSelected()
            }
            onHovered: root.selectedIndex = index
          }
        }

        Rectangle {
          Layout.fillHeight: true
          width: 1
          color: theme.surfaceBorder
        }

        ColumnLayout {
          Layout.preferredWidth: 150
          Layout.fillHeight: true
          spacing: 5

          Text {
            color: theme.textSecondary
            font.bold: true
            font.pixelSize: theme.textSize
            text: "Places"
          }

          Repeater {
            model: root.places

            delegate: ButtonFrame {
              required property var modelData
              Layout.fillWidth: true
              Layout.preferredHeight: 32
              onClicked: root.openPlace(modelData)

              content: Row {
                anchors.fill: parent
                anchors.leftMargin: 6
                spacing: 6

                IconImage {
                  width: 18
                  height: 18
                  anchors.verticalCenter: parent.verticalCenter
                  asynchronous: true
                  source: Quickshell.iconPath(modelData.icon, "folder")
                }

                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  width: parent.width - 24
                  color: theme.textSecondary
                  elide: Text.ElideRight
                  font.pixelSize: theme.textSize
                  text: modelData.name
                }
              }
            }
          }
        }
      }
    }
  }

  Tooltip {
    id: tooltip
    panelWindow: root
  }
}
