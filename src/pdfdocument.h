#ifndef PDFDOCUMENT_H
#define PDFDOCUMENT_H

#include <QObject>
#include <QString>
#include <QImage>
#include <QVariantList>
#include <memory>

namespace Poppler {
class Document;
class Page;
}

class PdfDocument : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(int pageCount READ pageCount NOTIFY pageCountChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
    Q_PROPERTY(QVariantList bookmarks READ bookmarks NOTIFY bookmarksChanged)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)

public:
    explicit PdfDocument(QObject *parent = nullptr);
    ~PdfDocument() override;

    QString source() const { return m_source; }
    void setSource(const QString &path);

    int pageCount() const { return m_pageCount; }
    bool ready() const { return m_ready; }
    QVariantList bookmarks() const { return m_bookmarks; }
    QString title() const { return m_title; }

    Q_INVOKABLE QImage renderPage(int pageIndex, qreal scale) const;
    Q_INVOKABLE QSizeF pageSize(int pageIndex) const;
    Q_INVOKABLE QVariantList search(const QString &text) const;

signals:
    void sourceChanged();
    void pageCountChanged();
    void readyChanged();
    void bookmarksChanged();
    void titleChanged();
    void errorOccurred(const QString &message);

private:
    void loadDocument(const QString &path);
    void clear();
    void loadBookmarks();

    QString m_source;
    int m_pageCount = 0;
    bool m_ready = false;
    QString m_title;
    QVariantList m_bookmarks;
    std::unique_ptr<Poppler::Document> m_doc;
};

#endif
