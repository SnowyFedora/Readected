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

# ---- Main reader ----
qt_add_executable(readected
    src/main.cpp
    src/pdfdocument.h
    src/pdfdocument.cpp
    src/pdfimageprovider.h
    src/pdfimageprovider.cpp
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
    ${POPPLER_QT6_LIBRARIES}
)

target_compile_options(readected PRIVATE ${POPPLER_QT6_CFLAGS_OTHER})

# ---- Updater (Material GUI) ----
qt_add_executable(readected-updater
    src/updatermain.cpp
    src/updaterbackend.h
    src/updaterbackend.cpp
    updater.qrc
)

target_include_directories(readected-updater PRIVATE src)

target_link_libraries(readected-updater PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Widgets
    Qt6::Network
)

install(TARGETS readected readected-updater RUNTIME DESTINATION bin)
