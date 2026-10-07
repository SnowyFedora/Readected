#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QObject>
#include <QFileDialog>
#include <QStandardPaths>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QCryptographicHash>
#include <QUuid>
#include <QDateTime>

class FileHelper : public QObject
{
    Q_OBJECT
public:
    explicit FileHelper(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE QString openPdf()
    {
        return QFileDialog::getOpenFileName(
            nullptr,
            tr("Open PDF"),
            QStandardPaths::writableLocation(QStandardPaths::HomeLocation),
            tr("PDF files (*.pdf);;All files (*)")
        );
    }

    Q_INVOKABLE QString marksDir() const
    {
        const QString base = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
                             + QStringLiteral("/Readected/marks");
        QDir().mkpath(base);
        return base;
    }

    Q_INVOKABLE QString marksPathFor(const QString &pdfPath) const
    {
        if (pdfPath.isEmpty())
            return {};
        const QByteArray hash = QCryptographicHash::hash(
            pdfPath.toUtf8(), QCryptographicHash::Sha256).toHex().left(32);
        return marksDir() + QLatin1Char('/') + QString::fromLatin1(hash) + QStringLiteral(".json");
    }

    Q_INVOKABLE QString loadMarks(const QString &pdfPath) const
    {
        const QString path = marksPathFor(pdfPath);
        QFile f(path);
        if (!f.open(QIODevice::ReadOnly))
            return QStringLiteral("{\"bookmarks\":[],\"notes\":[]}");
        return QString::fromUtf8(f.readAll());
    }

    Q_INVOKABLE bool saveMarks(const QString &pdfPath, const QString &json) const
    {
        if (pdfPath.isEmpty())
            return false;
        const QString path = marksPathFor(pdfPath);
        QFile f(path);
        if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate))
            return false;
        f.write(json.toUtf8());
        return true;
    }

    Q_INVOKABLE QString newId() const
    {
        return QUuid::createUuid().toString(QUuid::WithoutBraces);
    }

    Q_INVOKABLE QString nowIso() const
    {
        return QDateTime::currentDateTime().toString(Qt::ISODate);
    }
};

#endif
