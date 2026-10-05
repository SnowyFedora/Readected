cmake_minimum_required(VERSION 3.21)
project(Readected VERSION 1.1.0 LANGUAGES CXX)

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
)

find_package(PkgConfig REQUIRED)
pkg_check_modules(POPPLER_QT6 REQUIRED poppler-qt6)

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

install(TARGETS readected RUNTIME DESTINATION bin)
