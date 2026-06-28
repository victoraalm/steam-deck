# Steam Deck Toolkit

Scripts para configurar e manter o **modo desktop** do Steam Deck (SteamOS /
Arch Linux): instalação de Distrobox + Podman, ambiente de desenvolvimento,
configuração regional e recuperação de serviços após atualizações do sistema.

![CI](https://github.com/victoraalm/steam-deck/actions/workflows/ci.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)

> ⚠️ **Importante — SteamOS é um Arch imutável.** A raiz do sistema é somente
> leitura e usa atualização atômica (A/B): **mudanças em `/` e `/usr` (e parte de
> `/etc`) são descartadas a cada update do sistema.** Por isso este toolkit foca
> em **user-space** (`~/.local`) e é **idempotente** — pode (e deve) ser
> reexecutado após updates. Os scripts marcam no cabeçalho e no menu o que toca o
> sistema (`[sistema]`) e, portanto, precisa ser reaplicado depois de atualizar.

## Sumário

- [Instalação (recomendada)](#instalação-recomendada)
- [Uso individual](#uso-individual-sem-menu)
- [Scripts disponíveis](#scripts-disponíveis)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Desenvolvimento](#desenvolvimento)
- [Publicar uma release](#publicar-uma-release)
- [Licença](#licença)

## Instalação (recomendada)

Baixa o toolkit para `~/.local/share/steam-deck` e abre o menu:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/victoraalm/steam-deck/main/install.sh)"
```

A instalação também cria um **atalho "Steam Deck Toolkit"** (com ícone) na **área
de trabalho** e **pesquisável** no menu de aplicativos / KRunner. Dá para reabrir
de três formas:

- pelo atalho na área de trabalho;
- buscando por **"Steam Deck Toolkit"** no menu;
- pelo terminal: `~/.local/share/steam-deck/deck-toolkit`.

No menu, **navegue com as setas ↑/↓**, **Enter** seleciona e **q/Esc** sai — cada
item mostra uma descrição. Há também opções para **atualizar o toolkit** e
**reinstalar o atalho**. Tudo fica em `$HOME`, então o atalho e o ícone
**sobrevivem aos updates** da SteamOS.

## Uso individual (sem menu)

Cada script também roda sozinho, a partir dos artefatos **standalone** da última
release (já vêm com a `lib` embutida):

```sh
# Instalar/atualizar Distrobox + Podman
bash -c "$(curl -fsSL https://github.com/victoraalm/steam-deck/releases/latest/download/distrobox-podman)"

# Destravar o Podman após um update (use --dry-run para simular)
bash -c "$(curl -fsSL https://github.com/victoraalm/steam-deck/releases/latest/download/podman)"
```

Trocando o nome do arquivo final pelos demais: `arch-devenv`, `deck-region`,
`waydroid`.

> Criar a distro Arch (após instalar o Distrobox+Podman):
>
> ```sh
> distrobox create --image docker.io/library/archlinux:latest --name arch --init \
>   --home "$HOME/.local/share/podman-static/share/containers/homes/arch/" --hostname arch
> ```

## Scripts disponíveis

| Script | O que faz | Escopo |
|---|---|---|
| [`setup/distrobox-podman`](setup/distrobox-podman) | Instala/atualiza Distrobox + Podman rootless (compara versões com o GitHub) | user-space (subuid em `/etc`) |
| [`setup/arch-devenv`](setup/arch-devenv) | Ambiente de dev **dentro do container Arch**: Zsh + Oh-My-Zsh, pyenv + Python, VS Code | container |
| [`setup/deck-region`](setup/deck-region) | Teclado US alt-intl, fuso `America/Sao_Paulo`, NTP e locale `en_US` | **sistema** ⚠ |
| [`recovery/podman`](recovery/podman) | "Doctor" que destrava o Podman (mata processos, remove locks, regenera estado). Tem `--dry-run` | user-space |
| [`recovery/waydroid`](recovery/waydroid) | Baixa e executa o atualizador oficial do Waydroid (com confirmação) | user-space |
| [`docs/persistent-pacman.md`](docs/persistent-pacman.md) | Guia: partição persistente para o pacman + chaves GPG sobreviverem aos updates | guia |

## Estrutura do repositório

```
.
├── deck-toolkit            # menu interativo (entrypoint)
├── install.sh              # bootstrap p/ curl | bash
├── lib/common.sh           # cores + logging + helpers compartilhados
├── setup/                  # distrobox-podman · arch-devenv · deck-region
├── recovery/               # podman · waydroid
├── docs/                   # persistent-pacman.md
├── assets/deck-toolkit.svg # ícone do atalho
├── scripts/                # build.sh (dist) · desktop-integration.sh (atalho+ícone)
└── .github/workflows/      # ci.yml (lint+build) · release.yml (publica dist/)
```

## Desenvolvimento

Os scripts em `setup/` e `recovery/` dão `source` em `lib/common.sh` (DRY). Para
gerar as versões **standalone** distribuídas nas releases (com a lib embutida):

```sh
bash scripts/build.sh   # gera ./dist/ e valida cada arquivo com `bash -n`
```

Recomendado rodar [`shellcheck`](https://www.shellcheck.net/) antes de commitar
(é o que a CI faz automaticamente).

## Publicar uma release

O workflow de release builda o `dist/` e anexa os artefatos automaticamente
quando você cria uma tag de versão:

```sh
git tag v1.0.0
git push origin v1.0.0
```

## Licença

[MIT](LICENSE) © victoraalm
