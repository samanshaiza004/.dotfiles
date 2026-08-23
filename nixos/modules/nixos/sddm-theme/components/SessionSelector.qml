import QtQuick 2.15

Item {
    id: root

    property var model
    property int currentIndex: model && model.lastIndex >= 0 ? model.lastIndex : 0
    property bool expanded: false
    readonly property string selectedName: list.currentItem ? list.currentItem.sessionName : "Mango"

    implicitHeight: 34
    z: expanded ? 20 : 1
    focus: true

    Surface {
        anchors.fill: parent
        topColor: root.expanded ? "#5b6f8e" : "#3c3f47"
        bottomColor: root.expanded ? "#30445f" : "#202227"
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: arrow.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.selectedName || "Mango"
        color: "#c9c4ba"
        font.pixelSize: 11
        elide: Text.ElideRight
    }

    Text {
        id: arrow
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: root.expanded ? "▲" : "▼"
        color: "#9cb7db"
        font.pixelSize: 8
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.model && root.model.count > 1
        onClicked: {
            root.forceActiveFocus()
            root.expanded = !root.expanded
        }
    }

    ListView {
        id: list
        y: root.height + 4
        width: root.width
        height: Math.min(root.model ? root.model.count * 34 : 0, 170)
        model: root.model
        currentIndex: root.currentIndex
        visible: root.expanded && root.model && root.model.count > 1
        clip: true
        delegate: Item {
            width: list.width
            height: 34
            property string sessionName: model.name

            Surface {
                anchors.fill: parent
                topColor: mouse.containsMouse ? "#5b6f8e" : "#33363e"
                bottomColor: mouse.containsMouse ? "#30445f" : "#1b1d22"
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: parent.sessionName
                color: "#e9e6df"
                font.pixelSize: 11
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    root.currentIndex = index
                    root.expanded = false
                }
            }
        }
    }
}
