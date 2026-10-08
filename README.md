# Readected

<p align="center">
  <strong>Modern PDF reader for Linux</strong><br>
  Qt6 · QML · Poppler
</p>

<p align="center">
  <a href="#english">English</a> ·
  <a href="#русский">Русский</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Qt-6-41CD52?style=flat-square&logo=qt&logoColor=white" alt="Qt6">
  <img src="https://img.shields.io/badge/license-GPLv3-blue?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/platform-Linux-FCC624?style=flat-square&logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/version-1.5.5-informational?style=flat-square" alt="Version">
</p>

---

<a id="english"></a>

## English

### Overview

**Readected** is a lightweight, keyboard-friendly PDF reader for Linux. It uses Qt6/QML for the interface and Poppler for rendering — fast continuous scrolling, a resizable sidebar, bookmarks, notes, and a set of carefully tuned themes.

No telemetry. No account required.

### Features

| Area | Details |
|------|---------|
| **Rendering** | Poppler-Qt6, virtualized continuous scroll, single-page mode |
| **Navigation** | Outline (TOC), user bookmarks, full-text search |
| **Annotations** | Bookmarks (Ctrl+D), sticky notes in edit mode (Ctrl+E) |
| **UI** | Flat toolbar, resizable sidebar, 14 themes including System / qt6ct |
| **Input** | Drag-and-drop, CLI file argument, keyboard shortcuts |
| **Data** | Marks stored under `~/.config/Readected/marks/` (not next to PDFs) |
| **Updates** | CLI: `readected update` (no separate GUI updater) |

### Requirements

- Linux (x86_64 / aarch64)
- Qt 6 (Core, Gui, Qml, Quick, QuickControls2, Widgets)
- Poppler with Qt6 bindings (`poppler-qt6`)
- CMake ≥ 3.21, Ninja, C++17 compiler

### Install

**Home directory (recommended, no root for the binary):**

```bash
git clone https://github.com/SnowyFedora/Readected.git
cd Readected
chmod +x INSTALL_HOME.sh
./INSTALL_HOME.sh
```

Binary: `~/.local/bin/readected`  
Ensure `~/.local/bin` is on your `PATH`.

**System-wide (`/usr/local`):**

```bash
./install.sh
```

The installer detects the package manager (pacman, apt, dnf, zypper, xbps, emerge) and can install build dependencies automatically.

#### Manual dependencies

**Arch / Manjaro**

```bash
sudo pacman -S qt6-base qt6-declarative qt6-quickcontrols2 poppler-qt6 cmake ninja base-devel pkgconf
```

**Debian / Ubuntu**

```bash
sudo apt install qt6-base-dev qt6-declarative-dev qt6-tools-dev \
  libpoppler-qt6-dev cmake ninja-build build-essential pkg-config
```

**Fedora**

```bash
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel \
  poppler-qt6-devel cmake ninja-build gcc-c++ pkgconf-pkg-config
```

### Usage

```bash
readected                 # empty window
readected document.pdf    # open a file
readected version         # print version
readected help            # CLI help
readected update          # reinstall from GitHub main
readected uninstall       # remove binaries (keeps bookmarks)
```

Or build and run from the source tree without installing:

```bash
./run.sh
```

### Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+O` | Open PDF |
| `Ctrl+W` | Close document |
| `Ctrl+B` | Toggle sidebar |
| `Ctrl+D` | Add bookmark for current page |
| `Ctrl+E` | Toggle note edit mode |
| `Ctrl+F` | Search |
| `Ctrl+=` / `Ctrl+-` | Zoom in / out |
| `Ctrl+0` | Fit width |
| `←` / `→` | Previous / next page |
| `Ctrl+Q` | Quit |

### Themes

Fourteen built-in themes, including:

- **System** — follows the desktop / qt6ct palette  
- Material Light & Dark  
- Catppuccin Latte & Mocha  
- Gruvbox Light & Dark  
- Nord, Dracula, Tokyo Night  
- Solarized Light & Dark, One Dark, Marxism, Graphite  

Switch from the toolbar theme menu. Preference is saved automatically.

### Project layout

```
Readected/
├── CMakeLists.txt
├── INSTALL_HOME.sh          # install to ~/.local
├── install.sh               # multi-distro install (system or prefix)
├── run.sh                   # build & run without install
├── resources.qrc
├── src/
│   ├── main.cpp             # app entry + CLI subcommands
│   ├── pdfdocument.*        # Poppler document wrapper
│   ├── pdfimageprovider.*   # page image provider (LRU cache)
│   └── filehelper.h         # file dialog + marks I/O
└── qml/
    ├── Main.qml
    ├── components/          # SidePanel, PageArea, SearchBar, …
    └── themes/              # ThemeManager + theme modules
```

### Build from source

```bash
mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/.local" ..
ninja
cmake --install .
```

### License

[GPLv3](LICENSE) — free software. You may redistribute and modify it under the terms of the GNU General Public License version 3.

### Contributing

