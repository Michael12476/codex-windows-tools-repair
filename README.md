# Codex Windows Tools Repair

Small PowerShell repair script for Codex Desktop on Windows when the bundled in-app Browser, Chrome extension plugin, or Computer Use stop working after an update or cache mismatch.

## What It Fixes

- Codex in-app Browser plugin not loading.
- Google Chrome / Chrome extension native host is registered, but Codex cannot use it.
- Computer Use failing after a Codex update or plugin cache rebuild.
- `js_repl` accidentally disabled in the Codex config.
- Stale bundled plugin cache folders for `browser`, `chrome`, or `computer-use`.

## What The Script Does

- Sets `[features].js_repl = true` in `%USERPROFILE%\.codex\config.toml`.
- Stops the Codex Chrome extension host process if it is running.
- Moves these cache folders to timestamped `.bak-*` backups:
  - `%USERPROFILE%\.codex\plugins\cache\openai-bundled\browser`
  - `%USERPROFILE%\.codex\plugins\cache\openai-bundled\chrome`
  - `%USERPROFILE%\.codex\plugins\cache\openai-bundled\computer-use`
  - `%USERPROFILE%\.codex\.tmp\bundled-marketplaces\openai-bundled`

It does not delete the cache folders. It renames them so Codex can rebuild fresh copies on restart.

## Usage

Close Codex Desktop and Google Chrome first if possible, then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\repair-codex-windows-tools.ps1
```

Reopen Codex Desktop and wait for bundled plugins to rebuild. Then test Browser, Chrome extension, and Computer Use again.

## Optional Chrome Native Messaging Check

If the Chrome extension still fails, verify the native messaging host:

```powershell
$manifest = "$env:LOCALAPPDATA\OpenAI\extension\com.openai.codexextension.json"
Test-Path $manifest
Get-ItemProperty "HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.openai.codexextension"
```

The registry value should point to the manifest path.

## Notes

This is an unofficial community script. It is not affiliated with OpenAI.

