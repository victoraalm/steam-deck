# Changelog

Todas as mudanças relevantes deste projeto são documentadas aqui.
O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/)
e o projeto adota [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Adicionado
- `deck-toolkit`: menu interativo (bash puro, zero dependências) que lista e
  executa todos os scripts com descrição.
- `install.sh`: bootstrap para `curl | bash` que clona/atualiza o repo e abre o menu.
- `lib/common.sh`: biblioteca compartilhada (cores com detecção de TTY, logging
  com timestamp, `banner`/`confirm`/`require_cmd`).
- `scripts/build.sh`: gera versões standalone (lib inlined) em `dist/`.
- CI (`ci.yml`) com shellcheck + teste de build; release (`release.yml`) que
  publica os artefatos `dist/*` ao criar uma tag `v*`.
- Modo `--dry-run` no doctor do Podman e confirmação antes de executar o
  atualizador do Waydroid.
- `LICENSE` (MIT) e este `CHANGELOG`.
- `.gitattributes` forçando LF nos scripts (evita CRLF quebrar o bash no Linux).

### Alterado
- Repositório reestruturado em `setup/`, `recovery/`, `docs/`, `lib/`, `scripts/`.
- Todos os scripts agora compartilham `lib/common.sh` e marcam no cabeçalho se
  mexem no **sistema imutável** (perdido em update) ou em **user-space**.
- `setup_setup_deck_region` renomeado para `setup/deck-region`.
- `.zshrc` passou a ser ajustado de forma **não-destrutiva** (preserva o existente).
- `persistent_pacman` virou `docs/persistent-pacman.md`, limpo e formatado.

### Corrigido
- Podman: bug de quoting em `exec_safe`, loop de containers em subshell, campo
  de formato `{{.State.Status}}` inválido e flag inexistente `podman stop --force`.
- Distrobox/Podman: download do binário agora é verificado **antes** de gravar o
  "recibo" de versão (evitava reinstalação após download falho).
- Waydroid: valida o download antes de executar (não roda mais arquivo vazio/404).
