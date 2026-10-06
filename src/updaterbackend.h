#ifndef UPDATERBACKEND_H
#define UPDATERBACKEND_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QProcess>
#include <QString>

class UpdaterBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString log READ log NOTIFY logChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(bool updateAvailable READ updateAvailable NOTIFY updateAvailableChanged)
    Q_PROPERTY(QString remoteVersion READ remoteVersion NOTIFY remoteVersionChanged)
    Q_PROPERTY(QString localVersion READ localVersion CONSTANT)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString sourceDir READ sourceDir WRITE setSourceDir NOTIFY sourceDirChanged)

public:
    explicit UpdaterBackend(QObject *parent = nullptr);

    QString status() const { return m_status; }
    QString log() const { return m_log; }
    bool busy() const { return m_busy; }
    bool updateAvailable() const { return m_updateAvailable; }
    QString remoteVersion() const { return m_remoteVersion; }
    QString localVersion() const { return m_localVersion; }
    int progress() const { return m_progress; }
    QString sourceDir() const { return m_sourceDir; }
    void setSourceDir(const QString &dir);

    Q_INVOKABLE void checkForUpdates();
    Q_INVOKABLE void installUpdate();
    Q_INVOKABLE void openSourceFolder();

signals:
    void statusChanged();
    void logChanged();
    void busyChanged();
    void updateAvailableChanged();
    void remoteVersionChanged();
    void progressChanged();
    void sourceDirChanged();
    void finished(bool ok);

private:
    void setStatus(const QString &s);
    void appendLog(const QString &line);
    void setBusy(bool b);
    void setProgress(int p);
    void runInstallScript();

    QNetworkAccessManager m_nam;
    QProcess *m_proc = nullptr;
    QString m_status;
    QString m_log;
    QString m_localVersion = QStringLiteral("1.3.0");
    QString m_remoteVersion;
    QString m_remoteSha;
    QString m_sourceDir;
    QString m_downloadPath;
    bool m_busy = false;
    bool m_updateAvailable = false;
    int m_progress = 0;
};

#endif
