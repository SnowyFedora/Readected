pragma Singleton
import QtQuick

QtObject {
    id: root

    property string current: "system"

    readonly property var themeIds: [
        "system",
        "marxism",
        "gruvbox_dark", "gruvbox_light",
        "catppuccin_mocha", "catppuccin_latte",
        "nord", "dracula", "tokyo_night",
        "onedark", "rosepine", "everforest",
        "solarized_dark", "solarized_light"
    ]

    readonly property var themeNames: ({
        "system": "System (qt6ct)",
        "marxism": "Marxism",
        "gruvbox_dark": "Gruvbox Dark",
        "gruvbox_light": "Gruvbox Light",
        "catppuccin_mocha": "Catppuccin Mocha",
        "catppuccin_latte": "Catppuccin Latte",
        "nord": "Nord",
        "dracula": "Dracula",
        "tokyo_night": "Tokyo Night",
        "onedark": "One Dark",
        "rosepine": "Rosé Pine",
        "everforest": "Everforest",
        "solarized_dark": "Solarized Dark",
        "solarized_light": "Solarized Light"
    })

    readonly property var palette: ({
        "marxism": {
            bg: "#121212", surface: "#1e1e1e", surface2: "#2c2c2c", surface3: "#383838",
            primary: "#cf6679", primaryHover: "#e57373", onPrimary: "#000000",
            text: "#e0e0e0", textDim: "#9e9e9e", border: "#333333",
            accent: "#ff5252", pageBg: "#0d0d0d", radius: 12, elev: 4
        },
        "gruvbox_dark": {
            bg: "#1d2021", surface: "#282828", surface2: "#3c3836", surface3: "#504945",
            primary: "#fe8019", primaryHover: "#fabd2f", onPrimary: "#1d2021",
            text: "#ebdbb2", textDim: "#a89984", border: "#3c3836",
            accent: "#fb4934", pageBg: "#1d2021", radius: 12, elev: 4
        },
        "gruvbox_light": {
            bg: "#fbf1c7", surface: "#f2e5bc", surface2: "#ebdbb2", surface3: "#d5c4a1",
            primary: "#af3a03", primaryHover: "#9d0006", onPrimary: "#ffffff",
            text: "#3c3836", textDim: "#665c54", border: "#d5c4a1",
            accent: "#cc241d", pageBg: "#f9f5d7", radius: 12, elev: 2
        },
        "catppuccin_mocha": {
            bg: "#1e1e2e", surface: "#181825", surface2: "#313244", surface3: "#45475a",
            primary: "#cba6f7", primaryHover: "#f5c2e7", onPrimary: "#1e1e2e",
            text: "#cdd6f4", textDim: "#a6adc8", border: "#313244",
            accent: "#f38ba8", pageBg: "#11111b", radius: 16, elev: 4
        },
        "catppuccin_latte": {
            bg: "#eff1f5", surface: "#e6e9ef", surface2: "#dce0e8", surface3: "#ccd0da",
            primary: "#8839ef", primaryHover: "#ea76cb", onPrimary: "#ffffff",
            text: "#4c4f69", textDim: "#6c6f85", border: "#ccd0da",
            accent: "#d20f39", pageBg: "#e6e9ef", radius: 16, elev: 2
        },
        "nord": {
            bg: "#2e3440", surface: "#3b4252", surface2: "#434c5e", surface3: "#4c566a",
            primary: "#88c0d0", primaryHover: "#8fbcbb", onPrimary: "#2e3440",
            text: "#eceff4", textDim: "#d8dee9", border: "#434c5e",
            accent: "#81a1c1", pageBg: "#2e3440", radius: 12, elev: 4
        },
        "dracula": {
            bg: "#282a36", surface: "#21222c", surface2: "#44475a", surface3: "#6272a4",
            primary: "#bd93f9", primaryHover: "#ff79c6", onPrimary: "#282a36",
            text: "#f8f8f2", textDim: "#6272a4", border: "#44475a",
            accent: "#ff5555", pageBg: "#282a36", radius: 12, elev: 4
        },
        "tokyo_night": {
            bg: "#1a1b26", surface: "#16161e", surface2: "#24283b", surface3: "#414868",
            primary: "#7aa2f7", primaryHover: "#bb9af7", onPrimary: "#1a1b26",
            text: "#c0caf5", textDim: "#565f89", border: "#24283b",
            accent: "#f7768e", pageBg: "#1a1b26", radius: 12, elev: 4
        },
        "onedark": {
            bg: "#282c34", surface: "#21252b", surface2: "#2c313c", surface3: "#3e4451",
            primary: "#61afef", primaryHover: "#c678dd", onPrimary: "#282c34",
            text: "#abb2bf", textDim: "#5c6370", border: "#2c313c",
            accent: "#e06c75", pageBg: "#282c34", radius: 12, elev: 4
        },
        "rosepine": {
            bg: "#191724", surface: "#1f1d2e", surface2: "#26233a", surface3: "#403d52",
            primary: "#c4a7e7", primaryHover: "#ebbcba", onPrimary: "#191724",
            text: "#e0def4", textDim: "#908caa", border: "#26233a",
            accent: "#eb6f92", pageBg: "#191724", radius: 16, elev: 4
        },
        "everforest": {
            bg: "#2d353b", surface: "#343f44", surface2: "#3d484d", surface3: "#475258",
            primary: "#a7c080", primaryHover: "#83c092", onPrimary: "#2d353b",
            text: "#d3c6aa", textDim: "#859289", border: "#3d484d",
            accent: "#e67e80", pageBg: "#2d353b", radius: 12, elev: 4
        },
        "solarized_dark": {
            bg: "#002b36", surface: "#073642", surface2: "#586e75", surface3: "#657b83",
            primary: "#268bd2", primaryHover: "#2aa198", onPrimary: "#fdf6e3",
            text: "#93a1a1", textDim: "#586e75", border: "#073642",
            accent: "#cb4b16", pageBg: "#002b36", radius: 8, elev: 3
        },
        "solarized_light": {
            bg: "#fdf6e3", surface: "#eee8d5", surface2: "#93a1a1", surface3: "#839496",
            primary: "#268bd2", primaryHover: "#2aa198", onPrimary: "#fdf6e3",
            text: "#657b83", textDim: "#93a1a1", border: "#eee8d5",
            accent: "#cb4b16", pageBg: "#eee8d5", radius: 8, elev: 2
        }
    })

    property color sysWindow: "#121212"
    property color sysBase: "#1e1e1e"
    property color sysButton: "#2c2c2c"
    property color sysText: "#e0e0e0"
    property color sysBrightText: "#ffffff"
    property color sysHighlight: "#bb86fc"
    property color sysHighlightedText: "#000000"
    property color sysMid: "#404040"

    function _p(key) {
        if (current === "system") {
            switch (key) {
            case "bg": return sysWindow
            case "surface": return sysBase
            case "surface2": return sysButton
            case "surface3": return sysMid
            case "primary": return sysHighlight
            case "primaryHover": return Qt.lighter(sysHighlight, 1.12)
            case "onPrimary": return sysHighlightedText
            case "text": return sysText
            case "textDim": return Qt.rgba(sysText.r, sysText.g, sysText.b, 0.62)
            case "border": return sysMid
            case "accent": return sysHighlight
            case "pageBg": return sysWindow
            case "radius": return 12
            case "elev": return 4
            }
        }
        var t = palette[current]
        return t ? t[key] : palette["marxism"][key]
    }

    property color bg: _p("bg")
    property color surface: _p("surface")
    property color surface2: _p("surface2")
    property color surface3: _p("surface3")
    property color primary: _p("primary")
    property color primaryHover: _p("primaryHover")
    property color onPrimary: _p("onPrimary")
    property color text: _p("text")
    property color textDim: _p("textDim")
    property color border: _p("border")
    property color accent: _p("accent")
    property color pageBg: _p("pageBg")
    property real radius: Number(_p("radius")) || 12
    property real elev: Number(_p("elev")) || 4

    property bool isDark: {
        if (current === "system")
            return (sysWindow.r + sysWindow.g + sysWindow.b) < 1.5
        return ["marxism","gruvbox_dark","catppuccin_mocha","nord","dracula",
                "tokyo_night","onedark","rosepine","everforest","solarized_dark"].indexOf(current) >= 0
    }

    function setTheme(name) {
        if (name === "system" || palette[name] !== undefined)
            current = name
    }

    function displayName(id) {
        return themeNames[id] || id
    }
}
