#!/usr/bin/env bash
# Readected — build & install script
set -euo pipefail

PREFIX="${PREFIX:-/usr}"
BUILD_TYPE="${BUILD_TYPE:-Release}"
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}==>${NC} $*"; }
ok()    { echo -e "${GREEN}==>${NC} $*"; }
die()   { echo -e "${RED}error:${NC} $*" >&2; exit 1; }

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "'$1' not found. Install build dependencies first."
}

check_deps() {
    info "Checking dependencies..."
    need_cmd cmake
    need_cmd ninja
    need_cmd pkg-config
    need_cmd c++

    if ! pkg-config --exists poppler-qt6; then
        die "poppler-qt6 not found (pkg-config). On Arch: sudo pacman -S poppler-qt6"
    fi
    ok "Tools OK"
}

configure() {
    info "Configuring (prefix=${PREFIX}, type=${BUILD_TYPE})..."
    mkdir -p "${BUILD_DIR}"
    cmake -S "${SCRIPT_DIR}" -B "${BUILD_DIR}" \
        -G Ninja \
        -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}"
    ok "Configured"
}

build() {
    info "Building (${JOBS} jobs)..."
    cmake --build "${BUILD_DIR}" -j "${JOBS}"
    ok "Build complete"
}

install_app() {
    info "Installing to ${PREFIX}..."
    if [[ "${PREFIX}" == /usr* ]] || [[ "${PREFIX}" == /opt* ]]; then
        sudo cmake --install "${BUILD_DIR}"
    else
        cmake --install "${BUILD_DIR}"
    fi

    local apps_dir
    if [[ "${PREFIX}" == /usr ]]; then
        apps_dir="/usr/share/applications"
    else
        apps_dir="${PREFIX}/share/applications"
        mkdir -p "${apps_dir}"
    fi

    local desktop_file="${apps_dir}/readected.desktop"
    local write_cmd=(tee "${desktop_file}")
    if [[ ! -w "${apps_dir}" ]]; then
        write_cmd=(sudo tee "${desktop_file}")
    fi

    cat << DESKTOP | "${write_cmd[@]}" >/dev/null
[Desktop Entry]
Name=Readected
GenericName=PDF Reader
GenericName[ru]=PDF-читалка
Comment=PDF Reader for the Proletariat
Comment[ru]=PDF-читалка для пролетариата
Exec=readected %f
Icon=application-pdf
Terminal=false
Type=Application
Categories=Office;Viewer;
MimeType=application/pdf;
Keywords=PDF;reader;viewer;document;
StartupNotify=true
DESKTOP

    if command -v update-desktop-database >/dev/null 2>&1; then
        if [[ -w "${apps_dir}" ]]; then
            update-desktop-database "${apps_dir}" 2>/dev/null || true
        else
            sudo update-desktop-database "${apps_dir}" 2>/dev/null || true
        fi
    fi

    ok "Installed: ${PREFIX}/bin/readected"
    ok "Desktop entry: ${desktop_file}"

    local updater_desktop="${apps_dir}/readected-updater.desktop"
    local uw=(tee "${updater_desktop}")
    if [[ ! -w "${apps_dir}" ]]; then
        uw=(sudo tee "${updater_desktop}")
    fi
    cat << UDESK | "${uw[@]}" >/dev/null
[Desktop Entry]
Name=Readected Updater
Name[ru]=Обновление Readected
Comment=Update Readected PDF reader
Comment[ru]=Обновление PDF-читалки Readected
Exec=readected-updater
Icon=system-software-update
Terminal=false
Type=Application
Categories=Utility;System;
StartupNotify=true
UDESK
    ok "Updater desktop: ${updater_desktop}"
}

main() {
    echo ""
    echo "  Readected — PDF Reader for the Proletariat"
    echo "  ----------------------------------------"
    echo ""

    case "${1:-all}" in
        deps)      check_deps ;;
        configure) check_deps; configure ;;
        build)     check_deps; configure; build ;;
        install)   install_app ;;
        all)
            check_deps
            configure
            build
            install_app
            echo ""
            ok "Done. Run: readected"
            echo ""
            ;;
        uninstall)
            info "Removing Readected..."
            sudo rm -f /usr/bin/readected /usr/bin/readected-updater
            sudo rm -f /usr/share/applications/readected.desktop
            sudo rm -f /usr/share/applications/readected-updater.desktop
            sudo update-desktop-database /usr/share/applications 2>/dev/null || true
            ok "Uninstalled"
            ;;
        *)
            echo "Usage: $0 [all|deps|configure|build|install|uninstall]"
            echo "  PREFIX=/usr/local $0"
            exit 1
            ;;
    esac
}

main "$@"
