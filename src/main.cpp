#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QFileInfo>
#include <QUrl>
#include <QTimer>

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
    app.setApplicationName("Readected");
    app.setOrganizationName("Proletariat");
    app.setApplicationVersion("1.1.0");
    app.setDesktopFileName(QStringLiteral("readected"));

    QQuickStyle::setStyle("Fusion");

    qmlRegisterType<PdfDocument>("Readected", 1, 0, "PdfDocument");

    PdfDocument pdfDoc;
    PdfImageProvider *provider = new PdfImageProvider(&pdfDoc);
    FileHelper fileHelper;

    QQmlApplicationEngine engine;
    engine.addImageProvider("pdf", provider);
    engine.rootContext()->setContextProperty("pdfDocument", &pdfDoc);
    engine.rootContext()->setContextProperty("fileHelper", &fileHelper);

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
