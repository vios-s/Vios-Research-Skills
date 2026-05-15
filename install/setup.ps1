# setup.ps1 — Windows PowerShell one-command setup
# Installs VIOS Research Skills and configures the Claude Code SessionStart
# hook for automatic background updates. If Node.js/npx is missing, this script
# installs Node.js LTS with winget first.
#
# Usage (run as normal user, not Administrator):
#   irm https://raw.githubusercontent.com/vios-s/Vios-Research-Skills/main/install/setup.ps1 | iex

$ErrorActionPreference = "Stop"

$REPO     = "vios-s/Vios-Research-Skills"
$SETTINGS = Join-Path $env:USERPROFILE ".claude\settings.json"
$HOOK_CMD = "node -e `"const{spawn}=require('child_process');spawn('npx',['skills','update','--yes'],{detached:true,stdio:'ignore',shell:true}).unref()`""

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

function Ensure-Node {
    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    $hasNpx  = Get-Command npx -ErrorAction SilentlyContinue

    if ($hasNode -and $hasNpx) {
        return
    }

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "Node.js is required, but node and npx are not both available and winget is unavailable. Install Node.js LTS from https://nodejs.org/ and rerun this script."
    }

    Write-Host "==> Installing Node.js LTS with winget..."
    winget install --id OpenJS.NodeJS.LTS --source winget --accept-package-agreements --accept-source-agreements
    Update-ProcessPath

    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    $hasNpx  = Get-Command npx -ErrorAction SilentlyContinue

    if (-not ($hasNode -and $hasNpx)) {
        throw "Node.js was installed, but node and npx are not both available in this PowerShell session. Open a new PowerShell window and rerun this script."
    }
}

Ensure-Node

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
