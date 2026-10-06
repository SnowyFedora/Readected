import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../themes"

Pane {
    id: root
    height: visible ? 52 : 0
    visible: false
    padding: 8
    leftPadding: 16
    rightPadding: 12
    Material.background: ThemeManager.surface2
    clip: true

    property string placeholder: "Search"
    property string findLabel: "Find"
    signal searchRequested(string text)
    signal closed()

    Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    RowLayout {
        anchors.fill: parent
        spacing: 8
        TextField {
            id: field
            Layout.fillWidth: true
            placeholderText: root.placeholder
            selectByMouse: true
            onAccepted: root.searchRequested(text)
            Keys.onEscapePressed: root.close()
        }
        Button {
            text: root.findLabel
            Material.background: ThemeManager.primary
            Material.foreground: ThemeManager.onPrimary
            onClicked: root.searchRequested(field.text)
        }
        ToolButton {
            text: "×"
            onClicked: root.close()
        }
    }

    function toggle() { visible ? close() : open() }
    function open() { visible = true; field.forceActiveFocus(); field.selectAll() }
    function close() { visible = false; field.text = ""; closed() }
}
