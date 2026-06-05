$ErrorActionPreference = "Stop"

$installDir = Join-Path $env:USERPROFILE ".codex\windows-tools-repair"
$startupName = "CodexWindowsToolsAutoRepair"
$sourceFiles = @(
  "repair-codex-windows-tools.ps1",
  "auto-repair-codex-windows-tools.ps1"
)

New-Item -ItemType Directory -Path $installDir -Force | Out-Null

foreach ($file in $sourceFiles) {
  $source = Join-Path $PSScriptRoot $file
  if (-not (Test-Path -LiteralPath $source)) {
    throw "Required script not found: $source"
  }
  Copy-Item -LiteralPath $source -Destination (Join-Path $installDir $file) -Force
}

$autoRepairScript = Join-Path $installDir "auto-repair-codex-windows-tools.ps1"
$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$startupCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$autoRepairScript`""
New-Item -Path $runKey -Force | Out-Null
Set-ItemProperty -Path $runKey -Name $startupName -Value $startupCommand

Write-Output "Installed scripts to $installDir"
Write-Output "Registered startup entry: $startupName"
Write-Output "The repair check runs at user logon."
