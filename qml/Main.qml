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
    height: 820
    minimumWidth: 900
    minimumHeight: 560
    title: pdfDocument.ready ? (pdfDocument.title || "PDF") + " — Readected" : "Readected"
    color: ThemeManager.bg
    font.family: "Inter, JetBrains Mono, Noto Sans, sans-serif"
    font.pixelSize: 13

    Material.theme: ThemeManager.isDark ? Material.Dark : Material.Light
    Material.accent: ThemeManager.primary
    Material.primary: ThemeManager.primary
    Material.background: ThemeManager.bg
    Material.foreground: ThemeManager.text
    Material.roundedScale: Material.Small

    property string lang: "ru"
    property bool continuousMode: true
    property bool invertPages: false
    property var recentFiles: []
    property bool sidebarOpen: true

    readonly property var i18n: ({
        en: {
            open: "Open", close: "Close", outline: "Outline",
            noOutline: "No outline", search: "Search",
            emptyTitle: "No document open",
            emptySub: "Open a PDF, drop a file here, or pass a path on the CLI",
            openBtn: "Open PDF", page: "Page", of: "of",
            continuous: "Scroll", single: "Single", night: "Night",
            theme: "Theme", about: "About"
        },
        ru: {
            open: "Открыть", close: "Закрыть", outline: "Оглавление",
            noOutline: "Нет оглавления", search: "Поиск",
            emptyTitle: "Документ не открыт",
            emptySub: "Откройте PDF, перетащите файл сюда или укажите путь в CLI",
            openBtn: "Открыть PDF", page: "Стр.", of: "из",
            continuous: "Лента", single: "Страница", night: "Ночь",
            theme: "Тема", about: "О программе"
        }
    })
    function tr(k) { return (i18n[lang] && i18n[lang][k]) ? i18n[lang][k] : k }

    Settings {
        id: settings
        property string theme: "graphite"
        property string language: "ru"
        property real zoom: 1.2
        property bool continuous: true
        property bool sidebar: true
        property real sidebarWidth: 240
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
    Shortcut { sequence: "Ctrl+0"; onActivated: pageArea.fitToWidth() }
    Shortcut { sequence: "Ctrl+1"; onActivated: pageArea.fitToPage() }
    Shortcut { sequence: "Ctrl+B"; onActivated: sidebarOpen = !sidebarOpen }
    Shortcut { sequence: "Ctrl+L"; onActivated: continuousMode = !continuousMode }
    Shortcut { sequence: "Ctrl+I"; onActivated: invertPages = !invertPages }
    Shortcut { sequence: "Left"; onActivated: if (pdfDocument.ready) pageArea.goTo(pageArea.currentPage - 1) }
    Shortcut { sequence: "Right"; onActivated: if (pdfDocument.ready) pageArea.goTo(pageArea.currentPage + 1) }
    Shortcut { sequence: "Space"; onActivated: if (pdfDocument.ready) pageArea.goTo(pageArea.currentPage + 1) }

    header: Rectangle {
        height: 36
        color: ThemeManager.surface
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: ThemeManager.border
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 0
            Item {
                Layout.preferredWidth: 32; Layout.preferredHeight: 28
                Rectangle {
                    anchors.fill: parent; anchors.margins: 2; radius: 4
                    color: sbMa.containsMouse ? ThemeManager.surface2 : "transparent"
                    Text { anchors.centerIn: parent; text: "="; color: ThemeManager.text; font.pixelSize: 14; font.bold: true }
                    MouseArea {
                        id: sbMa; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sidebarOpen = !sidebarOpen
                    }
                }
            }
            Item {
                Layout.preferredWidth: 56; Layout.preferredHeight: 28
                Rectangle {
                    anchors.fill: parent; anchors.margins: 2; radius: 4
                    color: opMa.containsMouse ? ThemeManager.surface2 : "transparent"
                    Text { anchors.centerIn: parent; text: "Open"; color: ThemeManager.text; font.pixelSize: 12 }
                    MouseArea {
                        id: opMa; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: openNative()
                    }
                }
            }
            Item {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28
                Rectangle {
                    anchors.fill: parent; anchors.margins: 2; radius: 4
                    color: clMa.containsMouse && pdfDocument.ready ? ThemeManager.surface2 : "transparent"
                    Text { anchors.centerIn: parent; text: "x"; color: pdfDocument.ready ? ThemeManager.text : ThemeManager.textDim; font.pixelSize: 13 }
                    MouseArea {
                        id: clMa; anchors.fill: parent; hoverEnabled: true
                        enabled: pdfDocument.ready
                        onClicked: closeDoc()
                    }
                }
            }
            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; color: ThemeManager.border; Layout.leftMargin: 6; Layout.rightMargin: 6 }
            Item {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28
                Rectangle {
                    anchors.fill: parent; anchors.margins: 2; radius: 4
                    color: prevMa.containsMouse && pdfDocument.ready ? ThemeManager.surface2 : "transparent"
                    Text { anchors.centerIn: parent; text: "<"; color: pdfDocument.ready ? ThemeManager.text : ThemeManager.textDim; font.pixelSize: 14 }
                    MouseArea {
                        id: prevMa; anchors.fill: parent; hoverEnabled: true
                        enabled: pdfDocument.ready && pageArea.currentPage > 0
                        onClicked: pageArea.goTo(pageArea.currentPage - 1)
                    }
                }
            }
            Item {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28
                Rectangle {
                    anchors.fill: parent; anchors.margins: 2; radius: 4
                    color: nextMa.containsMouse && pdfDocument.ready ? ThemeManager.surface2 : "transparent"
                    Text { anchors.centerIn: parent; text: ">"; color: pdfDocument.ready ? ThemeManager.text : ThemeManager.textDim; font.pixelSize: 14 }
                    MouseArea {
                        id: nextMa; anchors.fill: parent; hoverEnabled: true
                        enabled: pdfDocument.ready && pageArea.currentPage < pdfDocument.pageCount - 1
                        onClicked: pageArea.goTo(pageArea.currentPage + 1)
                    }
                }
            }
            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; color: ThemeManager.border; Layout.leftMargin: 6; Layout.rightMargin: 6 }
            Item {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28
                Rectangle {
                    anchors.fill: parent; anchors.margins: 2; radius: 4
                    color: zoMa.containsMouse ? ThemeManager.surface2 : "transparent"
                    Text { anchors.centerIn: parent; text: "-"; color: ThemeManager.text; font.pixelSize: 15 }
                    MouseArea { id: zoMa; anchors.fill: parent; hoverEnabled: true; onClicked: pageArea.zoomOut() }
                }
            }
            Text {
                text: pdfDocument.ready ? Math.round(pageArea.zoomFactor * 100) + "%" : "--"
                color: ThemeManager.textDim
                font.pixelSize: 11
                font.family: "monospace"
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignHCenter
            }
            Item {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28
                Rectangle {
                    anchors.fill: parent; anchors.margins: 2; radius: 4
                    color: ziMa.containsMouse ? ThemeManager.surface2 : "transparent"
                    Text { anchors.centerIn: parent; text: "+"; color: ThemeManager.text; font.pixelSize: 14 }
                    MouseArea { id: ziMa; anchors.fill: parent; hoverEnabled: true; onClicked: pageArea.zoomIn() }
                }
            }
            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; color: ThemeManager.border; Layout.leftMargin: 6; Layout.rightMargin: 6 }
            Item {
                Layout.preferredWidth: 56; Layout.preferredHeight: 24
                Rectangle {
                    anchors.fill: parent; radius: 4
                    color: continuousMode ? ThemeManager.surface2 : "transparent"
                    border.color: continuousMode ? ThemeManager.border : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: continuousMode ? tr("continuous") : tr("single")
                        color: continuousMode ? ThemeManager.primary : ThemeManager.textDim
                        font.pixelSize: 11
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: continuousMode = !continuousMode }
                }
            }
            Item {
                Layout.preferredWidth: 44; Layout.preferredHeight: 24
                Layout.leftMargin: 4
                Rectangle {
                    anchors.fill: parent; radius: 4
                    color: invertPages ? ThemeManager.surface2 : "transparent"
                    border.color: invertPages ? ThemeManager.border : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: tr("night")
                        color: invertPages ? ThemeManager.accent : ThemeManager.textDim
                        font.pixelSize: 11
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: invertPages = !invertPages }
                }
            }
            Item {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28
                Layout.leftMargin: 2
                Rectangle {
                    anchors.fill: parent; anchors.margins: 2; radius: 4
                    color: seMa.containsMouse ? ThemeManager.surface2 : "transparent"
                    Text { anchors.centerIn: parent; text: "S"; color: ThemeManager.text; font.pixelSize: 12; font.bold: true }
                    MouseArea { id: seMa; anchors.fill: parent; hoverEnabled: true; onClicked: searchBar.toggle() }
                }
            }
            Item { Layout.fillWidth: true }
            Text {
                visible: pdfDocument.ready
                text: tr("page") + " " + (pageArea.currentPage + 1) + " " + tr("of") + " " + pdfDocument.pageCount
                color: ThemeManager.textDim
                font.pixelSize: 11
                font.family: "monospace"
                Layout.rightMargin: 8
            }
            Item {
                Layout.preferredWidth: 48; Layout.preferredHeight: 24
                Rectangle {
                    anchors.fill: parent; radius: 4
                    color: thMa.containsMouse ? ThemeManager.surface2 : "transparent"
                    Text { anchors.centerIn: parent; text: tr("theme"); color: ThemeManager.textDim; font.pixelSize: 11 }
                    MouseArea {
                        id: thMa; anchors.fill: parent; hoverEnabled: true
                        onClicked: themeMenu.open()
                    }
                    Menu {
                        id: themeMenu
                        width: 200
                        Repeater {
                            model: ThemeManager.themeIds
                            MenuItem {
                                required property var modelData
                                text: ThemeManager.displayName(modelData)
                                checkable: true
                                checked: ThemeManager.current === modelData
                                onTriggered: {
                                    ThemeManager.setTheme(modelData)
                                    settings.theme = modelData
                                }
                            }
                        }
                    }
                }
            }
            Item {
                Layout.preferredWidth: 32; Layout.preferredHeight: 24
                Rectangle {
                    anchors.fill: parent; radius: 4
                    color: langMa.containsMouse ? ThemeManager.surface2 : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: lang === "ru" ? "RU" : "EN"
                        color: ThemeManager.textDim; font.pixelSize: 11; font.bold: true
                    }
                    MouseArea {
                        id: langMa; anchors.fill: parent; hoverEnabled: true
                        onClicked: lang = (lang === "ru" ? "en" : "ru")
                    }
                }
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
            title: tr("outline")
            emptyText: tr("noOutline")
            bookmarks: pdfDocument.bookmarks
            onPageRequested: (p) => pageArea.goTo(p)
            onWidthEdited: (w) => { settings.sidebarWidth = w }
        }
        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: ThemeManager.border
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
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                PageArea {
                    id: pageArea
                    anchors.fill: parent
                    continuous: continuousMode
                    invert: invertPages
                    documentReady: pdfDocument.ready
                    pageCount: pdfDocument.pageCount
                    emptyHint: ""
                    emptyHint2: ""
                }
                Rectangle {
                    anchors.fill: parent
                    color: ThemeManager.bg
                    visible: !pdfDocument.ready
                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        width: 420
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tr("emptyTitle")
                            color: ThemeManager.text
                            font.pixelSize: 22
                            font.weight: Font.DemiBold
                        }
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: tr("emptySub")
                            color: ThemeManager.textDim
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }
                        Item { height: 8; width: 1 }
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 140; height: 36
                            radius: 6
                            color: openBtnMa.containsMouse ? ThemeManager.primaryHover : ThemeManager.primary
                            Text {
                                anchors.centerIn: parent
                                text: tr("openBtn")
                                color: ThemeManager.onPrimary
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                            }
                            MouseArea {
                                id: openBtnMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: openNative()
                            }
                        }
                    }
                }
            }
        }
    }

    footer: Rectangle {
        height: 22
        color: ThemeManager.surface
        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: ThemeManager.border
        }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: pdfDocument.ready
                  ? ((pdfDocument.source || "").split("/").pop())
                  : "Readected 1.3.1 · UI-FIXED"
            color: ThemeManager.textDim
            font.pixelSize: 10
            font.family: "monospace"
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: ThemeManager.displayName(ThemeManager.current)
            color: ThemeManager.textDim
            font.pixelSize: 10
        }
    }

    AboutDialog { id: aboutDialog }
}
