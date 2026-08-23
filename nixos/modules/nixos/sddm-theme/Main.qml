import QtQuick 2.15

import "components"

Rectangle {
    id: root

    color: "#08090c"
    width: 1920
    height: 1080

    property bool authenticating: false
    property string statusMessage: ""
    property color urgentColor: "#c05b3c"

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#252a34" }
        GradientStop { position: 0.38; color: "#101319" }
        GradientStop { position: 1.0; color: "#050506" }
    }

    Rectangle {
        anchors.fill: parent
        color: "#72050609"
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: "#20ffffff"
    }

    Surface {
        id: loginCard
        width: 400
        height: 438
        anchors.centerIn: parent
        visible: primaryScreen
        topColor: "#4a4d56"
        bottomColor: "#121419"

        Column {
            id: content
            anchors.fill: parent
            anchors.margins: 26
            spacing: 12

            Text {
                width: parent.width
                text: "WELCOME BACK"
                color: "#9cb7db"
                font.pixelSize: 10
                font.letterSpacing: 1.4
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                width: parent.width
                height: 86

                Rectangle {
                    id: avatarFallback
                    anchors.centerIn: parent
                    width: 76
                    height: 76
                    radius: 38
                    color: "#2b2e35"
                    border.width: 1
                    border.color: "#6b7483"

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 16
                        width: 20
                        height: 20
                        radius: 10
                        color: "#b8c1ce"
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 40
                        width: 38
                        height: 22
                        radius: 11
                        color: "#b8c1ce"
                    }
                }

                Image {
                    id: avatar
                    anchors.centerIn: parent
                    width: 76
                    height: 76
                    source: userSelector.selectedIcon
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    visible: status === Image.Ready
                }
            }

            Text {
                width: parent.width
                text: userSelector.selectedName || "User"
                color: "#e9e6df"
                font.pixelSize: 19
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            UserSelector {
                id: userSelector
                width: parent.width
                model: userModel
                currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                KeyNavigation.tab: passwordField
            }

            Text {
                text: "Password"
                color: "#b8b3a9"
                font.pixelSize: 10
            }

            LoginField {
                id: passwordField
                width: parent.width
                placeholderText: "Enter your password"
                backTabTarget: userSelector
                tabTarget: sessionSelector
                onAccepted: root.tryLogin()
            }

            Text {
                width: parent.width
                height: 18
                text: root.statusMessage
                color: root.urgentColor
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
                visible: text.length > 0
            }

            Row {
                width: parent.width
                height: 34
                spacing: 8

                SessionSelector {
                    id: sessionSelector
                    width: parent.width - loginButton.width - parent.spacing
                    model: sessionModel
                    currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
                }

                ButtonFrame {
                    id: loginButton
                    width: 104
                    text: root.authenticating ? "Logging In..." : "Log In"
                    busy: root.authenticating
                    KeyNavigation.backtab: sessionSelector
                    KeyNavigation.tab: powerOffButton.visible ? powerOffButton : rebootButton
                    onClicked: root.tryLogin()
                }
            }

            Row {
                width: parent.width
                height: 30
                spacing: 8

                ButtonFrame {
                    id: powerOffButton
                    width: 104
                    implicitHeight: 30
                    text: "Power Off"
                    visible: sddm.canPowerOff
                    KeyNavigation.backtab: loginButton
                    KeyNavigation.tab: rebootButton
                    onClicked: sddm.powerOff()
                }

                ButtonFrame {
                    id: rebootButton
                    width: 104
                    implicitHeight: 30
                    text: "Reboot"
                    visible: sddm.canReboot
                    KeyNavigation.backtab: powerOffButton.visible ? powerOffButton : loginButton
                    KeyNavigation.tab: userSelector
                    onClicked: sddm.reboot()
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        text: sddm.hostName + "  |  Mango Wayland"
        color: "#706d68"
        font.pixelSize: 10
    }

    function tryLogin() {
        if (root.authenticating || passwordField.text.length === 0)
            return

        root.authenticating = true
        root.statusMessage = ""
        sddm.login(userSelector.selectedName, passwordField.text, sessionSelector.currentIndex)
    }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            root.authenticating = false
        }

        function onLoginFailed() {
            root.authenticating = false
            root.statusMessage = "Authentication failed"
            passwordField.text = ""
            passwordField.focusField()
        }

        function onInformationMessage(message) {
            root.authenticating = false
            root.statusMessage = message
        }
    }

    Component.onCompleted: {
        if (primaryScreen)
            passwordField.focusField()
    }
}
