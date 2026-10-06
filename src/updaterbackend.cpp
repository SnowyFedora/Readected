#include "updaterbackend.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QDesktopServices>
#include <QUrl>
#include <QCoreApplication>

UpdaterBackend::UpdaterBackend(QObject *parent)
    : QObject(parent)
{
    m_status = tr("Ready");
    const QString home = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    const QStringList candidates = {
        home + QStringLiteral("/\u0417\u0430\u0433\u0440\u0443\u0437\u043a\u0438/readected"),
        home + QStringLiteral("/Downloads/readected"),
        home + QStringLiteral("/readected"),
        QCoreApplication::applicationDirPath() + QStringLiteral("/../share/readected")
    };
    for (const QString &c : candidates) {
        if (QDir(c).exists()) {
            m_sourceDir = c;
            break;
        }
    }
    if (m_sourceDir.isEmpty())
        m_sourceDir = home + QStringLiteral("/Downloads/readected");
}

void UpdaterBackend::setSourceDir(const QString &dir)
{
    if (m_sourceDir == dir) return;
    m_sourceDir = dir;
    emit sourceDirChanged();
}

void UpdaterBackend::setStatus(const QString &s)
{
    if (m_status == s) return;
    m_status = s;
    emit statusChanged();
}

void UpdaterBackend::appendLog(const QString &line)
{
    if (!m_log.isEmpty()) m_log += QLatin1Char('\n');
    m_log += line;
    emit logChanged();
}

void UpdaterBackend::setBusy(bool b)
{
    if (m_busy == b) return;
    m_busy = b;
    emit busyChanged();
}

void UpdaterBackend::setProgress(int p)
{
    p = qBound(0, p, 100);
    if (m_progress == p) return;
    m_progress = p;
    emit progressChanged();
}

QString UpdaterBackend::installedShaPath() const
{
    const QString cfg = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    QDir().mkpath(cfg);
    return cfg + QStringLiteral("/installed_sha");
}

QString UpdaterBackend::readInstalledSha() const
{
    QFile f(installedShaPath());
    if (f.open(QIODevice::ReadOnly))
        return QString::fromUtf8(f.readAll()).trimmed().left(7);
    return {};
}

void UpdaterBackend::writeInstalledSha(const QString &sha)
{
    if (sha.isEmpty()) return;
    QFile f(installedShaPath());
    if (f.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        f.write(sha.toUtf8());
        f.write("\n");
    }
    if (!m_sourceDir.isEmpty()) {
        QFile f2(m_sourceDir + QStringLiteral("/.readected_sha"));
        if (f2.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            f2.write(sha.toUtf8());
            f2.write("\n");
        }
    }
}

void UpdaterBackend::checkForUpdates()
{
    if (m_busy) return;
    setBusy(true);
    setProgress(10);
    setStatus(tr("Checking GitHub\u2026"));
    appendLog(tr("\u2192 GET api.github.com/repos/SnowyFedora/Readected/commits/main"));

    QNetworkRequest req(QUrl(QStringLiteral(
        "https://api.github.com/repos/SnowyFedora/Readected/commits/main")));
    req.setHeader(QNetworkRequest::UserAgentHeader, QStringLiteral("Readected-Updater/1.3"));
    req.setRawHeader("Accept", "application/vnd.github+json");

    QNetworkReply *reply = m_nam.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        setProgress(40);

        if (reply->error() != QNetworkReply::NoError) {
            setStatus(tr("Network error"));
            appendLog(tr("Error: %1").arg(reply->errorString()));
            setBusy(false);
            emit finished(false);
            return;
        }

        const QJsonObject obj = QJsonDocument::fromJson(reply->readAll()).object();
        m_remoteSha = obj.value(QStringLiteral("sha")).toString().left(7);
        const QString msg = obj.value(QStringLiteral("commit")).toObject()
                               .value(QStringLiteral("message")).toString().split(QLatin1Char('\n')).first();
        m_remoteVersion = m_remoteSha.isEmpty() ? QStringLiteral("unknown") : m_remoteSha;
        emit remoteVersionChanged();

        QString localSha = readInstalledSha();
        if (localSha.isEmpty()) {
            QFile ver(m_sourceDir + QStringLiteral("/.git/refs/heads/main"));
            if (ver.open(QIODevice::ReadOnly))
                localSha = QString::fromUtf8(ver.readAll()).trimmed().left(7);
        }
        if (localSha.isEmpty()) {
            QFile ver2(m_sourceDir + QStringLiteral("/.readected_sha"));
            if (ver2.open(QIODevice::ReadOnly))
                localSha = QString::fromUtf8(ver2.readAll()).trimmed().left(7);
        }

        if (localSha.isEmpty() && !m_remoteSha.isEmpty()) {
            writeInstalledSha(m_remoteSha);
            localSha = m_remoteSha;
            m_updateAvailable = false;
        } else {
            m_updateAvailable = !m_remoteSha.isEmpty() && !localSha.isEmpty() && localSha != m_remoteSha;
        }

        emit updateAvailableChanged();
        setProgress(100);

        if (m_updateAvailable) {
            setStatus(tr("Update available"));
            appendLog(tr("Remote: %1 \u2014 %2").arg(m_remoteSha, msg));
            if (!localSha.isEmpty())
                appendLog(tr("Local:  %1").arg(localSha));
        } else {
            setStatus(tr("Up to date"));
            appendLog(tr("Already on latest commit (%1)").arg(m_remoteSha));
            writeInstalledSha(m_remoteSha);
        }
        setBusy(false);
        emit finished(true);
    });
}

