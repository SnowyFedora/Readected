import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore
import "components"
import "themes"

ApplicationWindow {
    id: root
    visible: true
    width: 1200
    height: 800
    minimumWidth: 640
    minimumHeight: 480
    title: pdfDocument.ready ? (pdfDocument.title + " — Readected") : "Readected"
    color: ThemeManager.background

    Material.theme: ThemeManager.isDark ? Material.Dark : Material.Light
    Material.accent: ThemeManager.primary
    Material.primary: ThemeManager.primary
    Material.background: ThemeManager.background
    Material.foreground: ThemeManager.text

    property bool sidebarVisible: true
    property real sidebarWidth: 260
    property bool continuousMode: true
    property bool nightMode: false
    property string lang: "en"

    Settings {
        id: settings
        property string themeId: "material_dark"
        property real sidebarWidth: 260
        property bool continuousMode: true
        property bool nightMode: false
        property string lang: "en"
        property real zoom: 1.15
    }

    Component.onCompleted: {
        ThemeManager.apply(settings.themeId)
        root.sidebarWidth = settings.sidebarWidth
        root.continuousMode = settings.continuousMode
        root.nightMode = settings.nightMode
        root.lang = settings.lang
        pageArea.zoomFactor = settings.zoom
    }

    function tr(en, ru) {
        return root.lang === "ru" ? ru : en
    }

    header: ToolBar {
        id: topBar
        height: 52
        Material.background: ThemeManager.surface

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 4

            ToolButton {
                text: "☰"
                onClicked: root.sidebarVisible = !root.sidebarVisible
                ToolTip.visible: hovered
                ToolTip.text: tr("Toggle sidebar", "Боковая панель")
            }
            ToolButton {
                text: "📂"
                onClicked: fileDialog.open()
                ToolTip.visible: hovered
                ToolTip.text: tr("Open PDF", "Открыть PDF")
            }
            ToolButton {
                text: "✕"
                enabled: pdfDocument.ready
                onClicked: pdfDocument.setSource("")
                ToolTip.visible: hovered
                ToolTip.text: tr("Close", "Закрыть")
            }

            ToolSeparator {}

            ToolButton {
                text: "◀"
                enabled: pdfDocument.ready && pageArea.currentPage > 0
                onClicked: pageArea.goTo(pageArea.currentPage - 1)
            }
            Label {
                text: pdfDocument.ready
                      ? (pageArea.currentPage + 1) + " / " + pdfDocument.pageCount
                      : "—"
                color: ThemeManager.text
                Layout.preferredWidth: 72
                horizontalAlignment: Text.AlignHCenter
            }
            ToolButton {
                text: "▶"
                enabled: pdfDocument.ready && pageArea.currentPage < pdfDocument.pageCount - 1
                onClicked: pageArea.goTo(pageArea.currentPage + 1)
            }

            ToolSeparator {}

            ToolButton {
                text: "−"
                enabled: pdfDocument.ready
                onClicked: pageArea.zoomOut()
            }
            Label {
                text: Math.round(pageArea.zoomFactor * 100) + "%"
                color: ThemeManager.text
                Layout.preferredWidth: 48
                horizontalAlignment: Text.AlignHCenter
            }
            ToolButton {
                text: "+"
                enabled: pdfDocument.ready
                onClicked: pageArea.zoomIn()
            }

            ToolSeparator {}

            ToolButton {
                text: root.continuousMode ? "📜" : "📄"
                onClicked: {
                    root.continuousMode = !root.continuousMode
                    settings.continuousMode = root.continuousMode
                }
                ToolTip.visible: hovered
                ToolTip.text: tr("Toggle continuous", "Непрерывный режим")
            }
            ToolButton {
                text: "🔍"
                onClicked: searchBar.toggle()
            }
            ToolButton {
                text: root.nightMode ? "☀️" : "🌙"
                onClicked: {
                    root.nightMode = !root.nightMode
                    settings.nightMode = root.nightMode
                }
                ToolTip.visible: hovered
                ToolTip.text: tr("Night mode", "Ночной режим")
            }

            Item { Layout.fillWidth: true }

            ToolButton {
                text: "🎨"
                onClicked: themeMenu.open()
                Menu {
                    id: themeMenu
                    MenuItem { text: "System / qt6ct"; onTriggered: applyTheme("system") }
                    MenuItem { text: "Material Dark"; onTriggered: applyTheme("material_dark") }
                    MenuItem { text: "Material Light"; onTriggered: applyTheme("material_light") }
                    MenuItem { text: "Nord"; onTriggered: applyTheme("nord") }
                    MenuItem { text: "Dracula"; onTriggered: applyTheme("dracula") }
                    MenuItem { text: "Tokyo Night"; onTriggered: applyTheme("tokyo_night") }
                    MenuItem { text: "One Dark"; onTriggered: applyTheme("one_dark") }
                    MenuItem { text: "Solarized Dark"; onTriggered: applyTheme("solarized_dark") }
                    MenuItem { text: "Solarized Light"; onTriggered: applyTheme("solarized_light") }
                    MenuItem { text: "Gruvbox Dark"; onTriggered: applyTheme("gruvbox_dark") }
                    MenuItem { text: "Gruvbox Light"; onTriggered: applyTheme("gruvbox_light") }
                    MenuItem { text: "Catppuccin Mocha"; onTriggered: applyTheme("catppuccin_mocha") }
                    MenuItem { text: "Catppuccin Latte"; onTriggered: applyTheme("catppuccin_latte") }
                    MenuItem { text: "Marxism"; onTriggered: applyTheme("marxism") }
                }
            }
            ToolButton {
                text: root.lang === "ru" ? "RU" : "EN"
                onClicked: {
                    root.lang = root.lang === "ru" ? "en" : "ru"
                    settings.lang = root.lang
                }
            }
            ToolButton {
                text: "ℹ"
                onClicked: aboutDialog.open()
            }
        }
    }

    function applyTheme(id) {
        ThemeManager.apply(id)
        settings.themeId = id
    }

    // Body
    RowLayout {
        anchors.fill: parent
        spacing: 0

        SidePanel {
            id: sidePanel
            visible: root.sidebarVisible
            Layout.preferredWidth: root.sidebarWidth
            Layout.fillHeight: true
            panelWidth: root.sidebarWidth
            bookmarks: pdfDocument.bookmarks
            emptyText: tr("No outline", "Нет оглавления")
            onPageRequested: (p) => pageArea.goTo(p)
            onWidthEdited: (w) => {
                root.sidebarWidth = w
                settings.sidebarWidth = w
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            SearchBar {
                id: searchBar
                Layout.fillWidth: true
                placeholder: tr("Search in document…", "Поиск в документе…")
                findLabel: tr("Find", "Найти")
                onSearchRequested: (text) => {
                    const hits = pdfDocument.search(text)
                    if (hits.length > 0)
                        pageArea.goTo(hits[0].page)
                }
            }

            PageArea {
                id: pageArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                documentReady: pdfDocument.ready
                pageCount: pdfDocument.pageCount
                continuous: root.continuousMode
                invert: root.nightMode
                emptyHint: tr("Open a PDF", "Откройте PDF")
                emptyHint2: tr("Ctrl+O · drag & drop · CLI argument", "Ctrl+O · перетащите файл · аргумент CLI")
                onPageChanged: (p) => { /* synced */ }
                onZoomFactorChanged: settings.zoom = zoomFactor

                function goTo(page) {
                    currentPage = Math.max(0, Math.min(page, pageCount - 1))
                    if (continuous && listView) {
                        // PageArea internal ListView scroll handled inside component
                    }
                }
                function zoomIn() { zoomFactor = Math.min(3.0, zoomFactor + 0.1) }
                function zoomOut() { zoomFactor = Math.max(0.4, zoomFactor - 0.1) }
            }
        }
    }

    // FAB open
    RoundButton {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        width: 56; height: 56
        text: "+"
        font.pixelSize: 24
        Material.background: ThemeManager.primary
        Material.foreground: ThemeManager.onPrimary
        visible: !pdfDocument.ready
        onClicked: fileDialog.open()
    }

    FileDialog {
        id: fileDialog
        title: tr("Open PDF", "Открыть PDF")
        nameFilters: ["PDF (*.pdf)"]
        onAccepted: {
            const path = selectedFile.toString()
            pdfDocument.setSource(path)
        }
    }

    DropArea {
        anchors.fill: parent
        onDropped: (drop) => {
            if (drop.hasUrls && drop.urls.length > 0)
                pdfDocument.setSource(drop.urls[0].toString())
        }
    }

    Shortcut {
        sequences: ["Ctrl+O"]
        onActivated: fileDialog.open()
    }
    Shortcut {
        sequences: ["Ctrl+F"]
        onActivated: searchBar.toggle()
    }
    Shortcut {
        sequences: ["Ctrl+W"]
        onActivated: pdfDocument.setSource("")
    }
    Shortcut {
        sequences: ["Left", "Page Up"]
        onActivated: if (pdfDocument.ready) pageArea.goTo(pageArea.currentPage - 1)
    }
    Shortcut {
        sequences: ["Right", "Page Down"]
        onActivated: if (pdfDocument.ready) pageArea.goTo(pageArea.currentPage + 1)
    }
    Shortcut {
        sequences: ["Home"]
        onActivated: if (pdfDocument.ready) pageArea.goTo(0)
    }
    Shortcut {
        sequences: ["End"]
        onActivated: if (pdfDocument.ready) pageArea.goTo(pdfDocument.pageCount - 1)
    }

    AboutDialog { id: aboutDialog }
}
