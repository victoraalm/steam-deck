#!/usr/bin/env bash
# ==============================================================================
# lib/common.sh — Biblioteca compartilhada do steam-deck toolkit
# ------------------------------------------------------------------------------
# Cores, logging padronizado e helpers reutilizados por todos os scripts.
# É "inlinada" pelo scripts/build.sh para gerar as versões standalone (dist/).
# ==============================================================================

# Evita carregar duas vezes quando vários scripts dão source na mesma sessão.
[ -n "${_DECK_COMMON_LOADED:-}" ] && return 0
_DECK_COMMON_LOADED=1

# --- Cores (desligadas automaticamente se a saída não for um terminal) --------
# [ -t 1 ] = stdout é um TTY. Ao redirecionar para arquivo/pipe, evita lixo ANSI.
if [ -t 1 ]; then
    RED=$'\033[0;31m'
    GREEN=$'\033[0;32m'
    YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'
    CYAN=$'\033[0;36m'
    BOLD=$'\033[1m'
    NC=$'\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
fi

# --- Logging padronizado (com timestamp) --------------------------------------
_ts() { date +'%H:%M:%S'; }
log_info() { printf '%s[%s] [INFO]%s %s\n'  "$CYAN"       "$(_ts)" "$NC" "$*"; }
log_ok()   { printf '%s[%s] [OK]%s %s\n'    "$GREEN"      "$(_ts)" "$NC" "$*"; }
log_warn() { printf '%s[%s] [AVISO]%s %s\n' "$YELLOW"     "$(_ts)" "$NC" "$*"; }
log_err()  { printf '%s[%s] [ERRO]%s %s\n'  "$RED"        "$(_ts)" "$NC" "$*" >&2; }
log_skip() { printf '%s[%s] [PULAR]%s %s\n' "$YELLOW"     "$(_ts)" "$NC" "$*"; }
log_act()  { printf '%s[%s] [AÇÃO]%s %s\n'  "$GREEN$BOLD" "$(_ts)" "$NC" "$*"; }

# --- Banner centralizado ------------------------------------------------------
banner() {
    local msg="$1" color="${2:-$CYAN}"
    echo -e "${color}===============================================================${NC}"
    echo -e "${color}  ${msg}${NC}"
    echo -e "${color}===============================================================${NC}"
}

# --- Confirmação sim/não (default = não) --------------------------------------
confirm() {
    local prompt="${1:-Continuar?}" answer
    read -r -p "$(printf '%s[?]%s %s [s/N] ' "$YELLOW" "$NC" "$prompt")" answer
    [[ "$answer" =~ ^[sSyY]$ ]]
}

# --- Verifica se um comando existe no PATH ------------------------------------
require_cmd() {
    command -v "$1" >/dev/null 2>&1
}
