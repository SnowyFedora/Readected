#ifndef PDFDOCUMENT_H
#define PDFDOCUMENT_H

#include <QObject>
#include <QImage>
#include <QVariantList>
#include <QString>
#include <memory>

namespace Poppler {
class Document;
}

class PdfDocument : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int pageCount READ pageCount NOTIFY pageCountChanged)
    Q_PROPERTY(QString path READ path NOTIFY pathChanged)
    Q_PROPERTY(bool loaded READ isLoaded NOTIFY loadedChanged)
    Q_PROPERTY(QVariantList outline READ outline NOTIFY outlineChanged)

public:
    explicit PdfDocument(QObject *parent = nullptr);
    ~PdfDocument() override;

    Q_INVOKABLE bool load(const QString &path);
    Q_INVOKABLE void close();
    Q_INVOKABLE QImage renderPage(int page, double scale) const;
    Q_INVOKABLE QVariantList search(const QString &text, int page) const;

    int pageCount() const { return m_pageCount; }
    QString path() const { return m_path; }
    bool isLoaded() const { return m_document != nullptr; }
    QVariantList outline() const { return m_outline; }

signals:
    void pageCountChanged();
    void pathChanged();
    void loadedChanged();
    void outlineChanged();
    void documentLoaded();
    void errorOccurred(const QString &message);

private:
    void rebuildOutline();

    std::unique_ptr<Poppler::Document> m_document;
    QString m_path;
    int m_pageCount = 0;
    QVariantList m_outline;
};

#endif // PDFDOCUMENT_H
