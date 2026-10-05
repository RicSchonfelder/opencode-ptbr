# Instalador Windows (legacy)

Instalador one-liner para Windows antigos (7/8/10/11) — sem Chocolatey, sem WSL, sem npm, sem admin.

Padrao de uso (igual `irm massgrave.dev/get | iex`):

## Instalar opencode

Abra o PowerShell e cole:

```powershell
powershell -c "irm https://raw.githubusercontent.com/RicSchonfelder/opencode-ptbr/dev/installer/windows/install-opencode.ps1 | iex"
```

O que faz:

- Baixa a versao **pt-BR** (TUI traduzida para Portugues do Brasil) desta release `pt-br-*`
- Detecta a arquitetura (x64 / arm64) e usa o build **x64-baseline** — roda em CPUs antigas sem AVX2
- Forca TLS 1.2 (necessario no Windows 7/8, que so usam TLS 1.0 por padrao)
- Extrai em `%LOCALAPPDATA%\opencode\bin` (nunca em D:), sem admin, e adiciona ao PATH do usuario
- Reinstala sozinho se o canal instalado for outro (marcador `.opencode-channel`)
- Compativel com PowerShell 2.0+ (usa WebClient + Shell COM em vez de Invoke-RestMethod/Expand-Archive)

### Versao oficial (upstream)

Para instalar a versao oficial sem traducao, use a flag `-Official`:

```powershell
powershell -ExecutionPolicy Bypass -File install-opencode.ps1 -Official
```

## Uso local (sem internet no host intermediario)

Copie `install-opencode.ps1` para a maquina (pendrive) e rode:

```powershell
powershell -ExecutionPolicy Bypass -File install-opencode.ps1
```

## Adicionar outro programa

Copie `install-opencode.ps1`, troque a variavel `$url` para o zip do release desejado e ajuste o nome do `.exe` verificado. Siga o mesmo padrao: baixar com `WebClient`, extrair com Shell COM, adicionar ao PATH.