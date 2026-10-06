#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QObject>
#include <QUrl>
#include <QFileInfo>

class FileHelper : public QObject
{
    Q_OBJECT
public:
    explicit FileHelper(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE QString toLocalFile(const QUrl &url) const
    {
        if (url.isLocalFile())
            return url.toLocalFile();
        return url.toString();
    }

    Q_INVOKABLE bool exists(const QString &path) const
    {
        return QFileInfo::exists(path);
    }

    Q_INVOKABLE QString fileName(const QString &path) const
    {
        return QFileInfo(path).fileName();
    }
};

#endif // FILEHELPER_H
