import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: root
    color: "#000000"

    // ── Panel central ─────────────────────────────────────
    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: 420
        height: 280
        color: "#000000"
        border.color: "#9b59d0"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 20

            // Hora
            Text {
                id: timeText
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#9b59d0"
                font.family: "Terminess Nerd Font"
                font.pixelSize: 72
                font.bold: true
                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: timeText.text = Qt.formatTime(new Date(), "HH:mm")
                }
                Component.onCompleted: text = Qt.formatTime(new Date(), "HH:mm")
            }

            // Fecha
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#555555"
                font.family: "Terminess Nerd Font"
                font.pixelSize: 12
                text: Qt.formatDate(new Date(), "ddd dd MMM yyyy")
            }

            // Separador
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "├"; color: "#9b59d0"; font.family: "Terminess Nerd Font"; font.pixelSize: 13 }
                Text { text: "──────────────────────────────────"; color: "#1a1a1a"; font.family: "Terminess Nerd Font"; font.pixelSize: 13 }
                Text { text: "┤"; color: "#9b59d0"; font.family: "Terminess Nerd Font"; font.pixelSize: 13 }
            }

            // Input contraseña
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 0

                Text {
                    text: "passwd > "
                    color: "#9b59d0"
                    font.family: "Terminess Nerd Font"
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 200; height: 22
                    color: "transparent"
                    border.color: passwordField.focus ? "#9b59d0" : "#222222"
                    border.width: 1

                    TextInput {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 4
                        color: "#c0c0c0"
                        font.family: "Terminess Nerd Font"
                        font.pixelSize: 13
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        focus: true
                        Keys.onReturnPressed: sddm.login(userModel.lastUser, text, sessionModel.lastIndex)
                        Keys.onEnterPressed:  sddm.login(userModel.lastUser, text, sessionModel.lastIndex)
                    }
                }
            }

            // Estado
            Text {
                id: statusMsg
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#333333"
                font.family: "Terminess Nerd Font"
                font.pixelSize: 11
                text: "[ ENTER ] confirmar"
            }
        }
    }

    // ── Info esquina superior izquierda ───────────────────
    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 24
        spacing: 4

        Text {
            text: "trafalgar@Monster"
            color: "#333333"
            font.family: "Terminess Nerd Font"
            font.pixelSize: 11
        }
        Text {
            text: "Arch Linux x86_64"
            color: "#222222"
            font.family: "Terminess Nerd Font"
            font.pixelSize: 11
        }
    }

    // ── Apagado esquina inferior derecha ──────────────────
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 24
        width: 72; height: 24
        color: "transparent"
        border.color: "#222222"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "[ ⏻ off ]"
            color: "#444444"
            font.family: "Terminess Nerd Font"
            font.pixelSize: 11
        }

        MouseArea {
            anchors.fill: parent
            onClicked: sddm.powerOff()
        }
    }

    // ── Conexión SDDM ─────────────────────────────────────
    Connections {
        target: sddm
        onLoginFailed: {
            statusMsg.color = "#ff3355"
            statusMsg.text = "[ ERR ] contraseña incorrecta"
            passwordField.text = ""
            passwordField.focus = true
            errorTimer.restart()
        }
    }

    Timer {
        id: errorTimer
        interval: 3000
        onTriggered: {
            statusMsg.color = "#333333"
            statusMsg.text = "[ ENTER ] confirmar"
        }
    }
}
