#!/usr/bin/env bash
# ==============================================================================
# install.sh — Bootstrap do steam-deck toolkit
# ------------------------------------------------------------------------------
# Clona (ou atualiza) o repositório e abre o menu. Pensado para:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/victoraalm/steam-deck/main/install.sh)"
#
# O destino pode ser sobrescrito com a variável DECK_TOOLKIT_DIR.
# ==============================================================================

set -euo pipefail

REPO="https://github.com/victoraalm/steam-deck.git"
DEST="${DECK_TOOLKIT_DIR:-$HOME/.local/share/steam-deck}"

if ! command -v git >/dev/null 2>&1; then
    echo "ERRO: git não encontrado. Instale o git ou baixe o repositório manualmente." >&2
    exit 1
fi

if [ -d "$DEST/.git" ]; then
    echo "Atualizando toolkit em $DEST..."
    # fetch + reset --hard: força a última versão e descarta mudanças locais
    # (ex.: bits de execução), que faziam o 'pull --ff-only' travar na versão antiga.
    if git -C "$DEST" fetch --depth 1 origin 2>/dev/null \
        && git -C "$DEST" reset --hard origin/main 2>/dev/null; then
        echo "Atualizado para a última versão."
    else
        echo "Aviso: não atualizei (offline?). Seguindo com a versão local."
    fi
else
    echo "Clonando toolkit em $DEST..."
    mkdir -p "$(dirname "$DEST")"
    git clone --depth 1 "$REPO" "$DEST"
fi

chmod +x "$DEST/deck-toolkit" "$DEST"/setup/* "$DEST"/recovery/* "$DEST"/scripts/*.sh 2>/dev/null || true

# Instala o atalho na área de trabalho + ícone (pesquisável no menu). Não-fatal.
bash "$DEST/scripts/desktop-integration.sh" \
    || echo "Aviso: não consegui instalar o atalho do desktop (siga pelo terminal)."

echo ""
echo "Toolkit pronto em: $DEST"
echo "Abra pelo atalho 'Steam Deck Toolkit' (menu/área de trabalho) ou rode '$DEST/deck-toolkit'."
echo ""
exec "$DEST/deck-toolkit"
