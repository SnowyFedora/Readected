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
    title: pdfDocument.ready ? (pdfDocument.title + " — Readected") : "Readected"
    color: ThemeManager.bg
    font.family: "Inter, Noto Sans, sans-serif"
    font.pixelSize: 13

    Material.theme: ThemeManager.isDark ? Material.Dark : Material.Light
    Material.accent: ThemeManager.primary
    Material.primary: ThemeManager.primary
    Material.background: ThemeManager.bg
    Material.foreground: ThemeManager.text
    Material.roundedScale: Material.Medium

    property string lang: "en"
    property bool continuousMode: true
    property bool invertPages: false
    property var recentFiles: []
    property bool sidebarOpen: false

    readonly property var i18n: ({
        en: {
            open: "Open", close: "Close", quit: "Quit",
            prev: "Previous", next: "Next",
            zoomIn: "Zoom in", zoomOut: "Zoom out",
            fitWidth: "Fit width", fitPage: "Fit page",
            search: "Search", theme: "Theme", about: "About",
            file: "File", view: "View", help: "Help",
            contents: "Outline", noBookmarks: "No outline",
            openHint: "Open a document",
            openHint2: "Ctrl+O  ·  drag & drop  ·  or use the button below",
            continuous: "Continuous", single: "Single page",
            invert: "Night mode", recent: "Recent", clearRecent: "Clear recent",
            goTo: "Go to page", fullscreen: "Fullscreen",
            language: "Language", page: "Page", of: "of"
        },
        ru: {
            open: "Открыть", close: "Закрыть", quit: "Выход",
            prev: "Назад", next: "Далее",
            zoomIn: "Крупнее", zoomOut: "Мельче",
            fitWidth: "По ширине", fitPage: "По странице",
            search: "Поиск", theme: "Тема", about: "О программе",
            file: "Файл", view: "Вид", help: "Справка",
            contents: "Оглавление", noBookmarks: "Нет оглавления",
            openHint: "Откройте документ",
            openHint2: "Ctrl+O  ·  перетащите файл  ·  или кнопка ниже",
            continuous: "Лента", single: "Постранично",
            invert: "Ночной режим", recent: "Недавние", clearRecent: "Очистить",
            goTo: "Перейти", fullscreen: "Полный экран",
            language: "Язык", page: "Стр.", of: "из"
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
    Shortcut { sequence: "Ctrl+0"; onActivated: pageArea.fitWidth() }
    Shortcut { sequence: "Ctrl+1"; onActivated: pageArea.fitPage() }
    Shortcut { sequence: "Ctrl+B"; onActivated: sidebarOpen = !sidebarOpen }
    Shortcut { sequence: "Ctrl+L"; onActivated: continuousMode = !continuousMode }
    Shortcut { sequence: "Ctrl+I"; onActivated: invertPages = !invertPages }
    Shortcut { sequence: "F11"; onActivated: root.visibility = root.visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen }
    Shortcut { sequence: "Left"; onActivated: if (pdfDocument.ready) pageArea.goTo(pageArea.currentPage - 1) }
    Shortcut { sequence: "Right"; onActivated: if (pdfDocument.ready) pageArea.goTo(pageArea.currentPage + 1) }
    Shortcut { sequence: "Space"; onActivated: if (pdfDocument.ready) pageArea.goTo(pageArea.currentPage + 1) }

    header: Rectangle {
        height: 48
        color: ThemeManager.surface
        Rectangle {
            anchors.bottom: parent.bottom; width: parent.width; height: 1
            color: ThemeManager.border; opacity: 0.6
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10; anchors.rightMargin: 10
            spacing: 2

            ToolButton {
                id: btnSidebar
                implicitWidth: 36; implicitHeight: 36
                text: "☰"
                font.pixelSize: 15
                onClicked: sidebarOpen = !sidebarOpen
                ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("contents") + "  (Ctrl+B)"
                background: Rectangle { radius: 8; color: btnSidebar.hovered || sidebarOpen ? ThemeManager.surface2 : "transparent" }
                contentItem: Text { text: btnSidebar.text; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font: btnSidebar.font }
            }
            ToolButton {
                id: btnOpen
                implicitWidth: 36; implicitHeight: 36
                onClicked: openNative()
                ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("open") + "  (Ctrl+O)"
                background: Rectangle { radius: 8; color: btnOpen.hovered ? ThemeManager.surface2 : "transparent" }
                contentItem: Text { text: "▢"; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 14 }
            }
            ToolButton {
                id: btnClose
                implicitWidth: 36; implicitHeight: 36
                enabled: pdfDocument.ready
                onClicked: closeDoc()
                ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("close")
                background: Rectangle { radius: 8; color: btnClose.hovered && btnClose.enabled ? ThemeManager.surface2 : "transparent"; opacity: btnClose.enabled ? 1 : 0.35 }
                contentItem: Text { text: "×"; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 18 }
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: ThemeManager.border; opacity: 0.5; Layout.leftMargin: 4; Layout.rightMargin: 4 }

            ToolButton {
                id: btnPrev
                implicitWidth: 36; implicitHeight: 36
                enabled: pdfDocument.ready && pageArea.currentPage > 0
                onClicked: pageArea.goTo(pageArea.currentPage - 1)
                background: Rectangle { radius: 8; color: btnPrev.hovered && btnPrev.enabled ? ThemeManager.surface2 : "transparent"; opacity: btnPrev.enabled ? 1 : 0.3 }
                contentItem: Text { text: "‹"; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 20 }
            }
            ToolButton {
                id: btnNext
                implicitWidth: 36; implicitHeight: 36
                enabled: pdfDocument.ready && pageArea.currentPage < pdfDocument.pageCount - 1
                onClicked: pageArea.goTo(pageArea.currentPage + 1)
                background: Rectangle { radius: 8; color: btnNext.hovered && btnNext.enabled ? ThemeManager.surface2 : "transparent"; opacity: btnNext.enabled ? 1 : 0.3 }
                contentItem: Text { text: "›"; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 20 }
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: ThemeManager.border; opacity: 0.5; Layout.leftMargin: 4; Layout.rightMargin: 4 }

            ToolButton {
                implicitWidth: 36; implicitHeight: 36
                enabled: pdfDocument.ready
                onClicked: pageArea.zoomOut()
                background: Rectangle { radius: 8; color: parent.hovered && parent.enabled ? ThemeManager.surface2 : "transparent"; opacity: parent.enabled ? 1 : 0.3 }
                contentItem: Text { text: "−"; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 18 }
            }
            Label {
                text: pdfDocument.ready ? Math.round(pageArea.zoomFactor * 100) + "%" : "—"
                color: ThemeManager.textDim
                font.pixelSize: 12
                Layout.preferredWidth: 44
                horizontalAlignment: Text.AlignHCenter
            }
            ToolButton {
                implicitWidth: 36; implicitHeight: 36
                enabled: pdfDocument.ready
                onClicked: pageArea.zoomIn()
                background: Rectangle { radius: 8; color: parent.hovered && parent.enabled ? ThemeManager.surface2 : "transparent"; opacity: parent.enabled ? 1 : 0.3 }
                contentItem: Text { text: "+"; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 16 }
            }

            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: ThemeManager.border; opacity: 0.5; Layout.leftMargin: 4; Layout.rightMargin: 4 }

            ToolButton {
                implicitWidth: 36; implicitHeight: 36
                checkable: true; checked: continuousMode
                onClicked: continuousMode = !continuousMode
                ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: continuousMode ? tr("continuous") : tr("single")
                background: Rectangle { radius: 8; color: parent.checked || parent.hovered ? ThemeManager.surface2 : "transparent" }
                contentItem: Text { text: continuousMode ? "≡" : "▭"; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 14 }
            }
            ToolButton {
                implicitWidth: 36; implicitHeight: 36
                onClicked: searchBar.toggle()
                ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("search") + "  (Ctrl+F)"
                background: Rectangle { radius: 8; color: parent.hovered ? ThemeManager.surface2 : "transparent" }
                contentItem: Text { text: "⌕"; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 15 }
            }
            ToolButton {
                implicitWidth: 36; implicitHeight: 36
                checkable: true; checked: invertPages
                onClicked: invertPages = !invertPages
                ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("invert")
                background: Rectangle { radius: 8; color: parent.checked || parent.hovered ? ThemeManager.surface2 : "transparent" }
                contentItem: Text { text: "◐"; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 14 }
            }

            Item { Layout.fillWidth: true }

            Label {
                visible: pdfDocument.ready
                text: tr("page") + " " + (pageArea.currentPage + 1) + " " + tr("of") + " " + pdfDocument.pageCount
                color: ThemeManager.textDim
                font.pixelSize: 12
            }

            ToolButton {
                implicitWidth: 36; implicitHeight: 36
                onClicked: themeMenu.open()
                ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("theme")
                background: Rectangle { radius: 8; color: parent.hovered ? ThemeManager.surface2 : "transparent" }
                contentItem: Text { text: "◉"; color: ThemeManager.primary; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                Menu {
                    id: themeMenu
                    width: 200
                    Repeater {
                        model: ThemeManager.themeIds
                        MenuItem {
                            text: ThemeManager.nameOf(modelData)
                            checkable: true
                            checked: ThemeManager.current === modelData
                            onTriggered: ThemeManager.setTheme(modelData)
                        }
                    }
                }
            }
            ToolButton {
                implicitWidth: 40; implicitHeight: 36
                text: lang === "ru" ? "RU" : "EN"
                font.pixelSize: 11
                font.bold: true
                onClicked: lang = (lang === "ru" ? "en" : "ru")
                background: Rectangle { radius: 8; color: parent.hovered ? ThemeManager.surface2 : "transparent" }
                contentItem: Text { text: parent.text; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font: parent.font }
            }
            ToolButton {
                implicitWidth: 36; implicitHeight: 36
                onClicked: aboutDialog.open()
                ToolTip.visible: hovered; ToolTip.delay: 500; ToolTip.text: tr("about")
                background: Rectangle { radius: 8; color: parent.hovered ? ThemeManager.surface2 : "transparent" }
                contentItem: Text { text: "i"; color: ThemeManager.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 14; font.bold: true }
            }
        }
    }

    DropArea {
        anchors.fill: parent
        onDropped: (drop) => {
            if (drop.hasUrls) {
                const u = drop.urls[0].toString()
                const p = u.startsWith("file://") ? u.substring(7) : u
                if (p.toLowerCase().endsWith(".pdf")) openPath(p)
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        SidePanel {
            id: sidePanel
            Layout.fillHeight: true
            visible: sidebarOpen
            title: tr("contents")
            emptyText: tr("noBookmarks")
            bookmarks: pdfDocument.bookmarks
            onPageRequested: (p) => pageArea.goTo(p)
            onWidthEdited: (w) => { settings.sidebarWidth = w }
        }

        Rectangle {
            Layout.preferredWidth: sidebarOpen ? 1 : 0
            Layout.fillHeight: true
            color: ThemeManager.border
            opacity: 0.5
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
                onSearchRequested: (q) => pageArea.search(q)
            }

            PageArea {
                id: pageArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                continuous: continuousMode
                invert: invertPages
                emptyHint: tr("openHint")
                emptyHint2: tr("openHint2")
            }
        }
    }

    // FAB open button when empty
    RoundButton {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        width: 52; height: 52
        visible: !pdfDocument.ready
        text: "+"
        font.pixelSize: 22
        Material.background: ThemeManager.primary
        Material.foreground: "#ffffff"
        onClicked: openNative()
    }

    AboutDialog { id: aboutDialog }
}
