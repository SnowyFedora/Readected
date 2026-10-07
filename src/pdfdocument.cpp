#include "pdfdocument.h"
#include <poppler-qt6.h>
#include <QFileInfo>
#include <QDebug>
#include <QUrl>
#include <functional>
#include <QByteArray>

static QString sanitizeOutlineTitle(QString name)
{
    if (name.isEmpty())
        return name;

    name.remove(QChar(0xFEFF));
    name.remove(QChar(0xFFFE));
    name.remove(QChar(0x0000));
    name.remove(QChar(0x200B));
    name.remove(QChar(0x200E));
    name.remove(QChar(0x200F));

    auto countCyr = [](const QString &s) {
        int n = 0;
        for (const QChar &ch : s) {
            const uint u = ch.unicode();
            if (u >= 0x0400 && u <= 0x04FF)
                ++n;
        }
        return n;
    };

    {
        bool onlyLatin1 = true;
        QByteArray raw;
        raw.reserve(name.size());
        for (const QChar &ch : name) {
            const uint u = ch.unicode();
            if (u > 0xFF) { onlyLatin1 = false; break; }
            raw.append(static_cast<char>(u & 0xFF));
        }
        if (onlyLatin1 && raw.size() >= 2) {
            const QString recovered = QString::fromUtf8(raw);
            if (!recovered.isEmpty()
                && !recovered.contains(QChar::ReplacementCharacter)
                && countCyr(recovered) > countCyr(name)) {
                name = recovered;
            }
        }
    }

    if (name.size() >= 4) {
        bool onlyLatin1 = true;
        QByteArray raw;
        for (const QChar &ch : name) {
            if (ch.unicode() > 0xFF) { onlyLatin1 = false; break; }
            raw.append(static_cast<char>(ch.unicode() & 0xFF));
        }
        if (onlyLatin1 && (raw.size() % 2 == 0)) {
            QString fromBe;
            QString fromLe;
            for (int i = 0; i + 1 < raw.size(); i += 2) {
                const ushort be = (static_cast<unsigned char>(raw[i]) << 8)
                                  | static_cast<unsigned char>(raw[i + 1]);
                const ushort le = (static_cast<unsigned char>(raw[i + 1]) << 8)
                                  | static_cast<unsigned char>(raw[i]);
                if (be) fromBe.append(QChar(be));
                if (le) fromLe.append(QChar(le));
            }
            const int base = countCyr(name);
            if (countCyr(fromBe) > base && countCyr(fromBe) >= countCyr(fromLe))
                name = fromBe;
            else if (countCyr(fromLe) > base)
                name = fromLe;
        }
    }

    while (!name.isEmpty() && name.front().category() == QChar::Other_Control)
        name.remove(0, 1);
    while (!name.isEmpty() && name.back().category() == QChar::Other_Control)
        name.chop(1);

    return name.simplified();
}

PdfDocument::PdfDocument(QObject *parent)
    : QObject(parent)
{
}

PdfDocument::~PdfDocument()
{
    clear();
}

void PdfDocument::setSource(const QString &path)
{
    QString localPath = path;
    if (localPath.startsWith("file://"))
        localPath = QUrl(localPath).toLocalFile();

    if (localPath == m_source)
        return;

    clear();
    m_source = localPath;
    emit sourceChanged();

    if (!localPath.isEmpty())
        loadDocument(localPath);
}

void PdfDocument::loadDocument(const QString &path)
{
    QFileInfo fi(path);
    if (!fi.exists() || !fi.isFile()) {
        emit errorOccurred(tr("File not found: %1").arg(path));
        return;
    }

    m_doc = Poppler::Document::load(path);
    if (!m_doc || m_doc->isLocked()) {
        m_doc.reset();
        emit errorOccurred(tr("Failed to open PDF or file is locked"));
        return;
    }

    m_doc->setRenderHint(Poppler::Document::Antialiasing, true);
    m_doc->setRenderHint(Poppler::Document::TextAntialiasing, true);
    m_doc->setRenderHint(Poppler::Document::TextHinting, true);

    m_pageCount = m_doc->numPages();
    m_title = sanitizeOutlineTitle(m_doc->title());
    if (m_title.isEmpty())
        m_title = fi.fileName();

    m_ready = true;
    loadBookmarks();

    emit pageCountChanged();
    emit readyChanged();
    emit titleChanged();
    emit bookmarksChanged();
}

void PdfDocument::clear()
{
    m_doc.reset();
    m_pageCount = 0;
    m_ready = false;
    m_title.clear();
    m_bookmarks.clear();
    m_source.clear();

    emit pageCountChanged();
    emit readyChanged();
    emit titleChanged();
    emit bookmarksChanged();
}

void PdfDocument::loadBookmarks()
{
    m_bookmarks.clear();
    if (!m_doc)
        return;

    const QList<Poppler::OutlineItem> topLevel = m_doc->outline();
    if (topLevel.isEmpty())
        return;

    std::function<void(const QList<Poppler::OutlineItem> &, int)> walk;
    walk = [&](const QList<Poppler::OutlineItem> &items, int depth) {
        for (const auto &item : items) {
            QVariantMap entry;
            entry["title"] = sanitizeOutlineTitle(item.name());

            int page = -1;
            auto dest = item.destination();
            if (dest)
                page = dest->pageNumber() - 1;
            entry["page"] = page;
            entry["level"] = depth;
            m_bookmarks.append(entry);

            if (item.hasChildren())
                walk(item.children(), depth + 1);
        }
    };

    walk(topLevel, 1);
}

QImage PdfDocument::renderPage(int pageIndex, qreal scale) const
{
    if (!m_doc || pageIndex < 0 || pageIndex >= m_pageCount)
        return {};

    std::unique_ptr<Poppler::Page> page(m_doc->page(pageIndex));
    if (!page)
        return {};

    return page->renderToImage(72.0 * scale, 72.0 * scale);
}

QSizeF PdfDocument::pageSize(int pageIndex) const
{
    if (!m_doc || pageIndex < 0 || pageIndex >= m_pageCount)
        return {595, 842};

    std::unique_ptr<Poppler::Page> page(m_doc->page(pageIndex));
    if (!page)
        return {595, 842};

    return page->pageSizeF();
}

QVariantList PdfDocument::search(const QString &text) const
{
    QVariantList results;
    if (!m_doc || text.isEmpty())
        return results;

    for (int i = 0; i < m_pageCount; ++i) {
        std::unique_ptr<Poppler::Page> page(m_doc->page(i));
        if (!page)
            continue;

        auto rects = page->search(text, Poppler::Page::IgnoreCase);
        if (!rects.isEmpty()) {
            QVariantMap hit;
            hit["page"] = i;
            hit["count"] = rects.size();
            results.append(hit);
        }
    }
    return results;
}
