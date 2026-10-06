# Readected

**Beautiful Material Design PDF reader for Linux** — Qt6 + QML + Poppler.

![Qt6](https://img.shields.io/badge/Qt-6-green) ![License](https://img.shields.io/badge/license-GPLv3-blue) ![Platform](https://img.shields.io/badge/platform-Linux-orange)

## Features

- **Material Design UI** with 14 themes (including System / qt6ct palette)
- Fast PDF rendering via **Poppler-Qt6** with virtualized continuous scroll
- Resizable sidebar (TOC + bookmarks) with word-wrap titles
- Full-text search, zoom (Ctrl+wheel), single/continuous page modes
- Night mode (soft tint overlay)
- Drag & drop + CLI file argument
- Keyboard shortcuts, recent files, i18n-ready
- Separate **readected-updater** GUI (GitHub commits check + install script)
- No telemetry

## Quick install

```bash
git clone https://github.com/SnowyFedora/Readected.git
cd Readected
./install.sh
```

The script checks dependencies, builds with CMake+Ninja and installs both `readected` and `readected-updater`.

### Dependencies (Arch)

```bash
sudo pacman -S qt6-base qt6-declarative qt6-quickcontrols2 cmake ninja pkgconf poppler-qt6
```

### Dependencies (Debian/Ubuntu)

```bash
sudo apt install qt6-base-dev qt6-declarative-dev qt6-tools-dev cmake ninja-build pkg-config libpoppler-qt6-dev
```

## Usage

```bash
readected                      # open empty window
readected document.pdf         # open file from CLI
# or drag-and-drop a PDF onto the window
```

Updater:

```bash
readected-updater
```

## Themes

14 built-in themes: System (qt6ct / desktop palette), Material Light/Dark, Catppuccin Latte/Mocha, Gruvbox Light/Dark, Nord, Dracula, Tokyo Night, Solarized Light/Dark, One Dark, Marxism, and more.

Switch via the toolbar or settings. System theme follows qt6ct / KDE / GNOME palette when available.

## Build manually

```bash
mkdir build && cd build
cmake -G Ninja ..
ninja
./readected
```

## Project structure

```
Readected/
├── CMakeLists.txt
├── install.sh
├── resources.qrc / updater.qrc
├── src/
│   ├── main.cpp / updatermain.cpp
│   ├── pdfdocument.*          # Poppler wrapper
│   ├── pdfimageprovider.*     # QQuickImageProvider + LRU cache
│   ├── updaterbackend.*       # GitHub API + install process
│   └── filehelper.h
└── qml/
    ├── Main.qml
    ├── components/            # SidePanel, PageArea, AppToolbar, …
    ├── themes/ThemeManager.qml
    └── updater/UpdaterMain.qml
```

## License

GPLv3 — see [LICENSE](LICENSE).
