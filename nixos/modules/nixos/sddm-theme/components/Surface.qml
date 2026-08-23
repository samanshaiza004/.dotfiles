import QtQuick 2.15

Rectangle {
    id: root

    property color topColor: "#4a4d56"
    property color bottomColor: "#17191e"
    property color borderColor: "#d92f3138"
    property color highlightColor: "#42ffffff"

    radius: 6
    border.width: 1
    border.color: root.borderColor

    gradient: Gradient {
        GradientStop { position: 0.0; color: root.topColor }
        GradientStop { position: 0.08; color: Qt.rgba(root.topColor.r, root.topColor.g, root.topColor.b, 0.94) }
        GradientStop { position: 1.0; color: root.bottomColor }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: 1
        color: root.highlightColor
    }
}
