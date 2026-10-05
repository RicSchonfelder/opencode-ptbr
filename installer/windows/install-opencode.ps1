# Instalador do opencode para Windows antigos (PowerShell 2.0+)
# Uso remoto:  irm https://SEU-HOST/install-opencode.ps1 | iex
# Uso local:   powershell -ExecutionPolicy Bypass -File install-opencode.ps1
# Padrao: instala a versao pt-BR (deste repositorio)
# Versao oficial (upstream): powershell -ExecutionPolicy Bypass -File install-opencode.ps1 -Official

param([switch]$Official, [switch]$PtBr)

$ErrorActionPreference = 'Stop'
# Windows 7/8 so usam TLS 1.0 por padrao; GitHub exige 1.2
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# 32-bit PowerShell em SO 64-bit reporta AMD64 via PROCESSOR_ARCHITEW6432
$pa = "${env:PROCESSOR_ARCHITEW6432}${env:PROCESSOR_ARCHITECTURE}"
if ($pa -match 'ARM64') { $arch = 'arm64' }
elseif ($pa -match 'AMD64') { $arch = 'x64-baseline' }  # ponytail: baseline roda em qualquer x64 (sem exigir AVX2)
else { throw 'opencode nao suporta Windows 32-bit.' }

# Instala sempre no AppData do usuario (nunca em D:)
$bin = Join-Path $env:LOCALAPPDATA 'opencode\bin'
$tmp = Join-Path $env:TEMP 'opencode-install.zip'
if ($Official) {
  $url = "https://github.com/anomalyco/opencode/releases/latest/download/opencode-windows-$arch.zip"
  $sub = 'oficial'
} else {
  $url = "https://github.com/RicSchonfelder/opencode-ptbr/releases/latest/download/opencode-windows-x64-ptbr.zip"
  $sub = 'pt-br'
}
$exe = Join-Path $bin 'opencode.exe'
# Reinstala se o canal instalado for diferente do pedido (marcador .opencode-channel)
$marker = Join-Path $bin '.opencode-channel'
$installed = if (Test-Path $marker) { (Get-Content $marker -TotalCount 1) } else { '' }
if ((Test-Path $exe) -and ($installed -eq $sub)) {
  Write-Host 'opencode ja esta instalado - pulando download.'
} else {
  Write-Host "Baixando opencode ($sub, $arch)..."
  (New-Object Net.WebClient).DownloadFile($url, $tmp)

  Write-Host "Extraindo para $bin ..."
  New-Item -ItemType Directory -Force -Path $bin | Out-Null
  Remove-Item "$bin\*" -Recurse -Force -ErrorAction SilentlyContinue
  # Shell COM funciona do PS 2.0 ao 7; Expand-Archive so existe no PS 5+
  $sh = New-Object -ComObject Shell.Application
  $sh.NameSpace($bin).CopyHere($sh.NameSpace($tmp).Items(), 0x14)

  if (-not (Test-Path $exe)) { throw 'Falha na extracao: opencode.exe nao encontrado.' }
  Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  Set-Content $marker $sub -Encoding ASCII
  Write-Host "Instalado canal: $sub"
}

$p = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($p -split ';') -notcontains $bin) {
  [Environment]::SetEnvironmentVariable('Path', "$p;$bin", 'User')
  Write-Host 'Adicionado ao PATH do usuario (permanente).'
}

# Disponibiliza o comando 'opencode' ja nesta sessao
$env:Path = "$env:Path;$bin"

# Shim na pasta atual: cmd procura na pasta atual antes do PATH,
# entao 'opencode' funciona na MESMA janela aberta antes da instalacao
$dir = (Get-Location).Path
if ($dir -notmatch '^[A-Za-z]:\\Windows') {
  try { Set-Content (Join-Path $dir 'opencode.cmd') "@`"$exe`" %*" -Encoding ASCII } catch {}
}

# Abre o opencode direto (funciona mesmo chamado via powershell -c do cmd)
& $exe
Write-Host 'Encerrado. Digite opencode para abrir de novo.'
