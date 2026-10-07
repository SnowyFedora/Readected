#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QObject>
#include <QFileDialog>
#include <QStandardPaths>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
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

    Q_INVOKABLE QString sidecarPath(const QString &pdfPath) const
    {
        if (pdfPath.isEmpty()) return {};
        return pdfPath + QStringLiteral(".readected.json");
    }

    Q_INVOKABLE QString loadMarks(const QString &pdfPath) const
    {
        const QString path = sidecarPath(pdfPath);
        QFile f(path);
        if (!f.open(QIODevice::ReadOnly))
            return QStringLiteral("{\"bookmarks\":[],\"notes\":[]}");
        return QString::fromUtf8(f.readAll());
    }

    Q_INVOKABLE bool saveMarks(const QString &pdfPath, const QString &json) const
    {
        if (pdfPath.isEmpty()) return false;
        const QString path = sidecarPath(pdfPath);
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
