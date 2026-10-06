import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../themes"

Item {
    id: root
    // Layout: preferred width is driven by panelWidth, NOT by window size
    Layout.fillHeight: true
    Layout.fillWidth: false
    Layout.preferredWidth: visible ? panelWidth : 0
    Layout.minimumWidth: visible ? minWidth : 0
    Layout.maximumWidth: visible ? maxWidth : 0
    clip: true

    property real panelWidth: 260
    property real minWidth: 140
    property real maxWidth: 720
    property string title: "Outline"
    property string emptyText: "No outline"
    property var bookmarks: []

    signal pageRequested(int page)
    signal widthEdited(real w)

    property bool resizing: false

    // Only animate open/close, never fight the drag
    Behavior on Layout.preferredWidth {
        enabled: !root.resizing && root.visible
        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
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
                Layout.preferredHeight: 36
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.title
                    color: ThemeManager.textDim
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.letterSpacing: 0.4
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: ThemeManager.border
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.bookmarks
                spacing: 0
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle {
                        implicitWidth: 3
                        radius: 1.5
                        color: ThemeManager.border
                    }
                }

                delegate: Item {
                    width: list.width
                    height: 32
                    property bool hovered: delMa.containsMouse

                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        anchors.topMargin: 1
                        anchors.bottomMargin: 1
                        radius: 4
                        color: parent.hovered ? ThemeManager.surface2 : "transparent"
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12 + (modelData.level ? (modelData.level - 1) * 10 : 0)
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.title || ""
                        color: ThemeManager.text
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                    }
                    MouseArea {
                        id: delMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.page >= 0)
                                root.pageRequested(modelData.page)
                        }
                    }
                }
            }

            Text {
                visible: root.bookmarks.length === 0
                Layout.fillWidth: true
                Layout.margins: 20
                text: root.emptyText
                color: ThemeManager.textDim
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
        }
    }

    // Drag handle on the right edge — width independent of window
    Rectangle {
        id: handle
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 3
        z: 10
        color: handleMa.containsMouse || handleMa.pressed ? ThemeManager.primary : ThemeManager.border
        Behavior on color { ColorAnimation { duration: 80 } }

        MouseArea {
            id: handleMa
            anchors.fill: parent
            anchors.leftMargin: -6
            anchors.rightMargin: -6
            cursorShape: Qt.SizeHorCursor
            hoverEnabled: true
            preventStealing: true
            acceptedButtons: Qt.LeftButton

            property real startX: 0
            property real startW: 0

            onPressed: (mouse) => {
                root.resizing = true
                startX = mapToItem(root.parent, mouse.x, mouse.y).x
                startW = root.panelWidth
            }
            onPositionChanged: (mouse) => {
                if (!pressed) return
                const x = mapToItem(root.parent, mouse.x, mouse.y).x
                const delta = x - startX
                // Clamp only by min/max panel limits — not by window size
                const w = Math.round(Math.max(root.minWidth, Math.min(root.maxWidth, startW + delta)))
                if (w !== root.panelWidth)
                    root.panelWidth = w
            }
            onReleased: {
                root.resizing = false
                root.widthEdited(root.panelWidth)
            }
            onCanceled: {
                root.resizing = false
            }
        }
    }
}
