import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "../themes"

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: false
    Layout.preferredWidth: visible ? panelWidth : 0
    Layout.minimumWidth: visible ? minWidth : 0
    Layout.maximumWidth: visible ? maxWidth : 0
    clip: true

    property real panelWidth: 260
    property real minWidth: 140
    property real maxWidth: 720
    property string outlineTitle: "Outline"
    property string bookmarksTitle: "Bookmarks"
    property string emptyOutline: "No outline"
    property string emptyBookmarks: "No bookmarks"
    property string addBookmarkLabel: "Add"
    property var outline: []
    property var userBookmarks: []
    property int panelTab: 0
    property int currentPage: 0

    signal pageRequested(int page)
    signal widthEdited(real w)
    signal addBookmarkRequested()
    signal removeBookmarkRequested(string id)

    property bool resizing: false

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

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                spacing: 0
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Rectangle {
                        anchors.fill: parent
                        color: root.panelTab === 0 ? ThemeManager.surface2 : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: root.outlineTitle
                            color: root.panelTab === 0 ? ThemeManager.primary : ThemeManager.textDim
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.panelTab = 0
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Rectangle {
                        anchors.fill: parent
                        color: root.panelTab === 1 ? ThemeManager.surface2 : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: root.bookmarksTitle
                            color: root.panelTab === 1 ? ThemeManager.primary : ThemeManager.textDim
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.panelTab = 1
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: ThemeManager.border }

            ListView {
                id: outlineList
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.panelTab === 0
                clip: true
                model: root.outline
                spacing: 0
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle { implicitWidth: 3; radius: 1.5; color: ThemeManager.border }
                }
                delegate: Item {
                    width: outlineList.width
                    height: 32
                    property bool hovered: oMa.containsMouse
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
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
                    }
                    MouseArea {
                        id: oMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (modelData.page >= 0) root.pageRequested(modelData.page)
                    }
                }
            }
            Text {
                visible: root.panelTab === 0 && root.outline.length === 0
                Layout.fillWidth: true
                Layout.margins: 20
                text: root.emptyOutline
                color: ThemeManager.textDim
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            RowLayout {
                visible: root.panelTab === 1
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                Layout.leftMargin: 10
                Layout.rightMargin: 8
                Text {
                    text: root.bookmarksTitle
                    color: ThemeManager.textDim
                    font.pixelSize: 11
                    Layout.fillWidth: true
                }
                Rectangle {
                    width: 56; height: 24
                    radius: 4
                    color: addMa.containsMouse ? ThemeManager.primaryHover : ThemeManager.primary
                    Text {
                        anchors.centerIn: parent
                        text: root.addBookmarkLabel
                        color: ThemeManager.onPrimary
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        id: addMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.addBookmarkRequested()
                    }
                }
            }

            ListView {
                id: bmList
                visible: root.panelTab === 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.userBookmarks
                spacing: 2
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle { implicitWidth: 3; radius: 1.5; color: ThemeManager.border }
                }
                delegate: Item {
                    width: bmList.width
                    height: 40
                    property bool hovered: bmMa.containsMouse
                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        radius: 4
                        color: parent.hovered ? ThemeManager.surface2 : "transparent"
                    }
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: delBtn.left
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Text {
                            width: parent.width
                            text: modelData.label || ("Page " + ((modelData.page || 0) + 1))
                            color: ThemeManager.text
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                        Text {
                            text: "p. " + ((modelData.page || 0) + 1)
                            color: ThemeManager.textDim
                            font.pixelSize: 10
                            font.family: "monospace"
                        }
                    }
                    Text {
                        id: delBtn
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "x"
                        color: ThemeManager.textDim
                        font.pixelSize: 12
                        visible: parent.hovered
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.removeBookmarkRequested(modelData.id)
                        }
                    }
                    MouseArea {
                        id: bmMa
                        anchors.fill: parent
                        anchors.rightMargin: 28
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (modelData.page >= 0) root.pageRequested(modelData.page)
                    }
                }
            }
            Text {
                visible: root.panelTab === 1 && root.userBookmarks.length === 0
                Layout.fillWidth: true
                Layout.margins: 20
                text: root.emptyBookmarks
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
                const w = Math.round(Math.max(root.minWidth, Math.min(root.maxWidth, startW + (x - startX))))
                if (w !== root.panelWidth) root.panelWidth = w
            }
            onReleased: { root.resizing = false; root.widthEdited(root.panelWidth) }
            onCanceled: root.resizing = false
        }
    }
}
