#include "pdfdocument.h"
#include <poppler-qt6.h>
#include <QFileInfo>
#include <QDebug>
#include <QUrl>
#include <functional>

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

    // Poppler 26+ returns std::unique_ptr already
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
    m_title = m_doc->title();
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

    // Poppler 26: outline() returns QList<Poppler::OutlineItem>
    const QList<Poppler::OutlineItem> topLevel = m_doc->outline();
    if (topLevel.isEmpty())
        return;

    std::function<void(const QList<Poppler::OutlineItem> &, int)> walk;
    walk = [&](const QList<Poppler::OutlineItem> &items, int depth) {
        for (const auto &item : items) {
            QVariantMap entry;
            entry["title"] = item.name();

            int page = -1;
            // destination() returns QSharedPointer<const LinkDestination>
            auto dest = item.destination();
            if (dest) {
                page = dest->pageNumber() - 1;
            }
            entry["page"] = page;
            entry["level"] = depth;
            m_bookmarks.append(entry);

            if (item.hasChildren()) {
                walk(item.children(), depth + 1);
            }
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

    // DPI = 72 * scale
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
