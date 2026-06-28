#!/usr/bin/env bash
# ==============================================================================
# scripts/build.sh — Gera versões standalone (lib inlined) em dist/
# ------------------------------------------------------------------------------
# Para cada script de setup/ e recovery/, substitui a linha que faz
#   source ".../lib/common.sh"
# pelo conteúdo da própria lib, produzindo um arquivo autocontido que roda via
# `curl | bash` sem depender de mais nada. Esses arquivos viram os anexos da
# release no GitHub.
# ==============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB="$ROOT/lib/common.sh"
DIST="$ROOT/dist"

# Scripts que viram standalone (deck-toolkit/install.sh rodam do clone, ficam fora).
SCRIPTS=(
    setup/distrobox-podman
    setup/arch-devenv
    setup/deck-region
    recovery/podman
    recovery/waydroid
)

rm -rf "$DIST"
mkdir -p "$DIST"

for rel in "${SCRIPTS[@]}"; do
    src="$ROOT/$rel"
    out="$DIST/$(basename "$rel")"

    # Inlina a lib no lugar da linha 'source'. Da lib, pula o shebang e as
    # linhas do guard de duplo-source (o 'return' não é válido em script top-level).
    awk -v libfile="$LIB" '
        /source .*lib\/common\.sh/ {
            print "# --- lib/common.sh (inlined por scripts/build.sh) ---"
            while ((getline line < libfile) > 0) {
                if (line ~ /^#!/)                 continue
                if (line ~ /_DECK_COMMON_LOADED/) continue
                print line
            }
            close(libfile)
            print "# --- fim do trecho inlined ---"
            next
        }
        { print }
    ' "$src" > "$out"

    chmod +x "$out"

    # Sanidade: o arquivo gerado tem que passar no checador de sintaxe.
    if bash -n "$out"; then
        echo "build: $rel -> dist/$(basename "$rel")  [ok]"
    else
        echo "build: FALHA de sintaxe em dist/$(basename "$rel")" >&2
        exit 1
    fi
done

echo ""
echo "Pronto. Artefatos standalone em: $DIST"
