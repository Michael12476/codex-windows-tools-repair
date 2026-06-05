$ErrorActionPreference = "Stop"

$startupName = "CodexWindowsToolsAutoRepair"
$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

if ((Get-ItemProperty -Path $runKey -Name $startupName -ErrorAction SilentlyContinue)) {
  Remove-ItemProperty -Path $runKey -Name $startupName
  Write-Output "Removed startup entry: $startupName"
} else {
  Write-Output "Startup entry not found: $startupName"
}
