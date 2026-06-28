# Partição persistente para o pacman (e correção de GPG) no Steam Deck

Guia para criar uma **partição persistente** no Steam Deck (SteamOS / Arch) e
apontar o `pacman` para ela, de modo que **banco de pacotes, cache, logs e chaves
GPG sobrevivam às atualizações do sistema**.

## Por que isto é necessário

O SteamOS usa uma **raiz imutável com atualização atômica (A/B)**: a cada update
do sistema, mudanças em `/` e `/usr` (e parte de `/etc`) são **descartadas**.
Isso inclui o banco do `pacman` e o **keyring GPG**, o que costuma quebrar
`pacman -Syu` com erros de assinatura. Movendo esses dados para uma **partição
separada**, eles persistem entre os updates.

> ⚠️ **AVISO — risco de perda de dados.** As etapas de particionamento (`fdisk`,
> `mkfs`) **apagam dados** se aplicadas na partição errada. Confira o nome do
> dispositivo com muito cuidado e, de preferência, faça backup antes.

## Requisitos

- Steam Deck com SteamOS (modo desktop) e acesso ao terminal (Konsole).
- Familiaridade com comandos básicos de Linux.
- Espaço livre em disco não particionado.

---

## Passo 1 — Criar a partição persistente

### 1.1 Identificar o disco

```bash
lsblk
```

Anote o disco (ex.: `/dev/nvme0n1`) e o número da próxima partição livre.

### 1.2 Criar a partição

```bash
sudo fdisk /dev/nvme0n1
```

Crie uma nova partição do tipo *Linux filesystem*. **Substitua `/dev/nvme0n1`
pelo seu disco.**

### 1.3 Formatar como ext4

```bash
# Substitua nvme0n1p9 pelo nome real da partição criada
sudo mkfs.ext4 /dev/nvme0n1p9
```

### 1.4 Montar a partição

```bash
sudo mkdir -p /usr/local
sudo mount /dev/nvme0n1p9 /usr/local
```

### 1.5 Montar automaticamente no boot (`/etc/fstab`)

Prefira o **UUID** (mais estável que o nome do dispositivo):

```bash
# Descubra o UUID
sudo blkid /dev/nvme0n1p9

# Adicione ao fstab (troque <UUID> pelo valor acima)
echo "UUID=<UUID> /usr/local ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

---

## Passo 2 — Apontar o pacman para a partição

### 2.1 Editar `/etc/pacman.conf`

```bash
sudo nano /etc/pacman.conf
```

Ajuste as linhas:

```ini
DBPath      = /usr/local/var/lib/pacman
CacheDir    = /usr/local/var/cache/pacman/pkg
LogFile     = /usr/local/var/log/pacman/pacman.log
GPGDir      = /usr/local/etc/pacman.d/gnupg/
```

### 2.2 Mover as chaves GPG existentes

```bash
sudo mkdir -p /usr/local/etc/pacman.d
sudo mv /etc/pacman.d/gnupg /usr/local/etc/pacman.d/
```

---

## Passo 3 — Resolver erros de GPG

```bash
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman-key --populate holo     # keyring específico da SteamOS
```

Verifique se as chaves foram populadas:

```bash
ls -la /usr/local/etc/pacman.d/gnupg/
```

---

## Passo 4 — Testar

```bash
sudo pacman -Syu
```

Se atualizar sem erros de assinatura, está tudo certo.

---

## Conclusão

Com a partição montada em `/usr/local` e o `pacman.conf` apontando para ela, o
estado do pacman e as chaves GPG **persistem entre updates** da SteamOS.

> 🔁 **Pós-update.** O `/etc/pacman.conf` e o `/etc/fstab` ficam na raiz do
> sistema e **podem voltar ao padrão** após um update grande da SteamOS. Se isso
> acontecer, **reaplique apenas os Passos 1.5 e 2** (os dados na partição
> continuam intactos — basta reapontar). Veja também os scripts de recuperação
> em [`recovery/`](../recovery).
