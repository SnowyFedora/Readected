import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../themes"

Item {
    id: root
    width: visible ? panelWidth : 0
    clip: true

    property real panelWidth: 280
    property real minWidth: 180
    property real maxWidth: 520
    property string title: "Outline"
    property string emptyText: "No outline"
    property var bookmarks: []

    signal pageRequested(int page)
    signal widthEdited(real w)

    property bool resizing: false
    Behavior on width {
        enabled: !root.resizing
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    Rectangle {
        id: body
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: Math.max(0, parent.width - 4)
        color: ThemeManager.surface

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 8
                Layout.topMargin: 14
                Layout.bottomMargin: 10
                text: root.title
                font.pixelSize: 12
                font.weight: Font.DemiBold
                font.capitalization: Font.AllUppercase
                color: ThemeManager.textDim
                elide: Text.ElideRight
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.bookmarks
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 8
                }

                delegate: ItemDelegate {
                    id: del
                    width: list.width
                    height: Math.max(40, contentLabel.implicitHeight + 16)
                    leftPadding: 12 + Math.max(0, (modelData.level - 1) * 12)
                    rightPadding: 12
                    hoverEnabled: true

                    ToolTip.visible: hovered && contentLabel.truncated
                    ToolTip.text: modelData.title || ""
                    ToolTip.delay: 500

                    contentItem: Label {
                        id: contentLabel
                        text: modelData.title || ""
                        color: ThemeManager.text
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        width: del.width - del.leftPadding - del.rightPadding
                    }

                    background: Rectangle {
                        color: del.hovered ? ThemeManager.surface2 : "transparent"
                        radius: 4
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                    }

                    onClicked: {
                        if (modelData.page >= 0)
                            root.pageRequested(modelData.page)
                    }
                }
            }

            Label {
                visible: root.bookmarks.length === 0
                Layout.fillWidth: true
                Layout.margins: 24
                text: root.emptyText
                color: ThemeManager.textDim
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }
        }
    }

    Rectangle {
        id: handle
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 4
        color: handleMa.containsMouse || handleMa.pressed
               ? ThemeManager.primary : ThemeManager.border
        opacity: handleMa.containsMouse || handleMa.pressed ? 1 : 0.5
        visible: root.visible

        Behavior on color { ColorAnimation { duration: 100 } }

        MouseArea {
            id: handleMa
            anchors.fill: parent
            anchors.margins: -4
            cursorShape: Qt.SizeHorCursor
            hoverEnabled: true
            preventStealing: true

            property real startX: 0
            property real startW: 0

            onPressed: (mouse) => {
                root.resizing = true
                startX = mapToItem(root.parent, mouse.x, 0).x
                startW = root.panelWidth
            }
            onPositionChanged: (mouse) => {
                if (!pressed) return
                const x = mapToItem(root.parent, mouse.x, 0).x
                const delta = x - startX
                const w = Math.min(root.maxWidth, Math.max(root.minWidth, startW + delta))
                root.panelWidth = w
            }
            onReleased: {
                root.resizing = false
                root.widthEdited(root.panelWidth)
            }
        }
    }
}