void UpdaterBackend::installUpdate()
{
    if (m_busy) return;
    setBusy(true);
    setProgress(5);
    m_log.clear();
    emit logChanged();
    setStatus(tr("Downloading\u2026"));
    appendLog(tr("\u2192 Download source archive from GitHub"));

    m_downloadPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)
                     + QStringLiteral("/readected-update.zip");

    QNetworkRequest req(QUrl(QStringLiteral(
        "https://github.com/SnowyFedora/Readected/archive/refs/heads/main.zip")));
    req.setHeader(QNetworkRequest::UserAgentHeader, QStringLiteral("Readected-Updater/1.3"));

    QNetworkReply *reply = m_nam.get(req);
    connect(reply, &QNetworkReply::downloadProgress, this, [this](qint64 rec, qint64 total) {
        if (total > 0)
            setProgress(5 + int(50.0 * rec / total));
    });
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            setStatus(tr("Download failed"));
            appendLog(reply->errorString());
            setBusy(false);
            emit finished(false);
            return;
        }

        QFile f(m_downloadPath);
        if (!f.open(QIODevice::WriteOnly) || f.write(reply->readAll()) < 0) {
            setStatus(tr("Cannot write temp file"));
            setBusy(false);
            emit finished(false);
            return;
        }
        f.close();
        appendLog(tr("Saved %1").arg(m_downloadPath));
        setProgress(60);
        setStatus(tr("Extracting & installing\u2026"));

        const QString destParent = QFileInfo(m_sourceDir).absolutePath();
        const QString script = QStringLiteral(
            "set -e\n"
            "TMPDIR=$(mktemp -d)\n"
            "unzip -qo \"%1\" -d \"$TMPDIR\"\n"
            "SRC=$(find \"$TMPDIR\" -maxdepth 1 -type d -name 'Readected-*' | head -1)\n"
            "mkdir -p \"%2\"\n"
            "rm -rf \"%3\"\n"
            "mv \"$SRC\" \"%3\"\n"
            "chmod +x \"%3/install.sh\"\n"
            "cd \"%3\"\n"
            "./install.sh all\n"
            "rm -rf \"$TMPDIR\"\n"
        ).arg(m_downloadPath, destParent, m_sourceDir);

        if (m_proc) {
            m_proc->kill();
            m_proc->deleteLater();
        }
        m_proc = new QProcess(this);
        m_proc->setProcessChannelMode(QProcess::MergedChannels);
        connect(m_proc, &QProcess::readyRead, this, [this]() {
            appendLog(QString::fromUtf8(m_proc->readAll()).trimmed());
        });
        connect(m_proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
                this, [this](int code, QProcess::ExitStatus) {
            setProgress(100);
            if (code == 0) {
                setStatus(tr("Installed successfully"));
                appendLog(tr("\u2713 Done. Restart Readected."));
                writeInstalledSha(m_remoteSha);
                m_updateAvailable = false;
                emit updateAvailableChanged();
                emit finished(true);
            } else {
                setStatus(tr("Install failed (code %1)").arg(code));
                appendLog(tr("Try running manually: cd %1 && ./install.sh").arg(m_sourceDir));
                emit finished(false);
            }
            setBusy(false);
        });

        appendLog(tr("\u2192 Running install.sh (password dialog via pkexec/sudo)\u2026"));
        if (QFileInfo::exists(QStringLiteral("/usr/bin/pkexec"))) {
            m_proc->start(QStringLiteral("pkexec"),
                          QStringList() << QStringLiteral("bash") << QStringLiteral("-lc") << script);
        } else {
            m_proc->start(QStringLiteral("bash"),
                          QStringList() << QStringLiteral("-lc") << script);
        }
        setProgress(70);
    });
}

void UpdaterBackend::openSourceFolder()
{
    QDesktopServices::openUrl(QUrl::fromLocalFile(m_sourceDir));
}
