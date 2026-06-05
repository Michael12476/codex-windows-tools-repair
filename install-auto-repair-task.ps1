$ErrorActionPreference = "Stop"

$installDir = Join-Path $env:USERPROFILE ".codex\windows-tools-repair"
$startupName = "CodexWindowsToolsAutoRepair"
$sourceFiles = @(
  "repair-codex-windows-tools.ps1",
  "auto-repair-codex-windows-tools.ps1",
  "watch-codex-windows-tools.ps1"
)

New-Item -ItemType Directory -Path $installDir -Force | Out-Null

foreach ($file in $sourceFiles) {
  $source = Join-Path $PSScriptRoot $file
  if (-not (Test-Path -LiteralPath $source)) {
    throw "Required script not found: $source"
  }
  Copy-Item -LiteralPath $source -Destination (Join-Path $installDir $file) -Force
}

$watcherScript = Join-Path $installDir "watch-codex-windows-tools.ps1"
$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$startupCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$watcherScript`""
New-Item -Path $runKey -Force | Out-Null
Set-ItemProperty -Path $runKey -Name $startupName -Value $startupCommand

$codexPackage = Get-AppxPackage OpenAI.Codex -ErrorAction SilentlyContinue
if ($codexPackage) {
  $statePath = Join-Path $env:USERPROFILE ".codex\windows-tools-repair-state.json"
  $state = [pscustomobject]@{
    lastRepairedVersion = [string] $codexPackage.Version
    lastRepairedAt = (Get-Date).ToString("o")
    initializedByInstaller = $true
  }
  $state | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding UTF8
  Write-Output "Recorded current Codex version as already handled: $($codexPackage.Version)"
}

Write-Output "Installed scripts to $installDir"
Write-Output "Registered startup entry: $startupName"
Write-Output "The background repair watcher starts at user logon."
