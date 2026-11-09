# setup.ps1 — Windows PowerShell one-command setup
# Installs VIOS Research Skills globally for Claude Code, Codex, Gemini CLI,
# Cursor, GitHub Copilot and OpenCode, and configures the Claude Code
# SessionStart hook for automatic background updates. If Node.js/npx is missing
# or older than the `skills` CLI needs (22.20+), this script installs Node.js LTS
# with winget first.
#
# Usage (run as normal user, not Administrator):
#   irm https://raw.githubusercontent.com/vios-s/Vios-Research-Skills/main/install/setup.ps1 | iex

$ErrorActionPreference = "Stop"

$REPO     = "vios-s/Vios-Research-Skills"
# Agent ids understood by the `skills` CLI (https://github.com/vercel-labs/skills).
$AGENTS   = @("claude-code", "codex", "gemini-cli", "antigravity-cli", "cursor", "github-copilot", "opencode")
$SettingsPath = Join-Path $env:USERPROFILE ".claude\settings.json"
$HOOK_CMD = "node -e `"const{spawn}=require('child_process');spawn('npx',['--yes','skills','update','-g','-y'],{detached:true,stdio:'ignore',shell:true}).unref()`""

function Update-ProcessPath {
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath    = [Environment]::GetEnvironmentVariable("Path", "User")
    $paths       = @($machinePath, $userPath) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $env:Path    = $paths -join ";"

    $commonNodePaths = @(
        "$env:ProgramFiles\nodejs",
        "$env:LOCALAPPDATA\Programs\nodejs"
    )

    foreach ($path in $commonNodePaths) {
        if ((Test-Path $path) -and ($env:Path -notlike "*$path*")) {
            $env:Path = "$env:Path;$path"
        }
    }
}

# The `skills` CLI needs Node.js >= 22.20 (it imports `glob` from fs/promises).
function Test-NodeTools {
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) { return $false }
    if (-not (Get-Command npx -ErrorAction SilentlyContinue)) { return $false }
    $version = [version]((node --version).TrimStart('v'))
    return $version -ge [version]"22.20.0"
}

function Ensure-Node {
    if (Test-NodeTools) {
        return
    }

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "Node.js >= 22.20 is required, but node and npx are not both available at that version and winget is unavailable. Install Node.js LTS from https://nodejs.org/ and rerun this script."
    }

    Write-Host "==> Installing Node.js LTS with winget..."
    winget install --id OpenJS.NodeJS.LTS --source winget --accept-package-agreements --accept-source-agreements
    Update-ProcessPath

    if (-not (Test-NodeTools)) {
        throw "Node.js LTS was installed, but node >= 22.20 and npx are not both available in this PowerShell session. Open a new PowerShell window and rerun this script."
    }
}

Ensure-Node

Write-Host "==> Installing VIOS Research Skills..."
# -g: user-level install (not just this directory); -y + --skill '*': no prompts.
npx --yes skills add $REPO -g -y --skill '*' -a @AGENTS

Write-Host "==> Configuring Claude Code auto-update hook..."

# Ensure settings.json exists
if (-not (Test-Path $SettingsPath)) {
    New-Item -ItemType Directory -Force -Path (Split-Path $SettingsPath) | Out-Null
    '{}' | Set-Content $SettingsPath -Encoding UTF8NoBOM
}

$raw      = Get-Content $SettingsPath -Raw -Encoding UTF8
$settings = $raw | ConvertFrom-Json

# Build nested structure if missing
if (-not ($settings.PSObject.Properties.Name -contains 'hooks')) {
    $settings | Add-Member -MemberType NoteProperty -Name hooks -Value ([PSCustomObject]@{})
}
if (-not ($settings.hooks.PSObject.Properties.Name -contains 'SessionStart')) {
    $settings.hooks | Add-Member -MemberType NoteProperty -Name SessionStart -Value @()
}

# Drop any earlier version of this hook (e.g. the old project-scoped
# `skills update --yes`) so re-running setup upgrades it in place.
$kept = @()
foreach ($entry in @($settings.hooks.SessionStart)) {
    if ($null -eq $entry.hooks) { $kept += $entry; continue }
    $others = @($entry.hooks | Where-Object { -not ("$($_.command)" -like "*'skills','update'*") })
    if ($others.Count -gt 0) {
        $entry.hooks = $others
        $kept += $entry
    }
}

$newHook = [PSCustomObject]@{
    matcher = "startup"
    hooks   = @([PSCustomObject]@{ type = "command"; command = $HOOK_CMD })
}
$settings.hooks.SessionStart = @($kept) + $newHook
$settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsPath -Encoding UTF8NoBOM
Write-Host "  Hook written to $SettingsPath"

Write-Host ""
Write-Host "Done! Skills installed for: $($AGENTS -join ', ')"
Write-Host "On every new Claude Code session, skills update silently in the background."
Write-Host "Other clients: run 'npx skills update -g -y' to update by hand."
