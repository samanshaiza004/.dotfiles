import QtQuick 2.15

Item {
    id: root

    property alias text: input.text
    property int echoMode: TextInput.Password
    property string placeholderText: ""
    property Item tabTarget
    property Item backTabTarget
    signal accepted()

    implicitHeight: 38

    Surface {
        anchors.fill: parent
        topColor: "#17191e"
        bottomColor: "#0d0f13"
        borderColor: input.activeFocus ? "#9cb7db" : "#d90a0b0e"
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        verticalAlignment: TextInput.AlignVCenter
        color: "#e9e6df"
        selectionColor: "#42536b"
        selectedTextColor: "#f3f6fa"
        font.pixelSize: 12
        echoMode: root.echoMode
        clip: true
        selectByMouse: true
        passwordCharacter: "*"
        KeyNavigation.tab: root.tabTarget
        KeyNavigation.backtab: root.backTabTarget

        Keys.onReturnPressed: root.accepted()
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.placeholderText
        color: "#8a857b"
        font.pixelSize: 12
        visible: input.text.length === 0
    }

    function focusField() {
        input.forceActiveFocus()
    }
}
