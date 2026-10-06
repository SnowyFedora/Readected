import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import "../themes"

Rectangle {
    id: root
    color: ThemeManager.pageBg

    property int currentPage: 0
    property int pageCount: 0
    property real zoomFactor: 1.15
    property bool documentReady: false
    property bool continuous: true
    property bool invert: false
    property string emptyHint: "Open a PDF"
    property string emptyHint2: ""

    property real pageWpt: 595
    property real pageHpt: 842
    readonly property real pagePixelW: pageWpt * zoomFactor
    readonly property real pagePixelH: pageHpt * zoomFactor
    readonly property real pageGap: continuous ? 16 : 0
    readonly property real pageStride: pagePixelH + pageGap

    signal pageChanged(int page)

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

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        delegate: Item {
            width: listView.width
            height: root.pagePixelH
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(root.pagePixelW, parent.width - 48)
                height: root.pagePixelH
                color: "#ffffff"
                radius: 4
                layer.enabled: true
                border.color: ThemeManager.border
                border.width: 1

                Image {
                    id: img
                    anchors.fill: parent
                    anchors.margins: 1
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
                    opacity: 0.28
                    radius: 4
                }
                BusyIndicator {
                    anchors.centerIn: parent
                    running: img.status === Image.Loading
                    visible: running
                    width: 32; height: 32
                }
            }
        }

        onContentYChanged: syncPage()
        onMovementEnded: syncPage()
        function syncPage() {
            if (root.pageStride <= 0) return
            const idx = Math.max(0, Math.min(root.pageCount - 1,
                Math.round(contentY / root.pageStride)))
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
            anchors.centerIn: parent
            width: Math.min(root.pagePixelW, parent.width - 48)
            height: Math.min(root.pagePixelH, parent.height - 32)
            color: "#ffffff"
            radius: 4
            border.color: ThemeManager.border
            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: root.documentReady
                        ? ("image://pdf/" + root.currentPage + "_" + root.zoomFactor.toFixed(2)) : ""
                asynchronous: true
                cache: false
                smooth: true
                fillMode: Image.PreserveAspectFit
            }
            Rectangle {
                anchors.fill: parent
                visible: root.invert
                color: "#c4a574"
                opacity: 0.28
                radius: 4
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: !root.documentReady
        Label {
            text: root.emptyHint
            color: ThemeManager.text
            font.pixelSize: 18
            font.weight: Font.Medium
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            text: root.emptyHint2
            color: ThemeManager.textDim
            font.pixelSize: 13
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

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
    function resetZoom() { zoomFactor = 1.15 }
    function fitToWidth() {
        if (width > 80) zoomFactor = +((width - 64) / pageWpt).toFixed(2)
    }
    function fitToPage() {
        if (width > 80 && height > 80)
            zoomFactor = +(Math.min((width - 64) / pageWpt, (height - 64) / pageHpt)).toFixed(2)
    }
}
