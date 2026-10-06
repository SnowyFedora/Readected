import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 520
    height: 560
    minimumWidth: 420
    minimumHeight: 480
    title: "Readected Updater"
    Material.theme: Material.Dark
    Material.accent: "#bb86fc"
    Material.primary: "#bb86fc"
    Material.background: "#121212"
    color: Material.background

    header: ToolBar {
        Material.background: "#1e1e1e"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 8
            Label {
                text: "Readected Updater"
                font.pixelSize: 18
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }
            Label {
                text: "v" + appVersion
                opacity: 0.6
                font.pixelSize: 12
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Pane {
            Layout.fillWidth: true
            Material.elevation: 2
            Material.background: "#1e1e1e"
            padding: 16

            ColumnLayout {
                anchors.fill: parent
                spacing: 8
                Label {
                    text: qsTr("Status")
                    font.pixelSize: 12
                    opacity: 0.6
                    font.capitalization: Font.AllUppercase
                }
                Label {
                    text: updater.status
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    color: updater.updateAvailable ? Material.accent : "#e0e0e0"
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
                RowLayout {
                    Label { text: qsTr("Local:"); opacity: 0.6 }
                    Label { text: updater.localVersion; font.weight: Font.DemiBold }
                    Item { Layout.preferredWidth: 16 }
                    Label { text: qsTr("Remote:"); opacity: 0.6 }
                    Label {
                        text: updater.remoteVersion || "\u2014"
                        font.weight: Font.DemiBold
                    }
                }
            }
        }

        Pane {
            Layout.fillWidth: true
            Material.background: "#1e1e1e"
            padding: 12
            ColumnLayout {
                anchors.fill: parent
                spacing: 4
                Label {
                    text: qsTr("Source directory")
                    font.pixelSize: 12
                    opacity: 0.6
                }
                TextField {
                    Layout.fillWidth: true
                    text: updater.sourceDir
                    onEditingFinished: updater.sourceDir = text
                    selectByMouse: true
                }
            }
        }

        ProgressBar {
            Layout.fillWidth: true
            from: 0
            to: 100
            value: updater.progress
            visible: updater.busy || updater.progress > 0
            indeterminate: updater.busy && updater.progress < 5
        }

        Pane {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Material.background: "#0d0d0d"
            padding: 8
            Flickable {
                anchors.fill: parent
                contentHeight: logText.height
                clip: true
                Text {
                    id: logText
                    width: parent.width
                    text: updater.log || qsTr("Log will appear here\u2026")
                    color: "#b0b0b0"
                    font.family: "monospace"
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: qsTr("Check")
                enabled: !updater.busy
                Material.background: "#2c2c2c"
                onClicked: updater.checkForUpdates()
                Layout.fillWidth: true
            }
            Button {
                text: qsTr("Install update")
                enabled: !updater.busy && updater.updateAvailable
                Material.background: Material.accent
                Material.foreground: "#000000"
                font.bold: true
                onClicked: updater.installUpdate()
                Layout.fillWidth: true
            }
        }

        Button {
            text: qsTr("Open source folder")
            flat: true
            Layout.alignment: Qt.AlignHCenter
            onClicked: updater.openSourceFolder()
        }

        Label {
            text: qsTr("Install may request your password (sudo) in the process.")
            font.pixelSize: 11
            opacity: 0.5
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
