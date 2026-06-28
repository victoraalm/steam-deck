#!/usr/bin/env bash
# ==============================================================================
# scripts/desktop-integration.sh — Instala atalho + ícone (idempotente)
# ------------------------------------------------------------------------------
# Cria a entrada .desktop (pesquisável no menu/KRunner), uma cópia na área de
# trabalho e instala o ícone. Tudo em $HOME → PERSISTE a updates da SteamOS.
# Reexecutar é seguro: apenas regrava/atualiza o que for preciso.
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
ICON_SRC_PNG="$ROOT/assets/deck-toolkit.png"
ICON_SRC_SVG="$ROOT/assets/deck-toolkit.svg"
ICON_DEST_DIR="$HOME/.local/share/icons"
APPS_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$APPS_DIR/$DESKTOP_ID.desktop"
TOOLKIT_BIN="$ROOT/deck-toolkit"
DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"

# --- Desinstalação ------------------------------------------------------------
if [ "${1:-}" = "--uninstall" ]; then
    banner "REMOVENDO INTEGRAÇÃO COM O DESKTOP"
    rm -f -- "$DESKTOP_FILE" "$DESKTOP_DIR/$DESKTOP_ID.desktop" \
        "$ICON_DEST_DIR/$DESKTOP_ID.png" "$ICON_DEST_DIR/$DESKTOP_ID.svg"
    require_cmd update-desktop-database && update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
    log_ok "Atalho e ícone removidos."
    exit 0
fi

banner "INTEGRAÇÃO COM O DESKTOP"

# --- 1. Ícone -----------------------------------------------------------------
mkdir -p "$ICON_DEST_DIR"
if [ -f "$ICON_SRC_PNG" ]; then
    cp -f "$ICON_SRC_PNG" "$ICON_DEST_DIR/$DESKTOP_ID.png"
    ICON_REF="$ICON_DEST_DIR/$DESKTOP_ID.png"
    log_ok "Ícone (PNG) instalado: $ICON_REF"
elif [ -f "$ICON_SRC_SVG" ]; then
    cp -f "$ICON_SRC_SVG" "$ICON_DEST_DIR/$DESKTOP_ID.svg"
    ICON_REF="$ICON_DEST_DIR/$DESKTOP_ID.svg"
    log_ok "Ícone (SVG) instalado: $ICON_REF"
else
    log_warn "Nenhum ícone encontrado em assets/; usando ícone genérico do sistema."
    ICON_REF="utilities-terminal"
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

# --- 5. Atualiza o cache do menu de aplicativos -------------------------------
require_cmd update-desktop-database && update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true

echo ""
log_ok "Pronto! Procure por '$APP_NAME' no menu ou use o atalho da área de trabalho."
