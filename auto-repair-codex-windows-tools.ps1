$ErrorActionPreference = "Stop"

$statePath = Join-Path $env:USERPROFILE ".codex\windows-tools-repair-state.json"
$logPath = Join-Path $env:USERPROFILE ".codex\windows-tools-repair.log"
$repairScript = Join-Path $PSScriptRoot "repair-codex-windows-tools.ps1"

function Write-RepairLog {
  param([string] $Message)
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Add-Content -LiteralPath $logPath -Value "[$timestamp] $Message"
  Write-Output $Message
}

function Set-JsReplEnabled {
  $configPath = Join-Path $env:USERPROFILE ".codex\config.toml"
  if (-not (Test-Path -LiteralPath $configPath)) {
    Write-RepairLog "Codex config not found: $configPath"
    return
  }

  $config = Get-Content -LiteralPath $configPath -Raw
  $updated = $false
  if ($config -match '(?m)^js_repl\s*=') {
    $newConfig = $config -replace '(?m)^js_repl\s*=.*$', 'js_repl = true'
    $updated = $newConfig -ne $config
    $config = $newConfig
  } elseif ($config -match '(?m)^\[features\]\s*$') {
    $config = $config -replace '(?m)^\[features\]\s*$', "[features]`r`njs_repl = true"
    $updated = $true
  } else {
    $config = $config.TrimEnd() + "`r`n`r`n[features]`r`njs_repl = true`r`n"
    $updated = $true
  }

  if ($updated) {
    Set-Content -LiteralPath $configPath -Value $config -Encoding UTF8
    Write-RepairLog "Set js_repl = true in $configPath"
  }
}

Set-JsReplEnabled

$codexPackage = Get-AppxPackage OpenAI.Codex -ErrorAction SilentlyContinue
if (-not $codexPackage) {
  Write-RepairLog "OpenAI.Codex AppX package not found; skipping cache repair."
  exit 0
}

$currentVersion = [string] $codexPackage.Version
$state = $null
if (Test-Path -LiteralPath $statePath) {
  try {
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
  } catch {
    Write-RepairLog "Could not read state file; treating as first run."
  }
}

if ($state -and $state.lastRepairedVersion -eq $currentVersion) {
  Write-RepairLog "Codex version $currentVersion already repaired; no cache reset needed."
  exit 0
}

$codexProcesses = Get-Process -Name Codex,codex -ErrorAction SilentlyContinue
if ($codexProcesses) {
  Write-RepairLog "Codex version is $currentVersion, but Codex is running; cache repair deferred until next trigger."
  exit 0
}

if (-not (Test-Path -LiteralPath $repairScript)) {
  throw "Repair script not found: $repairScript"
}

Write-RepairLog "Codex version changed to $currentVersion; running cache repair."
& powershell -NoProfile -ExecutionPolicy Bypass -File $repairScript | ForEach-Object {
  Write-RepairLog $_
}

$newState = [pscustomobject]@{
  lastRepairedVersion = $currentVersion
  lastRepairedAt = (Get-Date).ToString("o")
}
$newState | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding UTF8
Write-RepairLog "Recorded repaired Codex version $currentVersion."

