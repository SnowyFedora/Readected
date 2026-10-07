#include <QApplication>
#include <QProcess>
#include <cstdio>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QFileInfo>
#include <QUrl>
#include <QTimer>
#include <QPalette>

#include "pdfdocument.h"
#include "pdfimageprovider.h"
#include "filehelper.h"

static QString findPdfArgument(const QStringList &args)
{
    for (int i = 1; i < args.size(); ++i) {
        const QString &a = args.at(i);
        if (a.startsWith(QLatin1Char('-')))
            continue;
        QString path = a;
        if (path.startsWith(QLatin1String("file:")))
            path = QUrl(path).toLocalFile();
        QFileInfo fi(path);
        if (fi.exists() && fi.isFile())
            return fi.absoluteFilePath();
    }
    return {};
}

int main(int argc, char *argv[])
{
    if (argc >= 2) {
        const QString cmd = QString::fromLocal8Bit(argv[1]);
        if (cmd == QLatin1String("help") || cmd == QLatin1String("--help") || cmd == QLatin1String("-h")) {
            fprintf(stdout,
                "Readected 1.5.5\n"
                "  readected [file.pdf]     open viewer\n"
                "  readected update         reinstall from GitHub\n"
                "  readected uninstall      remove ~/.local binaries\n"
                "  readected version        print version\n"
                "  readected which          print binary path\n");
            return 0;
        }
        if (cmd == QLatin1String("version") || cmd == QLatin1String("--version") || cmd == QLatin1String("-v")) {
            fprintf(stdout, "Readected 1.5.5\n");
            return 0;
        }
        if (cmd == QLatin1String("which")) {
            fprintf(stdout, "%s\n", argv[0]);
            return 0;
        }
        if (cmd == QLatin1String("update") || cmd == QLatin1String("--update")) {
            return QProcess::execute(QStringLiteral("bash"), {
                QStringLiteral("-lc"),
                QStringLiteral(
                    "TMP=$(mktemp -d); "
                    "curl -fsSL -o \"$TMP/z.zip\" https://github.com/SnowyFedora/Readected/archive/refs/heads/main.zip "
                    "|| wget -q -O \"$TMP/z.zip\" https://github.com/SnowyFedora/Readected/archive/refs/heads/main.zip; "
                    "unzip -qo \"$TMP/z.zip\" -d \"$TMP\"; "
                    "SRC=$(find \"$TMP\" -maxdepth 1 -type d -name 'Readected-*' | head -1); "
                    "chmod +x \"$SRC/INSTALL_HOME.sh\"; "
                    "bash \"$SRC/INSTALL_HOME.sh\"; "
                    "rm -rf \"$TMP\""
                )
            });
        }
        if (cmd == QLatin1String("uninstall") || cmd == QLatin1String("--uninstall")) {
            return QProcess::execute(QStringLiteral("bash"), {
                QStringLiteral("-lc"),
                QStringLiteral(
                    "rm -f \"$HOME/.local/bin/readected\" \"$HOME/.local/bin/readected-bin\" "
                    "\"$HOME/.local/bin/readected-update\" \"$HOME/.local/bin/readected-uninstall\" "
                    "\"$HOME/.local/bin/readected-updater\"; "
                    "rm -f \"$HOME/.local/share/applications/readected.desktop\"; "
                    "echo 'Uninstalled. Marks kept in ~/.config/Readected/marks/'"
                )
            });
        }
    }

    QApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("Readected"));
    app.setOrganizationName(QStringLiteral("Proletariat"));
    app.setApplicationVersion(QStringLiteral("1.5.5"));
    app.setDesktopFileName(QStringLiteral("readected"));

    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE"))
        QQuickStyle::setStyle(QStringLiteral("Material"));

    qmlRegisterType<PdfDocument>("Readected", 1, 0, "PdfDocument");

    PdfDocument pdfDoc;
    PdfImageProvider *provider = new PdfImageProvider(&pdfDoc);
    FileHelper fileHelper;

    QQmlApplicationEngine engine;
    engine.addImageProvider(QStringLiteral("pdf"), provider);
    engine.rootContext()->setContextProperty(QStringLiteral("pdfDocument"), &pdfDoc);
    engine.rootContext()->setContextProperty(QStringLiteral("fileHelper"), &fileHelper);
    engine.rootContext()->setContextProperty(QStringLiteral("appVersion"), app.applicationVersion());

    const QPalette pal = app.palette();
    auto hex = [](const QColor &c) { return c.name(QColor::HexRgb); };
    engine.rootContext()->setContextProperty(QStringLiteral("sysWindow"), hex(pal.color(QPalette::Window)));
    engine.rootContext()->setContextProperty(QStringLiteral("sysBase"), hex(pal.color(QPalette::Base)));
    engine.rootContext()->setContextProperty(QStringLiteral("sysButton"), hex(pal.color(QPalette::Button)));
    engine.rootContext()->setContextProperty(QStringLiteral("sysText"), hex(pal.color(QPalette::WindowText)));
    engine.rootContext()->setContextProperty(QStringLiteral("sysHighlight"), hex(pal.color(QPalette::Highlight)));
    engine.rootContext()->setContextProperty(QStringLiteral("sysHighlightedText"), hex(pal.color(QPalette::HighlightedText)));
    engine.rootContext()->setContextProperty(QStringLiteral("sysMid"), hex(pal.color(QPalette::Mid)));

    QObject::connect(&pdfDoc, &PdfDocument::sourceChanged, provider, [provider, &pdfDoc]() {
        provider->setDocument(&pdfDoc);
        provider->clearCache();
    });

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    const QString pdfPath = findPdfArgument(app.arguments());
    if (!pdfPath.isEmpty()) {
        QTimer::singleShot(0, &pdfDoc, [&pdfDoc, pdfPath]() {
            pdfDoc.setSource(pdfPath);
        });
    }

    return app.exec();
}
