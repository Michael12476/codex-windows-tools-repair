$ErrorActionPreference = "Stop"

$startupName = "CodexWindowsToolsAutoRepair"
$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

if ((Get-ItemProperty -Path $runKey -Name $startupName -ErrorAction SilentlyContinue)) {
  Remove-ItemProperty -Path $runKey -Name $startupName
  Write-Output "Removed startup entry: $startupName"
} else {
  Write-Output "Startup entry not found: $startupName"
}

Get-CimInstance Win32_Process |
  Where-Object { $_.CommandLine -like "*watch-codex-windows-tools.ps1*" } |
  ForEach-Object {
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    Write-Output "Stopped watcher process: $($_.ProcessId)"
  }
