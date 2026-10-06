#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QObject>
#include <QFileDialog>
#include <QStandardPaths>

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
};

#endif
