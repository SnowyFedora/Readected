# Readected

**Minimalist PDF reader for Linux.**  
Qt 6 · QML · Material Design · Poppler · GPLv3

No telemetry. No accounts. No bloat.

```
git clone https://github.com/SnowyFedora/Readected.git
cd Readected && ./install.sh
```

---

## Why Readected?

Desktop PDF readers are often heavy, slow to start, or full of features you never use.  
Readected is built for **reading**: fast page rendering, a clean Material UI, and themes that match your desktop (including **qt6ct**).

| | |
|---|---|
| **Engine** | Poppler (Qt 6 bindings) |
| **UI** | Qt Quick Controls 2 — Material |
| **Platform** | Linux |
| **License** | [GPLv3](LICENSE) |

---

## Features

- **Virtualized continuous scroll** — only visible pages are rendered
- **Outline sidebar** — resizable, word-wrap, tooltips for long titles
- **Search** across the document
- **Fit width / fit page / zoom** (also `Ctrl` + mouse wheel)
- Continuous or single-page mode
- **Night mode** (soft page tint)
- **14 themes** + **System (qt6ct)** palette
- **English** and **Русский** UI
- Native system file dialog, drag-and-drop
- Chapter name in the status bar (from PDF outline)
- Document title from PDF metadata
- Recent files list
- Opens files from the file manager (`readected file.pdf`)
- **Readected Updater** — Material GUI to check GitHub and reinstall

### Themes

`System (qt6ct)` · Marxism · Gruvbox Dark/Light · Catppuccin Mocha/Latte · Nord · Dracula · Tokyo Night · One Dark · Rosé Pine · Everforest · Solarized Dark/Light

### Keyboard shortcuts

| Key | Action |
|-----|--------|
| `Ctrl+O` | Open |
| `Ctrl+W` | Close |
| `Ctrl+Q` | Quit |
| `Ctrl+F` | Search |
| `Ctrl+G` | Go to page |
| `Ctrl++` / `Ctrl+-` | Zoom in / out |
| `Ctrl+0` | Reset zoom |
| `Ctrl+I` | Night mode |
| `←` `→` | Previous / next page |
| `Home` / `End` | First / last page |
| `F11` | Fullscreen |
| `Esc` | Close search / exit fullscreen |

---

## Install

### Dependencies

**Arch Linux**

```bash
sudo pacman -S qt6-base qt6-declarative qt6-tools poppler-qt6 cmake ninja pkgconf gcc
```

**Fedora**

```bash
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel poppler-qt6-devel cmake ninja-build gcc-c++
```

**Debian / Ubuntu**

```bash
sudo apt install qt6-base-dev qt6-declarative-dev libpoppler-qt6-dev cmake ninja-build g++ pkg-config
```

### One-command install

```bash
git clone https://github.com/SnowyFedora/Readected.git
cd Readected
chmod +x install.sh
./install.sh
```

This builds a **Release** binary, installs to `/usr/bin/readected` and `/usr/bin/readected-updater`, and adds desktop entries.

```bash
./install.sh              # full install
./install.sh build        # compile only
./install.sh uninstall    # remove from system
PREFIX=/usr/local ./install.sh
```

### Manual build

```bash
mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..
ninja
sudo ninja install
```

---

## qt6ct (system colors)

```bash
sudo pacman -S qt6ct   # Arch
echo 'export QT_QPA_PLATFORMTHEME=qt6ct' >> ~/.profile
```

In Readected: **Theme → System (qt6ct)**. Colors follow your qt6ct / desktop palette.

---

## Updater

```bash
readected-updater
```

Or from the application menu: **Readected Updater**.

Checks the latest commit on GitHub, downloads the source archive, and runs `install.sh`.  
Sudo may be required during install.

---

## Project layout

```
Readected/
├── src/                 # C++ (Poppler backend, image provider, updater)
├── qml/                 # UI
│   ├── Main.qml
│   ├── components/
│   ├── themes/
│   └── updater/
├── CMakeLists.txt
├── install.sh
└── README.md
```

---

## Philosophy

> Knowledge must be accessible to all.  
> Readected is a tool for workers, not for corporations.

- Free software (GPLv3)
- No telemetry
- No mandatory network access for reading
- Offline by default

---

## Contributing

Issues and pull requests are welcome.

1. Fork the repo  
2. Create a branch  
3. Open a PR against `main`

---

## License

[GNU General Public License v3.0](LICENSE)

---

## Русский

**Readected** — минималистичная PDF-читалка для Linux (Qt 6, Material, Poppler).

**Возможности:** быстрый скролл, оглавление с изменяемой шириной, поиск, 14 тем, qt6ct, русский/English, ночной режим, отдельный GUI-апдейтер.

**Установка (Arch):**

```bash
sudo pacman -S qt6-base qt6-declarative qt6-tools poppler-qt6 cmake ninja pkgconf gcc
git clone https://github.com/SnowyFedora/Readected.git
cd Readected && ./install.sh
```

Запуск: `readected` · обновление: `readected-updater`
