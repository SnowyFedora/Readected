import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../themes"

Dialog {
    id: dlg
    modal: true
    anchors.centerIn: parent
    title: "Readected"
    standardButtons: Dialog.Ok
    Material.background: ThemeManager.surface
    Material.foreground: ThemeManager.text
    Material.accent: ThemeManager.primary

    ColumnLayout {
        spacing: 12
        Label {
            text: "PDF Reader for the Proletariat"
            color: ThemeManager.textDim
            font.pixelSize: 13
        }
        Label {
            text: "Qt 6 · Material · Poppler\nVersion " + (typeof appVersion !== "undefined" ? appVersion : "1.3.0") + " · GPLv3\n\n14 themes · qt6ct · EN/RU"
            color: ThemeManager.text
            font.pixelSize: 13
            lineHeight: 1.3
        }
    }
}
