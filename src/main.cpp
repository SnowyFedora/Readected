#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QCommandLineParser>
#include <QFileInfo>
#include <QPalette>
#include <QDir>
#include <QIcon>

#include "pdfdocument.h"
#include "pdfimageprovider.h"
#include "filehelper.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName("Readected");
    app.setApplicationVersion("1.3.0");
    app.setOrganizationName("SnowyFedora");
    app.setDesktopFileName("readected");

    // Material style; respect qt6ct / system theme when available
    QQuickStyle::setStyle("Material");

    QCommandLineParser parser;
    parser.setApplicationDescription("Readected — Material Design PDF Reader");
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument("file", "PDF file to open", "[file]");
    parser.process(app);

    QString initialFile;
    const QStringList args = parser.positionalArguments();
    if (!args.isEmpty()) {
        QFileInfo fi(args.first());
        if (fi.exists() && fi.isFile())
            initialFile = fi.absoluteFilePath();
    }

    PdfDocument pdfDocument;
    FileHelper fileHelper;

    QQmlApplicationEngine engine;

    // Export system palette for QML "System" theme
    QPalette pal = app.palette();
    QVariantMap systemPalette;
    systemPalette["window"] = pal.color(QPalette::Window);
    systemPalette["windowText"] = pal.color(QPalette::WindowText);
    systemPalette["base"] = pal.color(QPalette::Base);
    systemPalette["text"] = pal.color(QPalette::Text);
    systemPalette["button"] = pal.color(QPalette::Button);
    systemPalette["buttonText"] = pal.color(QPalette::ButtonText);
    systemPalette["highlight"] = pal.color(QPalette::Highlight);
    systemPalette["highlightedText"] = pal.color(QPalette::HighlightedText);
    systemPalette["mid"] = pal.color(QPalette::Mid);
    systemPalette["dark"] = pal.color(QPalette::Dark);
    systemPalette["light"] = pal.color(QPalette::Light);
    systemPalette["link"] = pal.color(QPalette::Link);

    engine.rootContext()->setContextProperty("pdfDocument", &pdfDocument);
    engine.rootContext()->setContextProperty("fileHelper", &fileHelper);
    engine.rootContext()->setContextProperty("systemPalette", systemPalette);
    engine.rootContext()->setContextProperty("initialFile", initialFile);

    engine.addImageProvider("pdf", new PdfImageProvider(&pdfDocument));

    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
