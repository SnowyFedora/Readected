import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCore
import "components"
import "themes"

ApplicationWindow {
    id: root
    visible: true
    width: 1320
    height: 860
    minimumWidth: 960
    minimumHeight: 640
    title: pdfDocument.ready ? (pdfDocument.title + " \u2014 Readected") : "Readected"
    color: ThemeManager.bg
    font.pixelSize: 13

    Material.theme: ThemeManager.isDark ? Material.Dark : Material.Light
    Material.accent: ThemeManager.primary
    Material.primary: ThemeManager.primary
    Material.background: ThemeManager.bg
    Material.foreground: ThemeManager.text

    property string lang: "en"
    property bool continuousMode: true
    property bool invertPages: false
    property var recentFiles: []
    property bool sidebarOpen: false

    readonly property var i18n: ({
        en: {
            open: "Open", close: "Close", quit: "Quit",
            contents: "Outline", noBookmarks: "No outline",
            openHint: "Open a document",
            openHint2: "Ctrl+O  \u00b7  drag & drop  \u00b7  or use the button below",
            continuous: "Continuous", single: "Single page",
            invert: "Night mode", search: "Search", theme: "Theme",
            page: "Page", of: "of"
        },
        ru: {
            open: "\u041e\u0442\u043a\u0440\u044b\u0442\u044c", close: "\u0417\u0430\u043a\u0440\u044b\u0442\u044c", quit: "\u0412\u044b\u0445\u043e\u0434",
            contents: "\u041e\u0433\u043b\u0430\u0432\u043b\u0435\u043d\u0438\u0435", noBookmarks: "\u041d\u0435\u0442 \u043e\u0433\u043b\u0430\u0432\u043b\u0435\u043d\u0438\u044f",
            openHint: "\u041e\u0442\u043a\u0440\u043e\u0439\u0442\u0435 \u0434\u043e\u043a\u0443\u043c\u0435\u043d\u0442",
            openHint2: "Ctrl+O  \u00b7  \u043f\u0435\u0440\u0435\u0442\u0430\u0449\u0438\u0442\u0435 \u0444\u0430\u0439\u043b  \u00b7  \u0438\u043b\u0438 \u043a\u043d\u043e\u043f\u043a\u0430 \u043d\u0438\u0436\u0435",
            continuous: "\u041b\u0435\u043d\u0442\u0430", single: "\u041f\u043e\u0441\u0442\u0440\u0430\u043d\u0438\u0447\u043d\u043e",
            invert: "\u041d\u043e\u0447\u043d\u043e\u0439 \u0440\u0435\u0436\u0438\u043c", search: "\u041f\u043e\u0438\u0441\u043a", theme: "\u0422\u0435\u043c\u0430",
            page: "\u0421\u0442\u0440.", of: "\u0438\u0437"
        }
    })
    function tr(k) { return (i18n[lang] && i18n[lang][k]) ? i18n[lang][k] : k }

    Settings {
        id: settings
        property string theme: "graphite"
        property string language: "en"
        property real zoom: 1.15
        property bool continuous: true
        property bool sidebar: false
        property real sidebarWidth: 260
        property bool invert: false
        property string recentJson: "[]"
    }

    Component.onCompleted: {
        ThemeManager.sysWindow = sysWindow
        ThemeManager.sysBase = sysBase
        ThemeManager.sysButton = sysButton
        ThemeManager.sysText = sysText
        ThemeManager.sysHighlight = sysHighlight
        ThemeManager.sysHighlightedText = sysHighlightedText
        ThemeManager.sysMid = sysMid
        ThemeManager.setTheme(settings.theme)
        lang = settings.language
        continuousMode = settings.continuous
        invertPages = settings.invert
        pageArea.zoomFactor = settings.zoom
        sidebarOpen = settings.sidebar
        sidePanel.panelWidth = settings.sidebarWidth
        try { recentFiles = JSON.parse(settings.recentJson) } catch (e) { recentFiles = [] }
    }
    onClosing: {
        settings.theme = ThemeManager.current
        settings.language = lang
        settings.zoom = pageArea.zoomFactor
        settings.continuous = continuousMode
        settings.sidebar = sidebarOpen
        settings.sidebarWidth = sidePanel.panelWidth
        settings.invert = invertPages
        settings.recentJson = JSON.stringify(recentFiles.slice(0, 12))
    }

    function openNative() {
        const path = fileHelper.openPdf()
        if (path && path.length) openPath(path)
    }
    function openPath(path) {
        pdfDocument.source = path
        let list = recentFiles.filter(p => p !== path)
        list.unshift(path)
        recentFiles = list.slice(0, 12)
    }
    function closeDoc() { pdfDocument.source = "" }

    Shortcut { sequences: [StandardKey.Open]; onActivated: openNative() }
    Shortcut { sequences: [StandardKey.Close]; onActivated: closeDoc() }
    Shortcut { sequences: [StandardKey.Quit]; onActivated: Qt.quit() }
    Shortcut { sequences: [StandardKey.Find]; onActivated: searchBar.toggle() }
    Shortcut { sequence: "Ctrl+="; onActivated: pageArea.zoomIn() }
    Shortcut { sequence: "Ctrl+-"; onActivated: pageArea.zoomOut() }
    Shortcut { sequence: "Ctrl+0"; onActivated: pageArea.resetZoom() }
    Shortcut { sequence: "Left";  onActivated: if (pdfDocument.ready) pageArea.goTo(Math.max(0, pageArea.currentPage - 1)) }
    Shortcut { sequence: "Right"; onActivated: if (pdfDocument.ready) pageArea.goTo(Math.min(pdfDocument.pageCount - 1, pageArea.currentPage + 1)) }
    Shortcut { sequence: "Home";  onActivated: if (pdfDocument.ready) pageArea.goTo(0) }
    Shortcut { sequence: "End";   onActivated: if (pdfDocument.ready) pageArea.goTo(pdfDocument.pageCount - 1) }
    Shortcut { sequence: "F11";   onActivated: visibility = visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen }
    Shortcut { sequence: "Ctrl+B"; onActivated: sidebarOpen = !sidebarOpen }
    Shortcut { sequence: "Ctrl+I"; onActivated: invertPages = !invertPages }

    DropArea {
        anchors.fill: parent
        keys: ["text/uri-list"]
        onDropped: (drop) => {
            if (!drop.hasUrls) return
            for (let i = 0; i < drop.urls.length; ++i) {
                const u = drop.urls[i].toString()
                if (u.toLowerCase().endsWith(".pdf")) { openPath(u); break }
            }
        }
        Rectangle {
            anchors.fill: parent
            color: ThemeManager.primary
            opacity: parent.containsDrag ? 0.08 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
    }

    header: Rectangle {
        height: 48
        color: ThemeManager.surface
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 1
            color: ThemeManager.border; opacity: 0.6
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10; anchors.rightMargin: 10
            spacing: 2

            component BarBtn: ToolButton {
                id: b
                implicitWidth: 36; implicitHeight: 36
                property string glyph: ""
                property real glyphSize: 15
                contentItem: Text {
                    text: b.glyph
                    color: ThemeManager.text
                    opacity: b.enabled ? 1 : 0.3
                    font.pixelSize: b.glyphSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 8
                    color: b.hovered && b.enabled ? ThemeManager.surface2 : "transparent"
                }
            }

            BarBtn { glyph: "\u2630"; onClicked: sidebarOpen = !sidebarOpen; ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("contents") + "  (Ctrl+B)" }
            BarBtn { glyph: "\u25a2"; glyphSize: 14; onClicked: openNative(); ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("open") + "  (Ctrl+O)" }
            BarBtn { glyph: "\u00d7"; glyphSize: 18; enabled: pdfDocument.ready; onClicked: closeDoc() }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: ThemeManager.border; opacity: 0.5; Layout.leftMargin: 4; Layout.rightMargin: 4 }

            BarBtn { glyph: "\u2039"; glyphSize: 20; enabled: pdfDocument.ready && pageArea.currentPage > 0; onClicked: pageArea.goTo(pageArea.currentPage - 1) }
            Label {
                text: pdfDocument.ready ? (pageArea.currentPage + 1) + "  /  " + pdfDocument.pageCount : "\u2014"
                color: ThemeManager.textDim; font.pixelSize: 12; font.family: "monospace"
                Layout.preferredWidth: 72; horizontalAlignment: Text.AlignHCenter
            }
            BarBtn { glyph: "\u203a"; glyphSize: 20; enabled: pdfDocument.ready && pageArea.currentPage < pdfDocument.pageCount - 1; onClicked: pageArea.goTo(pageArea.currentPage + 1) }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: ThemeManager.border; opacity: 0.5; Layout.leftMargin: 4; Layout.rightMargin: 4 }

            BarBtn { glyph: "\u2212"; enabled: pdfDocument.ready; onClicked: pageArea.zoomOut() }
            Label {
                text: Math.round(pageArea.zoomFactor * 100) + "%"
                color: ThemeManager.textDim; font.pixelSize: 12; font.family: "monospace"
                Layout.preferredWidth: 44; horizontalAlignment: Text.AlignHCenter
            }
            BarBtn { glyph: "+"; enabled: pdfDocument.ready; onClicked: pageArea.zoomIn() }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: ThemeManager.border; opacity: 0.5; Layout.leftMargin: 4; Layout.rightMargin: 4 }

            BarBtn { glyph: continuousMode ? "\u2261" : "\u25ad"; onClicked: continuousMode = !continuousMode; ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: continuousMode ? tr("continuous") : tr("single") }
            BarBtn { glyph: "\u2315"; onClicked: searchBar.toggle(); ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("search") + "  (Ctrl+F)" }
            BarBtn { glyph: invertPages ? "\u2600" : "\u263e"; glyphSize: 13; onClicked: invertPages = !invertPages; ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("invert") }

            Item { Layout.fillWidth: true }

            BarBtn {
                glyph: "\u25d0"; glyphSize: 14
                onClicked: themeMenu.open()
                ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("theme")
                Menu {
                    id: themeMenu
                    Material.background: ThemeManager.surface
                    Material.foreground: ThemeManager.text
                    width: 200
                    Repeater {
                        model: ThemeManager.themeIds
                        MenuItem {
                            required property string modelData
                            text: ThemeManager.displayName(modelData)
                            font.pixelSize: 13
                            onTriggered: { ThemeManager.setTheme(modelData); settings.theme = modelData }
                            background: Rectangle {
                                implicitHeight: 36
                                color: parent.highlighted ? ThemeManager.surface2 : "transparent"
                                radius: 6
                            }
                        }
                    }
                }
            }
            ToolButton {
                implicitWidth: 40; implicitHeight: 36
                onClicked: { lang = lang === "ru" ? "en" : "ru"; settings.language = lang }
                background: Rectangle { radius: 8; color: parent.hovered ? ThemeManager.surface2 : "transparent" }
                contentItem: Text {
                    text: lang === "ru" ? "RU" : "EN"
                    color: ThemeManager.textDim
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 11; font.weight: Font.DemiBold
                }
            }
            BarBtn { glyph: "i"; glyphSize: 13; onClicked: aboutDialog.open() }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0
        SidePanel {
            id: sidePanel
            visible: sidebarOpen
            Layout.preferredWidth: visible ? panelWidth : 0
            Layout.fillHeight: true
            title: tr("contents")
            emptyText: tr("noBookmarks")
            bookmarks: pdfDocument.bookmarks
            onPageRequested: (p) => pageArea.goTo(p)
            onWidthEdited: (w) => { settings.sidebarWidth = w }
        }
        Rectangle {
            Layout.preferredWidth: sidebarOpen ? 1 : 0
            Layout.fillHeight: true
            color: ThemeManager.border; opacity: 0.5
            visible: sidebarOpen
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            SearchBar {
                id: searchBar
                Layout.fillWidth: true
                placeholder: tr("search")
                findLabel: tr("search")
                onSearchRequested: (text) => {
                    const hits = pdfDocument.search(text)
                    if (hits.length > 0) pageArea.goTo(hits[0].page)
                }
            }
            PageArea {
                id: pageArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                documentReady: pdfDocument.ready
                pageCount: pdfDocument.pageCount
                continuous: continuousMode
                invert: invertPages
                emptyHint: tr("openHint")
                emptyHint2: tr("openHint2")
            }
        }
    }

    RoundButton {
        id: fab
        anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 28
        width: 52; height: 52
        visible: !pdfDocument.ready
        onClicked: openNative()
        background: Rectangle {
            radius: width / 2
            color: fab.hovered ? ThemeManager.primaryHover : ThemeManager.primary
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        contentItem: Text {
            text: "+"
            color: ThemeManager.onPrimary
            font.pixelSize: 22; font.weight: Font.Light
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    footer: Rectangle {
        height: 26
        color: ThemeManager.surface
        Rectangle {
            anchors.top: parent.top; width: parent.width; height: 1
            color: ThemeManager.border; opacity: 0.5
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14; anchors.rightMargin: 14
            Label {
                text: pdfDocument.ready
                      ? (tr("page") + " " + (pageArea.currentPage + 1) + " " + tr("of") + " " + pdfDocument.pageCount
                         + (pdfDocument.title ? "  \u00b7  " + pdfDocument.title : ""))
                      : "Readected"
                color: ThemeManager.textDim; font.pixelSize: 11
                elide: Text.ElideMiddle; Layout.fillWidth: true
            }
            Label {
                text: ThemeManager.displayName(ThemeManager.current) + "  \u00b7  v" + appVersion
                color: ThemeManager.textDim; font.pixelSize: 11
            }
        }
    }

    AboutDialog { id: aboutDialog }
}
