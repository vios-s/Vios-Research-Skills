# setup.ps1 — Windows PowerShell one-command setup
# Installs VIOS Research Skills and configures the Claude Code SessionStart
# hook for automatic background updates.
#
# Usage (run as normal user, not Administrator):
#   irm https://raw.githubusercontent.com/vios-s/Vios-Research-Skills/main/install/setup.ps1 | iex

$ErrorActionPreference = "Stop"

$REPO     = "vios-s/Vios-Research-Skills"
$SETTINGS = Join-Path $env:USERPROFILE ".claude\settings.json"
$HOOK_CMD = "node -e `"const{spawn}=require('child_process');spawn('npx',['skills','update','--yes'],{detached:true,stdio:'ignore',shell:true}).unref()`""

Write-Host "==> Installing VIOS Research Skills..."
npx skills add $REPO

Write-Host "==> Configuring Claude Code auto-update hook..."

# Ensure settings.json exists
if (-not (Test-Path $SETTINGS)) {
    New-Item -ItemType Directory -Force -Path (Split-Path $SETTINGS) | Out-Null
    '{}' | Set-Content $SETTINGS -Encoding UTF8NoBOM
}

$raw      = Get-Content $SETTINGS -Raw -Encoding UTF8
$settings = $raw | ConvertFrom-Json

# Build nested structure if missing
if (-not ($settings.PSObject.Properties.Name -contains 'hooks')) {
    $settings | Add-Member -MemberType NoteProperty -Name hooks -Value ([PSCustomObject]@{})
}
if (-not ($settings.hooks.PSObject.Properties.Name -contains 'SessionStart')) {
    $settings.hooks | Add-Member -MemberType NoteProperty -Name SessionStart -Value @()
}

# Check if hook already present
$alreadyPresent = $false
foreach ($entry in $settings.hooks.SessionStart) {
    foreach ($h in $entry.hooks) {
        if ($h.command -eq $HOOK_CMD) { $alreadyPresent = $true; break }
    }
    if ($alreadyPresent) { break }
}

if ($alreadyPresent) {
    Write-Host "  Hook already configured, skipping."
} else {
    $newHook  = [PSCustomObject]@{ hooks = @([PSCustomObject]@{ type = "command"; command = $HOOK_CMD }) }
    $settings.hooks.SessionStart = @($settings.hooks.SessionStart) + $newHook
    $settings | ConvertTo-Json -Depth 10 | Set-Content $SETTINGS -Encoding UTF8NoBOM
    Write-Host "  Hook added to $SETTINGS"
}

Write-Host ""
Write-Host "Done! Skills installed and auto-update hook configured."
Write-Host "On every Claude Code session start, skills will update silently in the background."