Issues and pull requests are welcome:  
https://github.com/SnowyFedora/Readected

---

<a id="русский"></a>

## Русский

### Обзор

**Readected** — лёгкий PDF-ридер для Linux с удобной клавиатурной навигацией. Интерфейс на Qt6/QML, отрисовка через Poppler: быстрая лента страниц, изменяемая боковая панель, закладки, заметки и набор аккуратных тем.

Без телеметрии. Без аккаунтов.

### Возможности

| Область | Описание |
|---------|----------|
| **Отрисовка** | Poppler-Qt6, виртуализированная лента, режим одной страницы |
| **Навигация** | Оглавление, пользовательские закладки, полнотекстовый поиск |
| **Разметка** | Закладки (Ctrl+D), заметки в режиме правки (Ctrl+E) |
| **Интерфейс** | Плоский тулбар, ресайз панели, 14 тем (включая System / qt6ct) |
| **Ввод** | Drag-and-drop, аргумент файла в CLI, горячие клавиши |
| **Данные** | Метки в `~/.config/Readected/marks/` (не рядом с PDF) |
| **Обновления** | CLI: `readected update` (отдельного GUI-апдейтера нет) |

### Требования

- Linux (x86_64 / aarch64)
- Qt 6 (Core, Gui, Qml, Quick, QuickControls2, Widgets)
- Poppler с привязками Qt6 (`poppler-qt6`)
- CMake ≥ 3.21, Ninja, компилятор C++17

### Установка

**В домашний каталог (рекомендуется, для бинарника root не нужен):**

```bash
git clone https://github.com/SnowyFedora/Readected.git
cd Readected
chmod +x INSTALL_HOME.sh
./INSTALL_HOME.sh
```

Бинарник: `~/.local/bin/readected`  
Убедитесь, что `~/.local/bin` есть в `PATH`.

**В систему (`/usr/local`):**

```bash
./install.sh
```

Скрипт определяет пакетный менеджер (pacman, apt, dnf, zypper, xbps, emerge) и при необходимости ставит зависимости сам.

#### Зависимости вручную

**Arch / Manjaro**

```bash
sudo pacman -S qt6-base qt6-declarative qt6-quickcontrols2 poppler-qt6 cmake ninja base-devel pkgconf
```

**Debian / Ubuntu**

```bash
sudo apt install qt6-base-dev qt6-declarative-dev qt6-tools-dev \
  libpoppler-qt6-dev cmake ninja-build build-essential pkg-config
```

**Fedora**

```bash
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel \
  poppler-qt6-devel cmake ninja-build gcc-c++ pkgconf-pkg-config
```

### Использование

```bash
readected                 # пустое окно
readected document.pdf    # открыть файл
readected version         # версия
readected help            # справка CLI
readected update          # переустановка с GitHub main
readected uninstall       # удалить бинарники (закладки сохраняются)
```

Сборка и запуск из исходников без установки:

```bash
./run.sh
```

### Горячие клавиши

| Сочетание | Действие |
|-----------|----------|
| `Ctrl+O` | Открыть PDF |
| `Ctrl+W` | Закрыть документ |
| `Ctrl+B` | Показать / скрыть боковую панель |
| `Ctrl+D` | Закладка на текущую страницу |
| `Ctrl+E` | Режим заметок |
| `Ctrl+F` | Поиск |
| `Ctrl+=` / `Ctrl+-` | Масштаб + / − |
| `Ctrl+0` | По ширине |
| `←` / `→` | Предыдущая / следующая страница |
| `Ctrl+Q` | Выход |

### Темы

Четырнадцать встроенных тем, в том числе:

- **System** — палитра рабочего стола / qt6ct  
- Material Light и Dark  
- Catppuccin Latte и Mocha  
- Gruvbox Light и Dark  
- Nord, Dracula, Tokyo Night  
- Solarized Light и Dark, One Dark, Marxism, Graphite  

Переключение — в меню «Тема» на панели. Выбор сохраняется.

### Структура проекта

```
Readected/
├── CMakeLists.txt
├── INSTALL_HOME.sh          # установка в ~/.local
├── install.sh               # multi-distro (система или prefix)
├── run.sh                   # сборка и запуск без install
├── resources.qrc
├── src/
│   ├── main.cpp             # точка входа + CLI
│   ├── pdfdocument.*        # обёртка Poppler
│   ├── pdfimageprovider.*   # провайдер страниц (LRU-кэш)
│   └── filehelper.h         # диалог файлов + I/O меток
└── qml/
    ├── Main.qml
    ├── components/          # SidePanel, PageArea, SearchBar, …
    └── themes/              # ThemeManager и модули тем
```

### Сборка вручную

```bash
mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/.local" ..
ninja
cmake --install .
```

### Лицензия

[GPLv3](LICENSE) — свободное ПО. Распространение и изменение допускаются на условиях GNU General Public License версии 3.

### Участие

Багрепорты и pull request’ы приветствуются:  
https://github.com/SnowyFedora/Readected
