$ErrorActionPreference = "Stop"

$configPath = Join-Path $env:USERPROFILE ".codex\config.toml"
$cacheRoot = Join-Path $env:USERPROFILE ".codex\plugins\cache\openai-bundled"
$marketplaceCache = Join-Path $env:USERPROFILE ".codex\.tmp\bundled-marketplaces\openai-bundled"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

if (-not (Test-Path -LiteralPath $configPath)) {
  throw "Codex config not found: $configPath"
}

$config = Get-Content -LiteralPath $configPath -Raw
if ($config -match '(?m)^js_repl\s*=') {
  $config = $config -replace '(?m)^js_repl\s*=.*$', 'js_repl = true'
} elseif ($config -match '(?m)^\[features\]\s*$') {
  $config = $config -replace '(?m)^\[features\]\s*$', "[features]`r`njs_repl = true"
} else {
  $config = $config.TrimEnd() + "`r`n`r`n[features]`r`njs_repl = true`r`n"
}
Set-Content -LiteralPath $configPath -Value $config -Encoding UTF8

Stop-Process -Name extension-host -Force -ErrorAction SilentlyContinue

$paths = @(
  (Join-Path $cacheRoot "browser"),
  (Join-Path $cacheRoot "chrome"),
  (Join-Path $cacheRoot "computer-use"),
  $marketplaceCache
)

foreach ($path in $paths) {
  if (Test-Path -LiteralPath $path) {
    $destination = "$path.bak-$stamp"
    Move-Item -LiteralPath $path -Destination $destination
    Write-Output "Moved $path -> $destination"
  } else {
    Write-Output "Not found: $path"
  }
}

Write-Output "Set js_repl = true in $configPath"
Write-Output "Restart Codex Desktop, then let bundled plugins rebuild before testing Browser, Chrome, or Computer Use."

