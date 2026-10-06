#ifndef PDFIMAGEPROVIDER_H
#define PDFIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QImage>
#include <QHash>
#include <QMutex>

class PdfDocument;

class PdfImageProvider : public QQuickImageProvider
{
public:
    explicit PdfImageProvider(PdfDocument *doc);

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

    void setDocument(PdfDocument *doc);
    void clearCache();

private:
    PdfDocument *m_doc = nullptr;
    QHash<QString, QImage> m_cache;
    QMutex m_mutex;
};

#endif // PDFIMAGEPROVIDER_H
