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
    width: 1280
    height: 840
    minimumWidth: 900
    minimumHeight: 600
    title: pdfDocument.ready ? (pdfDocument.title + " \u2014 Readected") : "Readected"
    color: ThemeManager.bg
    font.pixelSize: 14

    Material.theme: ThemeManager.isDark ? Material.Dark : Material.Light
    Material.accent: ThemeManager.primary
    Material.primary: ThemeManager.primary
    Material.background: ThemeManager.bg
    Material.foreground: ThemeManager.text

    property string lang: "en"
    property bool continuousMode: true
    property bool invertPages: false
    property var recentFiles: []

    readonly property var i18n: ({
        en: { open:"Open", close:"Close", quit:"Quit", prev:"Prev", next:"Next",
              zoomIn:"Zoom in", zoomOut:"Zoom out", fitWidth:"Width", fitPage:"Page",
              search:"Search", theme:"Theme", about:"About", file:"File", view:"View",
              contents:"Outline", noBookmarks:"No outline", openHint:"Open a PDF",
              openHint2:"or drag and drop here", continuous:"Continuous", single:"Single",
              invert:"Night mode", recent:"Recent", clearRecent:"Clear", goTo:"Go to page",
              fullscreen:"Fullscreen", language:"Language", update:"Updater" },
        ru: { open:"\u041e\u0442\u043a\u0440\u044b\u0442\u044c", close:"\u0417\u0430\u043a\u0440\u044b\u0442\u044c", quit:"\u0412\u044b\u0445\u043e\u0434", prev:"\u041d\u0430\u0437\u0430\u0434", next:"\u0414\u0430\u043b\u0435\u0435",
              zoomIn:"\u041a\u0440\u0443\u043f\u043d\u0435\u0435", zoomOut:"\u041c\u0435\u043b\u044c\u0447\u0435", fitWidth:"\u0428\u0438\u0440\u0438\u043d\u0430", fitPage:"\u0421\u0442\u0440\u0430\u043d\u0438\u0446\u0430",
              search:"\u041f\u043e\u0438\u0441\u043a", theme:"\u0422\u0435\u043c\u0430", about:"\u041e \u043f\u0440\u043e\u0433\u0440\u0430\u043c\u043c\u0435", file:"\u0424\u0430\u0439\u043b", view:"\u0412\u0438\u0434",
              contents:"\u041e\u0433\u043b\u0430\u0432\u043b\u0435\u043d\u0438\u0435", noBookmarks:"\u041d\u0435\u0442 \u043e\u0433\u043b\u0430\u0432\u043b\u0435\u043d\u0438\u044f", openHint:"\u041e\u0442\u043a\u0440\u043e\u0439\u0442\u0435 PDF",
              openHint2:"\u0438\u043b\u0438 \u043f\u0435\u0440\u0435\u0442\u0430\u0449\u0438\u0442\u0435 \u0444\u0430\u0439\u043b \u0441\u044e\u0434\u0430", continuous:"\u041b\u0435\u043d\u0442\u0430", single:"\u041f\u043e\u0441\u0442\u0440\u0430\u043d\u0438\u0447\u043d\u043e",
              invert:"\u041d\u043e\u0447\u043d\u043e\u0439 \u0440\u0435\u0436\u0438\u043c", recent:"\u041d\u0435\u0434\u0430\u0432\u043d\u0438\u0435", clearRecent:"\u041e\u0447\u0438\u0441\u0442\u0438\u0442\u044c", goTo:"\u041f\u0435\u0440\u0435\u0439\u0442\u0438",
              fullscreen:"\u041f\u043e\u043b\u043d\u044b\u0439 \u044d\u043a\u0440\u0430\u043d", language:"\u042f\u0437\u044b\u043a", update:"\u041e\u0431\u043d\u043e\u0432\u043b\u0435\u043d\u0438\u0435" }
    })
    function tr(k) { return (i18n[lang] && i18n[lang][k]) ? i18n[lang][k] : k }

    Settings {
        id: settings
        property string theme: "system"
        property string language: "en"
        property real zoom: 1.15
        property bool continuous: true
        property bool sidebar: false
        property real sidebarWidth: 280
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
        sidePanel.visible = settings.sidebar
        sidePanel.panelWidth = settings.sidebarWidth
        try { recentFiles = JSON.parse(settings.recentJson) } catch (e) { recentFiles = [] }
    }
    onClosing: {
        settings.theme = ThemeManager.current
        settings.language = lang
        settings.zoom = pageArea.zoomFactor
        settings.continuous = continuousMode
        settings.sidebar = sidePanel.visible
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
    Shortcut { sequence: "Left"; onActivated: pageArea.goTo(Math.max(0, pageArea.currentPage - 1)) }
    Shortcut { sequence: "Right"; onActivated: pageArea.goTo(Math.min(pdfDocument.pageCount - 1, pageArea.currentPage + 1)) }
    Shortcut { sequence: "F11"; onActivated: visibility = visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen }

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
    }

    menuBar: MenuBar {
        Menu {
            title: tr("file")
            Action { text: tr("open") + "\u2026"; onTriggered: openNative() }
            Menu {
                title: tr("recent"); enabled: recentFiles.length > 0
                Repeater {
                    model: recentFiles
                    MenuItem {
                        required property string modelData
                        text: modelData.split("/").pop()
                        onTriggered: openPath(modelData)
                    }
                }
                MenuSeparator {}
                MenuItem { text: tr("clearRecent"); onTriggered: recentFiles = [] }
            }
            Action { text: tr("close"); onTriggered: closeDoc() }
            MenuSeparator {}
            Action { text: tr("quit"); onTriggered: Qt.quit() }
        }
        Menu {
            title: tr("view")
            Action { text: tr("zoomIn"); onTriggered: pageArea.zoomIn() }
            Action { text: tr("zoomOut"); onTriggered: pageArea.zoomOut() }
            Action { text: tr("fitWidth"); onTriggered: pageArea.fitToWidth() }
            Action { text: tr("fitPage"); onTriggered: pageArea.fitToPage() }
            MenuSeparator {}
            Action { text: tr("continuous"); checkable: true; checked: continuousMode; onTriggered: continuousMode = true }
            Action { text: tr("single"); checkable: true; checked: !continuousMode; onTriggered: continuousMode = false }
            Action { text: tr("invert"); checkable: true; checked: invertPages; onTriggered: invertPages = !invertPages }
            Action { text: tr("contents"); checkable: true; checked: sidePanel.visible; onTriggered: sidePanel.visible = !sidePanel.visible }
        }
        Menu {
            title: tr("theme")
            Repeater {
                model: ThemeManager.themeIds
                MenuItem {
                    required property string modelData
                    text: ThemeManager.displayName(modelData)
                    onTriggered: { ThemeManager.setTheme(modelData); settings.theme = modelData }
                }
            }
        }
        Menu {
            title: tr("language")
            Action { text: "English"; onTriggered: { lang = "en"; settings.language = "en" } }
            Action { text: "\u0420\u0443\u0441\u0441\u043a\u0438\u0439"; onTriggered: { lang = "ru"; settings.language = "ru" } }
        }
        Menu {
            title: tr("about")
            Action { text: "Readected\u2026"; onTriggered: aboutDialog.open() }
        }
    }

    header: ToolBar {
        Material.background: ThemeManager.surface
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8; anchors.rightMargin: 8
            spacing: 2
            ToolButton { text: "\u2630"; onClicked: sidePanel.visible = !sidePanel.visible }
            ToolButton { text: "\uD83D\uDCC2"; onClicked: openNative() }
            ToolButton { text: "\u2715"; enabled: pdfDocument.ready; onClicked: closeDoc() }
            ToolSeparator {}
            ToolButton { text: "\u25C0"; enabled: pdfDocument.ready && pageArea.currentPage > 0; onClicked: pageArea.goTo(pageArea.currentPage - 1) }
            Label {
                text: pdfDocument.ready ? (pageArea.currentPage + 1) + " / " + pdfDocument.pageCount : "\u2014"
                color: ThemeManager.text; Layout.preferredWidth: 72; horizontalAlignment: Text.AlignHCenter
            }
            ToolButton { text: "\u25B6"; enabled: pdfDocument.ready && pageArea.currentPage < pdfDocument.pageCount - 1; onClicked: pageArea.goTo(pageArea.currentPage + 1) }
            ToolSeparator {}
            ToolButton { text: "\u2212"; enabled: pdfDocument.ready; onClicked: pageArea.zoomOut() }
            Label { text: Math.round(pageArea.zoomFactor * 100) + "%"; color: ThemeManager.text; Layout.preferredWidth: 48; horizontalAlignment: Text.AlignHCenter }
            ToolButton { text: "+"; enabled: pdfDocument.ready; onClicked: pageArea.zoomIn() }
            ToolSeparator {}
            ToolButton { text: continuousMode ? "\uD83D\uDCDC" : "\uD83D\uDCC4"; onClicked: continuousMode = !continuousMode }
            ToolButton { text: "\uD83D\uDD0D"; onClicked: searchBar.toggle() }
            ToolButton { text: invertPages ? "\u2600" : "\uD83C\uDF19"; onClicked: invertPages = !invertPages }
            Item { Layout.fillWidth: true }
            Label { text: ThemeManager.displayName(ThemeManager.current); color: ThemeManager.textDim; font.pixelSize: 12 }
            ToolButton { text: lang === "ru" ? "RU" : "EN"; onClicked: { lang = lang === "ru" ? "en" : "ru"; settings.language = lang } }
            ToolButton { text: "\u2139"; onClicked: aboutDialog.open() }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0
        SidePanel {
            id: sidePanel
            visible: false
            Layout.preferredWidth: panelWidth
            Layout.fillHeight: true
            bookmarks: pdfDocument.bookmarks
            emptyText: tr("noBookmarks")
            onPageRequested: (p) => pageArea.goTo(p)
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
        anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 24
        width: 56; height: 56; text: "+"; font.pixelSize: 24
        Material.background: ThemeManager.primary
        Material.foreground: ThemeManager.onPrimary
        visible: !pdfDocument.ready
        onClicked: openNative()
    }

    footer: ToolBar {
        height: 28
        Material.background: ThemeManager.surface
        Label {
            anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 12
            text: pdfDocument.ready
                  ? ("Page " + (pageArea.currentPage + 1) + " of " + pdfDocument.pageCount)
                  : tr("openHint")
            color: ThemeManager.textDim; font.pixelSize: 12
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter; anchors.right: parent.right; anchors.rightMargin: 12
            text: "v" + appVersion
            color: ThemeManager.textDim; font.pixelSize: 12
        }
    }

    AboutDialog { id: aboutDialog }
}
