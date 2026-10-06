import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../themes"

Item {
    id: root
    width: visible ? panelWidth : 0
    clip: true

    property real panelWidth: 260
    property real minWidth: 180
    property real maxWidth: 480
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
        anchors.right: handle.left
        color: ThemeManager.surface

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.title
                    color: ThemeManager.textDim
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.capitalization: Font.AllUppercase
                    letterSpacing: 0.8
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: ThemeManager.border
                opacity: 0.5
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.bookmarks
                spacing: 1
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle { implicitWidth: 3; radius: 1.5; color: ThemeManager.border }
                }

                delegate: ItemDelegate {
                    id: del
                    width: list.width
                    height: 34
                    leftPadding: 12 + (modelData.level ? (modelData.level - 1) * 12 : 0)
                    rightPadding: 12

                    contentItem: Text {
                        text: modelData.title || ""
                        color: ThemeManager.text
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        width: del.width - del.leftPadding - del.rightPadding
                    }

                    background: Rectangle {
                        color: del.hovered ? ThemeManager.surface2 : "transparent"
                        radius: 6
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                    }

                    ToolTip.visible: del.hovered && contentItem.truncatedContentWidth > contentItem.width
                    ToolTip.delay: 600
                    ToolTip.text: modelData.title || ""

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
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
        }
    }

    Rectangle {
        id: handle
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 3
        color: handleMa.containsMouse || handleMa.pressed ? ThemeManager.primary : "transparent"
        opacity: handleMa.containsMouse || handleMa.pressed ? 0.7 : 0
        visible: root.visible
        Behavior on opacity { NumberAnimation { duration: 100 } }

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
                const w = Math.min(root.maxWidth, Math.max(root.minWidth, startW + (x - startX)))
                root.panelWidth = w
            }
            onReleased: {
                root.resizing = false
                root.widthEdited(root.panelWidth)
            }
        }
    }
}
