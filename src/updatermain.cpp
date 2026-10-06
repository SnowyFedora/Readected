#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "updaterbackend.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("Readected Updater"));
    app.setOrganizationName(QStringLiteral("Proletariat"));
    app.setApplicationVersion(QStringLiteral("1.3.0"));

    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE"))
        QQuickStyle::setStyle(QStringLiteral("Material"));

    UpdaterBackend backend;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("updater"), &backend);
    engine.rootContext()->setContextProperty(QStringLiteral("appVersion"), app.applicationVersion());
    engine.load(QUrl(QStringLiteral("qrc:/qml/updater/UpdaterMain.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}
