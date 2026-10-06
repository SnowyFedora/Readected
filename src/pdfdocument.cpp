#include "pdfdocument.h"
#include <poppler-qt6.h>
#include <QDebug>
#include <QFileInfo>

PdfDocument::PdfDocument(QObject *parent)
    : QObject(parent)
{
}

PdfDocument::~PdfDocument()
{
    close();
}

bool PdfDocument::load(const QString &path)
{
    close();

    QFileInfo fi(path);
    if (!fi.exists() || !fi.isFile()) {
        emit errorOccurred(tr("File not found: %1").arg(path));
        return false;
    }

    m_document = Poppler::Document::load(path);
    if (!m_document || m_document->isLocked()) {
        m_document.reset();
        emit errorOccurred(tr("Failed to open PDF (locked or invalid)"));
        return false;
    }

    m_document->setRenderHint(Poppler::Document::Antialiasing, true);
    m_document->setRenderHint(Poppler::Document::TextAntialiasing, true);
    m_path = path;
    m_pageCount = m_document->numPages();
    emit pageCountChanged();
    emit pathChanged();
    emit loadedChanged();
    rebuildOutline();
    emit documentLoaded();
    return true;
}

void PdfDocument::close()
{
    m_document.reset();
    m_path.clear();
    m_pageCount = 0;
    m_outline.clear();
    emit pageCountChanged();
    emit pathChanged();
    emit loadedChanged();
    emit outlineChanged();
}

QImage PdfDocument::renderPage(int page, double scale) const
{
    if (!m_document || page < 0 || page >= m_pageCount)
        return {};

    std::unique_ptr<Poppler::Page> p(m_document->page(page));
    if (!p)
        return {};

    // scale is relative to 72 DPI
    return p->renderToImage(72.0 * scale, 72.0 * scale);
}

QVariantList PdfDocument::search(const QString &text, int page) const
{
    QVariantList results;
    if (!m_document || text.isEmpty() || page < 0 || page >= m_pageCount)
        return results;

    std::unique_ptr<Poppler::Page> p(m_document->page(page));
    if (!p)
        return results;

    const auto rects = p->search(text, Poppler::Page::IgnoreCase);
    for (const auto &r : rects) {
        QVariantMap m;
        m["x"] = r.x();
        m["y"] = r.y();
        m["width"] = r.width();
        m["height"] = r.height();
        results.append(m);
    }
    return results;
}

void PdfDocument::rebuildOutline()
{
    m_outline.clear();
    if (!m_document)
        return;

    const auto toc = m_document->outline();
    std::function<void(const QVector<Poppler::OutlineItem> &, int)> walk;
    walk = [&](const QVector<Poppler::OutlineItem> &items, int depth) {
        for (const auto &item : items) {
            QVariantMap entry;
            entry["title"] = item.name();
            entry["depth"] = depth;
            int page = -1;
            if (item.destination()) {
                const auto dest = item.destination();
                if (dest->pageNumber() > 0)
                    page = dest->pageNumber() - 1; // 0-based
            }
            entry["page"] = page;
            m_outline.append(entry);
            if (item.hasChildren())
                walk(item.children(), depth + 1);
        }
    };
    walk(toc, 0);
    emit outlineChanged();
}
