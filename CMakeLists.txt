cmake_minimum_required(VERSION 3.21)
project(Readected VERSION 1.3.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Widgets
    Network
)

find_package(PkgConfig REQUIRED)
pkg_check_modules(POPPLER_QT6 REQUIRED poppler-qt6)

# ─── Main application ───────────────────────────────────────────────────────
qt_add_executable(readected
    src/main.cpp
    src/pdfdocument.cpp
    src/pdfdocument.h
    src/pdfimageprovider.cpp
    src/pdfimageprovider.h
    src/filehelper.h
    resources.qrc
)

target_include_directories(readected PRIVATE
    ${POPPLER_QT6_INCLUDE_DIRS}
    src
)

target_link_libraries(readected PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Widgets
    Qt6::Network
    ${POPPLER_QT6_LIBRARIES}
)

# ─── Updater application ────────────────────────────────────────────────────
qt_add_executable(readected-updater
    src/updatermain.cpp
    src/updaterbackend.cpp
    src/updaterbackend.h
    updater.qrc
)

target_link_libraries(readected-updater PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
)

# ─── Install ────────────────────────────────────────────────────────────────
include(GNUInstallDirs)
install(TARGETS readected readected-updater
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
