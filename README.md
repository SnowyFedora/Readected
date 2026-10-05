# Readected

**PDF Reader for the Proletariat**

A fast, minimalist PDF reader for Linux. Built with **Qt 6**, **QML**, and **Poppler**.  
No telemetry. No accounts. No bloat.

```
      _______
     /       \         ⚒
    |  BOOK   |    📖  Readected
    | +HAMMER |
     \_______/
```

---

## Features

- Native PDF rendering via **Poppler**
- **Virtualized** continuous scrolling (only visible pages are rendered)
- Table of contents sidebar
- Full-text search
- Fit width / fit page / zoom
- Continuous or single-page mode
- **5 themes**: Marxism, Gruvbox Dark/Light, Catppuccin Mocha/Latte
- **UI languages**: English, Русский
- System file dialog (KDE/GNOME native)
- Drag & drop
- Chapter name in status bar (from PDF outline)
- Document title from PDF metadata
- Keyboard shortcuts
- Remembers theme, language, zoom, and layout

### Shortcuts

| Key | Action |
|-----|--------|
| `Ctrl+O` | Open |
| `Ctrl+W` | Close |
| `Ctrl+Q` | Quit |
| `Ctrl+F` | Search |
| `Ctrl+G` | Go to page |
| `Ctrl++` / `Ctrl+-` | Zoom |
| `Ctrl+0` | Reset zoom |
| `←` `→` | Previous / next page |
| `Home` / `End` | First / last page |
| `F11` | Fullscreen |
| `Esc` | Close search / exit fullscreen |

---

## Dependencies

### Arch Linux

```bash
sudo pacman -S qt6-base qt6-declarative qt6-tools poppler-qt6 cmake ninja pkgconf gcc
```

### Fedora

```bash
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel poppler-qt6-devel cmake ninja-build gcc-c++
```

### Debian / Ubuntu

```bash
sudo apt install qt6-base-dev qt6-declarative-dev libpoppler-qt6-dev cmake ninja-build g++ pkg-config
```

---

## Install

```bash
git clone https://github.com/SnowyFedora/Readected.git
cd Readected
./install.sh
```

This will configure, build (Release), install to `/usr`, and create a desktop entry.

### Options

```bash
./install.sh              # full install
./install.sh build        # build only
./install.sh install      # install only (after build)
./install.sh uninstall    # remove from system

PREFIX=/usr/local ./install.sh   # custom prefix
```

### Manual build

```bash
mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..
ninja
sudo ninja install
```

---

## Uninstall

```bash
./install.sh uninstall
# or:
sudo rm /usr/bin/readected
sudo rm /usr/share/applications/readected.desktop
```

---

## Philosophy

> Knowledge must be accessible to all.  
> Readected is a tool for workers, not for corporations.

- Free software (GPLv3)
- No telemetry
- No network access required
- Works offline forever

---

## Tech stack

| Component | Technology |
|-----------|------------|
| UI | Qt 6 Quick / QML |
| PDF engine | Poppler (Qt6 bindings) |
| Build | CMake + Ninja |
| Platform | Linux |

---

## License

[GNU General Public License v3.0](LICENSE)

---

## Русский

**Readected** — минималистичная PDF-читалка для Linux на Qt 6 + QML + Poppler.

### Возможности

- Быстрый рендер (виртуализация страниц)
- Оглавление, поиск, масштаб
- 5 тем оформления
- Русский и English
- Системный диалог открытия файлов
- Drag-and-drop, горячие клавиши
- Без телеметрии

### Установка (Arch)

```bash
sudo pacman -S qt6-base qt6-declarative qt6-tools poppler-qt6 cmake ninja pkgconf gcc
git clone https://github.com/SnowyFedora/Readected.git
cd Readected
./install.sh
```

Запуск: `readected` или из меню приложений.

### Лицензия

GPLv3 — свободное ПО.
