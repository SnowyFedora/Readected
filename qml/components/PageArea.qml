import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import "../themes"

Rectangle {
    id: root
    color: ThemeManager.pageBg

    property int currentPage: 0
    property int pageCount: 0
    property real zoomFactor: 1.2
    property bool documentReady: false
    property bool continuous: true
    property bool invert: false
    property string emptyHint: ""
    property string emptyHint2: ""
    property bool editMode: false
    property var notes: []
    property var bookmarkPages: []

    property real pageWpt: 595
    property real pageHpt: 842
    readonly property real pagePixelW: pageWpt * zoomFactor
    readonly property real pagePixelH: pageHpt * zoomFactor
    readonly property real pageGap: continuous ? 24 : 0
    readonly property real pageStride: pagePixelH + pageGap

    signal pageChanged(int page)
    signal noteAddRequested(int page, real nx, real ny)

    ListView {
        id: listView
        anchors.fill: parent
        visible: root.documentReady && root.continuous
        clip: true
        model: root.documentReady && root.continuous ? root.pageCount : 0
        spacing: root.pageGap
        cacheBuffer: Math.round(root.pagePixelH * 1.5)
        reuseItems: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            contentItem: Rectangle { implicitWidth: 3; radius: 1.5; color: ThemeManager.border }
        }

        delegate: Item {
            width: listView.width
            height: root.pagePixelH
            Rectangle {
                id: pageRect
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(root.pagePixelW, parent.width - 48)
                height: root.pagePixelH
                color: "#ffffff"
                border.color: ThemeManager.border
                border.width: 1

                Image {
                    id: img
                    anchors.fill: parent
                    source: "image://pdf/" + index + "_" + root.zoomFactor.toFixed(2)
                    asynchronous: true
                    cache: false
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: root.pagePixelW
                    sourceSize.height: root.pagePixelH
                }
                Rectangle {
                    anchors.fill: parent
                    visible: root.invert
                    color: "#c4a574"
                    opacity: 0.25
                }
                Rectangle {
                    visible: root.bookmarkPages.indexOf(index) >= 0
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    width: 18; height: 28
                    color: ThemeManager.primary
                    radius: 2
                    Text {
                        anchors.centerIn: parent
                        text: "B"
                        color: ThemeManager.onPrimary
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
                Repeater {
                    model: root.notes
                    delegate: Rectangle {
                        visible: modelData.page === index
                        x: (modelData.x || 0) * pageRect.width - 8
                        y: (modelData.y || 0) * pageRect.height - 8
                        width: 16; height: 16; radius: 8
                        color: ThemeManager.accent
                        border.color: "#ffffff"; border.width: 1
                        z: 5
                        ToolTip.visible: nHover.containsMouse
                        ToolTip.text: modelData.text || ""
                        ToolTip.delay: 200
                        MouseArea { id: nHover; anchors.fill: parent; hoverEnabled: true }
                    }
                }
                BusyIndicator {
                    anchors.centerIn: parent
                    running: img.status === Image.Loading
                    visible: running
                    width: 24; height: 24
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: root.editMode
                    cursorShape: root.editMode ? Qt.CrossCursor : Qt.ArrowCursor
                    onClicked: (mouse) => {
                        root.noteAddRequested(index, mouse.x / pageRect.width, mouse.y / pageRect.height)
                    }
                }
            }
        }

        onContentYChanged: syncPage()
        onMovementEnded: syncPage()
        function syncPage() {
            if (root.pageStride <= 0) return
            const idx = Math.max(0, Math.min(root.pageCount - 1, Math.round(contentY / root.pageStride)))
            if (idx !== root.currentPage) {
                root.currentPage = idx
                root.pageChanged(idx)
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: root.documentReady && !root.continuous
        Rectangle {
            id: singlePage
            anchors.centerIn: parent
            width: Math.min(root.pagePixelW, parent.width - 48)
            height: Math.min(root.pagePixelH, parent.height - 32)
            color: "#ffffff"
            border.color: ThemeManager.border
            Image {
                anchors.fill: parent
                source: root.documentReady ? ("image://pdf/" + root.currentPage + "_" + root.zoomFactor.toFixed(2)) : ""
                asynchronous: true
                cache: false
                smooth: true
                fillMode: Image.PreserveAspectFit
            }
            Rectangle {
                anchors.fill: parent
                visible: root.invert
                color: "#c4a574"
                opacity: 0.25
            }
            Rectangle {
                visible: root.bookmarkPages.indexOf(root.currentPage) >= 0
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 8
                width: 18; height: 28
                color: ThemeManager.primary
                radius: 2
                Text {
                    anchors.centerIn: parent
                    text: "B"
                    color: ThemeManager.onPrimary
                    font.pixelSize: 10
                    font.bold: true
                }
            }
            Repeater {
                model: root.notes
                delegate: Rectangle {
                    visible: modelData.page === root.currentPage
                    x: (modelData.x || 0) * singlePage.width - 8
                    y: (modelData.y || 0) * singlePage.height - 8
                    width: 16; height: 16; radius: 8
                    color: ThemeManager.accent
                    z: 5
                    ToolTip.visible: snHover.containsMouse
                    ToolTip.text: modelData.text || ""
                    MouseArea { id: snHover; anchors.fill: parent; hoverEnabled: true }
                }
            }
            MouseArea {
                anchors.fill: parent
                enabled: root.editMode
                cursorShape: root.editMode ? Qt.CrossCursor : Qt.ArrowCursor
                onClicked: (mouse) => {
                    root.noteAddRequested(root.currentPage, mouse.x / singlePage.width, mouse.y / singlePage.height)
                }
            }
        }
    }

    Item { visible: false }

    WheelHandler {
        acceptedModifiers: Qt.ControlModifier
        onWheel: (event) => {
            if (event.angleDelta.y > 0) root.zoomIn()
            else root.zoomOut()
            event.accepted = true
        }
    }

    onZoomFactorChanged: {
        if (continuous && listView.count > 0) {
            const y = listView.contentY
            const m = listView.model
            listView.model = 0
            listView.model = m
            listView.contentY = y
        }
    }

    function goTo(page) { goToPage(page) }
    function goToPage(page) {
        if (!documentReady || page < 0 || page >= pageCount) return
        currentPage = page
        pageChanged(page)
        if (continuous) listView.positionViewAtIndex(page, ListView.Beginning)
    }
    function zoomIn()  { zoomFactor = Math.min(2.5, +(zoomFactor + 0.1).toFixed(2)) }
    function zoomOut() { zoomFactor = Math.max(0.4, +(zoomFactor - 0.1).toFixed(2)) }
    function resetZoom() { zoomFactor = 1.2 }
    function fitToWidth() {
        if (width > 80) zoomFactor = +((width - 56) / pageWpt).toFixed(2)
    }
    function fitToPage() {
        if (width > 80 && height > 80)
            zoomFactor = +(Math.min((width - 56) / pageWpt, (height - 48) / pageHpt)).toFixed(2)
    }
    function fitWidth() { fitToWidth() }
    function fitPage() { fitToPage() }
}
