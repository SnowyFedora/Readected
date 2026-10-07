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
    title: pdfDocument.ready ? ((pdfDocument.title || "PDF") + " — Readected") : "Readected"
    color: ThemeManager.bg
    font.family: "Noto Sans"
    font.pixelSize: 13
    Material.theme: ThemeManager.isDark ? Material.Dark : Material.Light
    Material.accent: ThemeManager.primary
    Material.primary: ThemeManager.primary
    Material.background: ThemeManager.bg
    Material.foreground: ThemeManager.text

    property string lang: "ru"
    property bool continuousMode: true
    property bool invertPages: false
    property var recentFiles: []
    property bool sidebarOpen: true
    property bool editMode: false
    property var userBookmarks: []
    property var userNotes: []

    function tr(k) {
        var ru = {
            outline: "Оглавление", noOutline: "Нет оглавления", search: "Поиск",
            emptyTitle: "Документ не открыт", emptySub: "Откройте PDF", openBtn: "Открыть PDF",
            page: "Стр.", of: "из", continuous: "Лента", single: "Страница", night: "Ночь",
            theme: "Тема", bookmarks: "Закладки", noBookmarks: "Нет закладок",
            addBm: "+ Метка", edit: "Правка", editOn: "Правка вкл.",
            noteTitle: "Заметка", notePrompt: "Текст", save: "Сохранить", cancel: "Отмена"
        }
        var en = {
            outline: "Outline", noOutline: "No outline", search: "Search",
            emptyTitle: "No document open", emptySub: "Open a PDF", openBtn: "Open PDF",
            page: "Page", of: "of", continuous: "Scroll", single: "Single", night: "Night",
            theme: "Theme", bookmarks: "Bookmarks", noBookmarks: "No bookmarks",
            addBm: "+ Mark", edit: "Edit", editOn: "Editing",
            noteTitle: "Note", notePrompt: "Text", save: "Save", cancel: "Cancel"
        }
        var t = (lang === "ru") ? ru : en
        return t[k] || k
    }

    Settings {
        id: settings
        property string theme: "graphite"
        property string language: "ru"
        property real zoom: 1.2
        property bool continuous: true
        property bool sidebar: true
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
        persistMarks()
    }

    function openNative() {
        var path = fileHelper.openPdf()
        if (path && path.length) openPath(path)
    }
    function openPath(path) {
        persistMarks()
        pdfDocument.source = path
        var list = recentFiles.filter(function(p) { return p !== path })
        list.unshift(path)
        recentFiles = list.slice(0, 12)
        loadMarks()
    }
    function closeDoc() {
        persistMarks()
        pdfDocument.source = ""
        userBookmarks = []
        userNotes = []
        editMode = false
    }
    function loadMarks() {
        userBookmarks = []
        userNotes = []
        if (!pdfDocument.source) return
        try {
            var data = JSON.parse(fileHelper.loadMarks(pdfDocument.source))
            userBookmarks = data.bookmarks || []
            userNotes = data.notes || []
        } catch (e) {}
    }
    function persistMarks() {
        if (!pdfDocument.source) return
        fileHelper.saveMarks(pdfDocument.source, JSON.stringify({ bookmarks: userBookmarks, notes: userNotes }))
    }
    function addBookmarkHere() {
        if (!pdfDocument.ready) return
        var page = pageArea.currentPage
        for (var i = 0; i < userBookmarks.length; ++i)
            if (userBookmarks[i].page === page) { sidePanel.panelTab = 0; return }
        userBookmarks = userBookmarks.concat([{
            id: fileHelper.newId(), page: page,
            label: tr("page") + " " + (page + 1),
            created: fileHelper.nowIso()
        }])
        persistMarks()
        sidePanel.panelTab = 0
    }
    function removeBookmark(id) {
        userBookmarks = userBookmarks.filter(function(b) { return b.id !== id })
        persistMarks()
    }
    function bookmarkPageList() {
        return userBookmarks.map(function(b) { return b.page })
    }
    function addNoteAt(page, nx, ny) {
        noteDialog.pendingPage = page
        noteDialog.pendingX = nx
        noteDialog.pendingY = ny
        noteField.text = ""
        noteDialog.open()
        noteField.forceActiveFocus()
    }
    function commitNote() {
        var text = noteField.text.trim()
        if (!text.length) { noteDialog.close(); return }
        userNotes = userNotes.concat([{
            id: fileHelper.newId(), page: noteDialog.pendingPage,
            x: noteDialog.pendingX, y: noteDialog.pendingY, text: text,
            created: fileHelper.nowIso()
        }])
        persistMarks()
        noteDialog.close()
    }

    Connections {
        target: pdfDocument
        function onReadyChanged() {
            if (pdfDocument.ready && pdfDocument.source) loadMarks()
        }
    }

    Shortcut { sequences: [StandardKey.Open]; onActivated: openNative() }
    Shortcut { sequences: [StandardKey.Close]; onActivated: closeDoc() }
    Shortcut { sequences: [StandardKey.Quit]; onActivated: Qt.quit() }
    Shortcut { sequences: [StandardKey.Find]; onActivated: searchBar.toggle() }
    Shortcut { sequence: "Ctrl+="; onActivated: pageArea.zoomIn() }
    Shortcut { sequence: "Ctrl+-"; onActivated: pageArea.zoomOut() }
    Shortcut { sequence: "Ctrl+0"; onActivated: pageArea.fitToWidth() }
    Shortcut { sequence: "Ctrl+B"; onActivated: sidebarOpen = !sidebarOpen }
    Shortcut { sequence: "Ctrl+D"; onActivated: addBookmarkHere() }
    Shortcut { sequence: "Ctrl+E"; onActivated: if (pdfDocument.ready) editMode = !editMode }
    Shortcut { sequence: "Left"; onActivated: if (pdfDocument.ready) pageArea.goTo(pageArea.currentPage - 1) }
    Shortcut { sequence: "Right"; onActivated: if (pdfDocument.ready) pageArea.goTo(pageArea.currentPage + 1) }

    header: Rectangle {
        height: 36
        color: ThemeManager.surface
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: ThemeManager.border }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 2
            Button { text: "="; flat: true; onClicked: sidebarOpen = !sidebarOpen }
            Button { text: "Open"; flat: true; onClicked: openNative() }
            Button { text: "x"; flat: true; enabled: pdfDocument.ready; onClicked: closeDoc() }
            Button { text: "<"; flat: true; enabled: pdfDocument.ready; onClicked: pageArea.goTo(pageArea.currentPage - 1) }
            Button { text: ">"; flat: true; enabled: pdfDocument.ready; onClicked: pageArea.goTo(pageArea.currentPage + 1) }
            Button { text: "-"; flat: true; onClicked: pageArea.zoomOut() }
            Label { text: pdfDocument.ready ? (Math.round(pageArea.zoomFactor * 100) + "%") : "--"; color: ThemeManager.textDim }
            Button { text: "+"; flat: true; onClicked: pageArea.zoomIn() }
            Button { text: continuousMode ? tr("continuous") : tr("single"); flat: true; onClicked: continuousMode = !continuousMode }
            Button { text: tr("night"); flat: true; onClicked: invertPages = !invertPages }
            Button { text: tr("addBm"); flat: true; enabled: pdfDocument.ready; onClicked: addBookmarkHere() }
            Button { text: editMode ? tr("editOn") : tr("edit"); flat: true; enabled: pdfDocument.ready; onClicked: editMode = !editMode }
            Button { text: "S"; flat: true; onClicked: searchBar.toggle() }
            Item { Layout.fillWidth: true }
            Label {
                visible: pdfDocument.ready
                text: tr("page") + " " + (pageArea.currentPage + 1) + " " + tr("of") + " " + pdfDocument.pageCount
                color: ThemeManager.textDim
            }
            Button {
                text: tr("theme"); flat: true
                onClicked: themeMenu.open()
                Menu {
                    id: themeMenu
                    Repeater {
                        model: ThemeManager.themeIds
                        MenuItem {
                            required property var modelData
                            text: ThemeManager.displayName(modelData)
                            onTriggered: { ThemeManager.setTheme(modelData); settings.theme = modelData }
                        }
                    }
                }
            }
            Button { text: lang === "ru" ? "RU" : "EN"; flat: true; onClicked: lang = (lang === "ru" ? "en" : "ru") }
        }
    }

    DropArea {
        anchors.fill: parent
        onDropped: function(drop) {
            if (drop.hasUrls) {
                var u = drop.urls[0].toString()
                var p = u.indexOf("file://") === 0 ? u.substring(7) : u
                if (p.toLowerCase().indexOf(".pdf") === p.length - 4) openPath(p)
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0
        SidePanel {
            id: sidePanel
            visible: sidebarOpen
            Layout.fillHeight: true
            Layout.preferredWidth: sidebarOpen ? sidePanel.panelWidth : 0
            outlineTitle: tr("outline")
            bookmarksTitle: tr("bookmarks")
            emptyOutline: tr("noOutline")
            emptyBookmarks: tr("noBookmarks")
            addBookmarkLabel: tr("addBm")
            outline: pdfDocument.bookmarks
            userBookmarks: root.userBookmarks
            currentPage: pageArea.currentPage
            panelTab: 0
            onPageRequested: function(p) { pageArea.goTo(p) }
            onWidthEdited: function(w) { settings.sidebarWidth = w; sidePanel.panelWidth = w }
            onAddBookmarkRequested: addBookmarkHere()
            onRemoveBookmarkRequested: function(id) { removeBookmark(id) }
        }
        Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: ThemeManager.border; visible: sidebarOpen }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            SearchBar { id: searchBar; Layout.fillWidth: true; placeholder: tr("search") }
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
                    editMode: root.editMode
                    notes: root.userNotes
                    bookmarkPages: root.bookmarkPageList()
                    onNoteAddRequested: function(page, nx, ny) { addNoteAt(page, nx, ny) }
                }
                Rectangle {
                    anchors.fill: parent
                    color: ThemeManager.bg
                    visible: !pdfDocument.ready
                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: tr("emptyTitle"); color: ThemeManager.text; font.pixelSize: 22 }
                        Text { width: 400; horizontalAlignment: Text.AlignHCenter; text: tr("emptySub"); color: ThemeManager.textDim; wrapMode: Text.WordWrap }
                        Button { anchors.horizontalCenter: parent.horizontalCenter; text: tr("openBtn"); onClicked: openNative() }
                    }
                }
            }
        }
    }

    footer: Rectangle {
        height: 22
        color: ThemeManager.surface
        Text {
            anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter
            text: pdfDocument.ready ? ((pdfDocument.source || "").split("/").pop()) : "Readected 1.5.5"
            color: ThemeManager.textDim; font.pixelSize: 10
        }
    }

    Dialog {
        id: noteDialog
        title: tr("noteTitle")
        modal: true
        anchors.centerIn: parent
        width: 360
        property int pendingPage: 0
        property real pendingX: 0
        property real pendingY: 0
        standardButtons: Dialog.NoButton
        contentItem: ColumnLayout {
            TextField { id: noteField; Layout.fillWidth: true; placeholderText: tr("notePrompt"); onAccepted: commitNote() }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Button { text: tr("cancel"); onClicked: noteDialog.close() }
                Button { text: tr("save"); onClicked: commitNote() }
            }
        }
    }

    AboutDialog { id: aboutDialog }
}
