import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../themes"

Dialog {
    id: dlg
    modal: true
    anchors.centerIn: parent
    width: 360
    title: ""
    standardButtons: Dialog.Ok
    Material.background: ThemeManager.surface
    Material.foreground: ThemeManager.text
    Material.accent: ThemeManager.primary
    padding: 24

    background: Rectangle {
        color: ThemeManager.surface
        radius: 12
        border.color: ThemeManager.border
        border.width: 1
    }

    ColumnLayout {
        spacing: 14
        width: parent.width

        Label {
            text: "Readected"
            color: ThemeManager.text
            font.pixelSize: 20
            font.weight: Font.DemiBold
        }
        Label {
            text: "PDF reader"
            color: ThemeManager.textDim
            font.pixelSize: 13
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: ThemeManager.border
            opacity: 0.5
        }
        Label {
            text: "Qt 6  ·  Poppler  ·  Material\nVersion " + (typeof appVersion !== "undefined" ? appVersion : "1.3.0") + "  ·  GPLv3"
            color: ThemeManager.text
            font.pixelSize: 12
            lineHeight: 1.4
        }
        Label {
            text: "15 themes  ·  EN / RU  ·  qt6ct"
            color: ThemeManager.textDim
            font.pixelSize: 12
        }
    }
}
