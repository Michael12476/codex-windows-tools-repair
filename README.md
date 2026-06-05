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

## Automatic Repair After Codex Updates

If the tools break after every Codex Desktop update, install the auto-repair task:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-auto-repair-task.ps1
```

The installer copies the scripts to `%USERPROFILE%\.codex\windows-tools-repair` and registers a current-user startup entry named `CodexWindowsToolsAutoRepair`.

The task runs at user logon. It:

- Always makes sure `js_repl = true`.
- Checks the installed `OpenAI.Codex` Windows app version.
- Runs the cache repair only when the Codex app version changes.
- Skips cache repair if Codex is currently running, so it does not disrupt an active session.

To remove the task:

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-auto-repair-task.ps1
```

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
