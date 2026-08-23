import QtQuick 2.15

Item {
    id: root

    property alias text: label.text
    property bool busy: false
    property color normalTop: "#4b4e57"
    property color normalBottom: "#292b31"
    property color activeTop: "#789ac5"
    property color activeBottom: "#3f5d83"
    property color labelColor: "#e9e6df"
    property color focusColor: "#9cb7db"
    signal clicked()

    implicitWidth: 104
    implicitHeight: 34
    focus: true

    Surface {
        anchors.fill: parent
        topColor: mouse.pressed || root.activeFocus ? root.activeTop : mouse.containsMouse ? Qt.lighter(root.normalTop, 1.12) : root.normalTop
        bottomColor: mouse.pressed || root.activeFocus ? root.activeBottom : mouse.containsMouse ? Qt.lighter(root.normalBottom, 1.08) : root.normalBottom
        borderColor: root.activeFocus ? root.focusColor : "#d90a0b0e"
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: root.labelColor
        font.pixelSize: 12
        font.weight: Font.DemiBold
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: 8
        color: "transparent"
        border.width: 1
        border.color: root.focusColor
        visible: root.activeFocus
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            root.forceActiveFocus()
            if (!root.busy)
                root.clicked()
        }
    }

    Keys.onReturnPressed: if (!root.busy) root.clicked()
    Keys.onSpacePressed: if (!root.busy) root.clicked()
}
