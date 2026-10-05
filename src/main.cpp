#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "pdfdocument.h"
#include "pdfimageprovider.h"
#include "filehelper.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName("Readected");
    app.setOrganizationName("Proletariat");
    app.setApplicationVersion("1.1.0");

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

    return app.exec();
}
