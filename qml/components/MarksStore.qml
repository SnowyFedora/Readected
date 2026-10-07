import QtQuick

QtObject {
    id: root
    property var bookmarks: []
    property var notes: []
    property var fileHelper: null
    property string source: ""

    function load() {
        bookmarks = []
        notes = []
        if (!source || !fileHelper) return
        try {
            const data = JSON.parse(fileHelper.loadMarks(source))
            bookmarks = data.bookmarks || []
            notes = data.notes || []
        } catch (e) {
            bookmarks = []
            notes = []
        }
    }
    function save() {
        if (!source || !fileHelper) return
        fileHelper.saveMarks(source, JSON.stringify({ bookmarks: bookmarks, notes: notes }))
    }
    function addBookmark(page, label) {
        for (let i = 0; i < bookmarks.length; ++i)
            if (bookmarks[i].page === page) return false
        bookmarks = bookmarks.concat([{
            id: fileHelper.newId(), page: page,
            label: label || ("p. " + (page + 1)),
            created: fileHelper.nowIso()
        }])
        save()
        return true
    }
    function removeBookmark(id) {
        bookmarks = bookmarks.filter(b => b.id !== id)
        save()
    }
    function addNote(page, x, y, text) {
        notes = notes.concat([{
            id: fileHelper.newId(), page: page, x: x, y: y, text: text,
            created: fileHelper.nowIso()
        }])
        save()
    }
    function bookmarkPages() { return bookmarks.map(b => b.page) }
    function clear() { bookmarks = []; notes = [] }
}
