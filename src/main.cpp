#include <QApplication>
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
    QApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("Readected"));
    app.setOrganizationName(QStringLiteral("Proletariat"));
    app.setApplicationVersion(QStringLiteral("1.3.0"));
    app.setDesktopFileName(QStringLiteral("readected"));

    // Material Design (qt6ct still works with System theme for colors)
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
