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
    implicitWidth: visible ? panelWidth : 0
    width: visible ? panelWidth : 0
    clip: true

    property real panelWidth: 280
    property real minWidth: 160
    property real maxWidth: 900
    property string outlineTitle: "Outline"
    property string bookmarksTitle: "Bookmarks"
    property string emptyOutline: "No outline"
    property string emptyBookmarks: "No bookmarks"
    property string addBookmarkLabel: "+ Mark"
    property var outline: []
    property var userBookmarks: []
    property int panelTab: 0
    property int currentPage: 0

    signal pageRequested(int page)
    signal widthEdited(real w)
    signal addBookmarkRequested()
    signal removeBookmarkRequested(string id)

    property bool resizing: false

    Rectangle {
        id: body
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: grip.left
        color: ThemeManager.surface

        Rectangle {
            id: tabBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 36
            color: ThemeManager.surface

            Row {
                anchors.fill: parent
                Item {
                    width: parent.width / 2
                    height: parent.height
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 4
                        color: root.panelTab === 0 ? ThemeManager.surface2 : "transparent"
                    }
                    Text {
                        anchors.centerIn: parent
                        text: root.bookmarksTitle
                        color: root.panelTab === 0 ? ThemeManager.primary : ThemeManager.textDim
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.panelTab = 0
                    }
                }
                Item {
                    width: parent.width / 2
                    height: parent.height
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 4
                        color: root.panelTab === 1 ? ThemeManager.surface2 : "transparent"
                    }
                    Text {
                        anchors.centerIn: parent
                        text: root.outlineTitle
                        color: root.panelTab === 1 ? ThemeManager.primary : ThemeManager.textDim
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.panelTab = 1
                    }
                }
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: ThemeManager.border
            }
        }

        Item {
            id: bookmarksPage
            anchors.top: tabBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: root.panelTab === 0

            Rectangle {
                id: addRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 40
                color: "transparent"
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 72; height: 26
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
                anchors.top: addRow.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true
                model: root.userBookmarks
                spacing: 2
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                delegate: Item {
                    width: bmList.width
                    height: 40
                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        radius: 4
                        color: bmMa.containsMouse ? ThemeManager.surface2 : "transparent"
                    }
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: delBm.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Text {
                            width: parent.width
                            text: modelData.label || ("p. " + ((modelData.page || 0) + 1))
                            color: ThemeManager.text
                            font.family: "Noto Sans"
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
                        id: delBm
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u00d7"
                        color: ThemeManager.textDim
                        font.pixelSize: 14
                        visible: bmMa.containsMouse
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
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
                anchors.centerIn: parent
                visible: root.userBookmarks.length === 0
                width: parent.width - 32
                horizontalAlignment: Text.AlignHCenter
                text: root.emptyBookmarks
                color: ThemeManager.textDim
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
        }

        Item {
            id: outlinePage
            anchors.top: tabBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: root.panelTab === 1

            ListView {
                id: outlineList
                anchors.fill: parent
                clip: true
                model: root.outline
                spacing: 0
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                delegate: Item {
                    width: outlineList.width
                    height: 32
                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        radius: 4
                        color: oMa.containsMouse ? ThemeManager.surface2 : "transparent"
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12 + (modelData.level ? (modelData.level - 1) * 10 : 0)
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.title || ""
                        color: ThemeManager.text
                        font.family: "Noto Sans"
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
                anchors.centerIn: parent
                visible: root.outline.length === 0
                width: parent.width - 32
                horizontalAlignment: Text.AlignHCenter
                text: root.emptyOutline
                color: ThemeManager.textDim
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
        }
    }

    Rectangle {
        id: grip
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 5
        z: 20
        color: gripMa.containsMouse || gripMa.pressed ? ThemeManager.primary : ThemeManager.border

        MouseArea {
            id: gripMa
            anchors.fill: parent
            anchors.leftMargin: -10
            anchors.rightMargin: -4
            cursorShape: Qt.SizeHorCursor
            hoverEnabled: true
            preventStealing: true
            acceptedButtons: Qt.LeftButton
            property real startX: 0
            property real startW: 0
            onPressed: function(mouse) {
                root.resizing = true
                startX = mapToItem(root.parent, mouse.x, mouse.y).x
                startW = root.panelWidth
            }
            onPositionChanged: function(mouse) {
                if (!pressed) return
                var x = mapToItem(root.parent, mouse.x, mouse.y).x
                var w = Math.round(Math.max(root.minWidth, Math.min(root.maxWidth, startW + (x - startX))))
                root.panelWidth = w
                root.width = w
                root.Layout.preferredWidth = w
            }
            onReleased: function() {
                root.resizing = false
                root.widthEdited(root.panelWidth)
            }
            onCanceled: function() { root.resizing = false }
        }
    }
}
