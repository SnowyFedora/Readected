import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../themes"

Rectangle {
    id: root
    height: visible ? 44 : 0
    visible: false
    color: ThemeManager.surface2
    clip: true

    property string placeholder: "Search"
    property string findLabel: "Find"
    signal searchRequested(string text)
    signal closed()

    Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width; height: 1
        color: ThemeManager.border
        opacity: 0.5
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 10
        spacing: 8

        Text {
            text: "\u2315"
            color: ThemeManager.textDim
            font.pixelSize: 14
        }
        TextField {
            id: field
            Layout.fillWidth: true
            placeholderText: root.placeholder
            selectByMouse: true
            color: ThemeManager.text
            placeholderTextColor: ThemeManager.textDim
            background: Item {}
            font.pixelSize: 13
            onAccepted: root.searchRequested(text)
            Keys.onEscapePressed: root.close()
        }
        Button {
            text: root.findLabel
            flat: true
            Material.foreground: ThemeManager.primary
            font.pixelSize: 12
            font.weight: Font.DemiBold
            onClicked: root.searchRequested(field.text)
        }
        ToolButton {
            implicitWidth: 32; implicitHeight: 32
            onClicked: root.close()
            contentItem: Text {
                text: "\u00d7"
                color: ThemeManager.textDim
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 6
                color: parent.hovered ? ThemeManager.surface3 : "transparent"
            }
        }
    }

    function toggle() { visible ? close() : open() }
    function open() { visible = true; field.forceActiveFocus(); field.selectAll() }
    function close() { visible = false; field.text = ""; closed() }
}
