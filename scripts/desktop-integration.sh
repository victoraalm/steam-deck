#!/usr/bin/env bash
# ==============================================================================
# scripts/desktop-integration.sh — Instala atalho + ícones (idempotente)
# ------------------------------------------------------------------------------
# Cria a entrada .desktop (pesquisável no menu/KRunner), uma cópia na área de
# trabalho e instala o ícone em vários tamanhos no tema hicolor (nítido em
# qualquer escala). Tudo em $HOME → PERSISTE a updates da SteamOS.
# Reexecutar é seguro.
#
# Uso: ./desktop-integration.sh [--uninstall]
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/lib/common.sh"

APP_NAME="Steam Deck Toolkit"
DESKTOP_ID="steam-deck-toolkit"
ICON_NAME="steam-deck-toolkit"
ICONS_SRC_DIR="$ROOT/assets/icons"
ICON_SRC_SVG="$ROOT/assets/deck-toolkit.svg"
ICON_SRC_PNG="$ROOT/assets/deck-toolkit.png"
HICOLOR="$HOME/.local/share/icons/hicolor"
FALLBACK_ICON_DIR="$HOME/.local/share/icons"
APPS_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$APPS_DIR/$DESKTOP_ID.desktop"
TOOLKIT_BIN="$ROOT/deck-toolkit"
DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
SIZES=(16 32 48 64 128 256)

refresh_caches() {
    require_cmd gtk-update-icon-cache && gtk-update-icon-cache -q -t -f "$HICOLOR" 2>/dev/null || true
    require_cmd update-desktop-database && update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
    local kb
    for kb in kbuildsycoca6 kbuildsycoca5; do
        if require_cmd "$kb"; then "$kb" >/dev/null 2>&1 || true; break; fi
    done
}

# --- Desinstalação ------------------------------------------------------------
if [ "${1:-}" = "--uninstall" ]; then
    banner "REMOVENDO INTEGRAÇÃO COM O DESKTOP"
    rm -f -- "$DESKTOP_FILE" "$DESKTOP_DIR/$DESKTOP_ID.desktop"
    for sz in "${SIZES[@]}"; do
        rm -f -- "$HICOLOR/${sz}x${sz}/apps/$ICON_NAME.png"
    done
    rm -f -- "$HICOLOR/scalable/apps/$ICON_NAME.svg"
    rm -f -- "$FALLBACK_ICON_DIR/$ICON_NAME.png" "$FALLBACK_ICON_DIR/$ICON_NAME.svg"
    refresh_caches
    log_ok "Atalho e ícones removidos."
    exit 0
fi

banner "INTEGRAÇÃO COM O DESKTOP"

# --- 1. Ícones (tema hicolor, vários tamanhos) --------------------------------
icons_installed=0
for sz in "${SIZES[@]}"; do
    src="$ICONS_SRC_DIR/$sz.png"
    if [ -f "$src" ]; then
        mkdir -p "$HICOLOR/${sz}x${sz}/apps"
        cp -f "$src" "$HICOLOR/${sz}x${sz}/apps/$ICON_NAME.png"
        icons_installed=$((icons_installed + 1))
    fi
done
if [ -f "$ICON_SRC_SVG" ]; then
    mkdir -p "$HICOLOR/scalable/apps"
    cp -f "$ICON_SRC_SVG" "$HICOLOR/scalable/apps/$ICON_NAME.svg"
    icons_installed=$((icons_installed + 1))
fi

if [ "$icons_installed" -gt 0 ]; then
    ICON_REF="$ICON_NAME"   # referencia pelo NOME → o tema escolhe o melhor tamanho
    log_ok "Ícones instalados no tema hicolor ($icons_installed arquivos)."
elif [ -f "$ICON_SRC_PNG" ]; then
    mkdir -p "$FALLBACK_ICON_DIR"
    cp -f "$ICON_SRC_PNG" "$FALLBACK_ICON_DIR/$ICON_NAME.png"
    ICON_REF="$FALLBACK_ICON_DIR/$ICON_NAME.png"
    log_warn "Tema hicolor indisponível; usei o PNG único."
else
    ICON_REF="utilities-terminal"
    log_warn "Nenhum ícone encontrado em assets/; usando ícone genérico do sistema."
fi

# --- 2. Como abrir um terminal para o menu TUI --------------------------------
if require_cmd konsole; then
    EXEC_CMD="konsole -e bash \"$TOOLKIT_BIN\""
    TERMINAL_FLAG="false"
else
    EXEC_CMD="\"$TOOLKIT_BIN\""
    TERMINAL_FLAG="true"   # deixa o ambiente desktop escolher o terminal
fi

# --- 3. Entrada .desktop (pesquisável no menu) --------------------------------
mkdir -p "$APPS_DIR"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=$APP_NAME
GenericName=Toolkit do Steam Deck
Comment=Configura e mantém o modo desktop do Steam Deck (Distrobox, Podman, Waydroid...)
Exec=$EXEC_CMD
Icon=$ICON_REF
Terminal=$TERMINAL_FLAG
Categories=Utility;System;Settings;
Keywords=steam;deck;distrobox;podman;waydroid;toolkit;arch;
EOF
chmod +x "$DESKTOP_FILE"
log_ok "Atalho instalado (pesquisável no menu): $DESKTOP_FILE"

# --- 4. Cópia na área de trabalho ---------------------------------------------
mkdir -p "$DESKTOP_DIR"
cp -f "$DESKTOP_FILE" "$DESKTOP_DIR/$DESKTOP_ID.desktop"
chmod +x "$DESKTOP_DIR/$DESKTOP_ID.desktop"
log_ok "Atalho na área de trabalho: $DESKTOP_DIR/$DESKTOP_ID.desktop"
log_info "Obs.: o KDE pode pedir, na 1ª vez, para confirmar que o atalho é confiável."

# --- 5. Atualiza os caches (menu + ícones) ------------------------------------
refresh_caches

echo ""
log_ok "Pronto! Procure por '$APP_NAME' no menu ou use o atalho da área de trabalho."
