$ErrorActionPreference = "Stop"

$statePath = Join-Path $env:USERPROFILE ".codex\windows-tools-repair-state.json"
$logPath = Join-Path $env:USERPROFILE ".codex\windows-tools-repair.log"
$autoRepairScript = Join-Path $PSScriptRoot "auto-repair-codex-windows-tools.ps1"
$lockPath = Join-Path $env:TEMP "codex-windows-tools-repair-watcher.lock"
$pollSeconds = 60

function Write-WatcherLog {
  param([string] $Message)
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Add-Content -LiteralPath $logPath -Value "[$timestamp] watcher: $Message"
}

$lockStream = $null
try {
  $lockStream = [System.IO.File]::Open($lockPath, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
} catch {
  exit 0
}

try {
  Write-WatcherLog "started"
  while ($true) {
    try {
      & powershell -NoProfile -ExecutionPolicy Bypass -File $autoRepairScript | ForEach-Object {
        Write-WatcherLog $_
      }
    } catch {
      Write-WatcherLog "repair check failed: $($_.Exception.Message)"
    }

    Start-Sleep -Seconds $pollSeconds
  }
} finally {
  if ($lockStream) {
    $lockStream.Dispose()
  }
}

