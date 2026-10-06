#include "pdfimageprovider.h"
#include "pdfdocument.h"
#include <QDebug>

PdfImageProvider::PdfImageProvider(PdfDocument *doc)
    : QQuickImageProvider(QQuickImageProvider::Image)
    , m_doc(doc)
{
}

void PdfImageProvider::setDocument(PdfDocument *doc)
{
    QMutexLocker lock(&m_mutex);
    m_doc = doc;
    m_cache.clear();
}

void PdfImageProvider::clearCache()
{
    QMutexLocker lock(&m_mutex);
    m_cache.clear();
}

QImage PdfImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    // id: "pageIndex_scale" e.g. "3_1.20"
    const QStringList parts = id.split(QLatin1Char('_'));
    if (parts.size() < 2)
        return {};

    bool ok1 = false, ok2 = false;
    const int page = parts[0].toInt(&ok1);
    const qreal scale = parts[1].toDouble(&ok2);
    if (!ok1 || !ok2 || scale <= 0.0)
        return {};

    const QString cacheKey = id;

    {
        QMutexLocker lock(&m_mutex);
        if (m_cache.contains(cacheKey)) {
            const QImage &img = m_cache.constFind(cacheKey).value();
            if (size)
                *size = img.size();
            return img;
        }
    }

    if (!m_doc || !m_doc->ready())
        return {};

    // Cap scale to avoid huge bitmaps
    const qreal cappedScale = qMin(scale, 2.5);
    QImage img = m_doc->renderPage(page, cappedScale);
    if (img.isNull())
        return {};

    // Convert to more compact format if very large
    if (img.width() * img.height() > 8'000'000)
        img = img.scaled(img.width() / 2, img.height() / 2, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    {
        QMutexLocker lock(&m_mutex);
        // LRU-ish: keep at most 12 pages
        if (m_cache.size() >= 12)
            m_cache.clear();
        m_cache.insert(cacheKey, img);
    }

    if (size)
        *size = img.size();
    return img;
}
